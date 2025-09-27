import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/wifi_scanner/connection_repo.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum TrainingStatus {
  waitingBluetooth,
  waitingNFC,
  checkingNFC,
  testMode, // weapon test mode
  ready, // armed, waiting first point
  inTraining,
  ended,
  errorNFC,
  disconnected,
}

class FencingTrainingViewModel extends BaseViewModel {
  // Repository
  final ConnectionRepository _repository = ConnectionRepository();
  final TrainingUsecase _trainingUsecase = TrainingUsecase();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  // UI / Context
  BuildContext? context;

  // State
  final _status =
      BehaviorSubject<TrainingStatus>.seeded(TrainingStatus.waitingBluetooth);
  final _playerData = BehaviorSubject<TraineeData?>();
  final _points = BehaviorSubject<int>.seeded(0);
  final _timeLeftMs = BehaviorSubject<int?>();
  final _elapsedMs = BehaviorSubject<int>.seeded(0);
  final _pointIndicator = BehaviorSubject<bool>.seeded(false);
  final _movementData = BehaviorSubject<PlayerMovementData>();
  final _pointRecords = BehaviorSubject<PointDataEntity?>();

  // Streams
  Stream<TrainingStatus> get statusStream => _status.stream;
  Stream<TraineeData?> get playerDataStream => _playerData.stream;
  Stream<int> get pointsStream => _points.stream;
  Stream<int?> get timeLeftMsStream => _timeLeftMs.stream;
  Stream<int> get elapsedMsStream => _elapsedMs.stream;
  Stream<bool> get pointIndicatorStream => _pointIndicator.stream;
  Stream<PlayerMovementData> get movementDataStream => _movementData.stream;
  Stream<PointDataEntity> get pointRecordStream => _pointRecords.stream
      .map((event) => event ?? PointDataEntity(timeInMs: -1, speed: 0));
  Stream<bool> get isPausedStream => _status.stream.map((_) => _isPaused);

  // Inputs from UI
  int? targetMinutes;
  int? targetPoints;

  // Internal
  Timer? _timer;
  int _startTimestampMs = 0;
  bool _timerStarted = false;
  bool _inTestMode = true;
  bool _endedAlready = false;
  bool _isPaused = false;
  String _endedBy = 'manual';
  final List<PointDataEntity> _pointRecordsList = [];
  final List<PlayerMovementData> _movementRecords = [];
  TraineeData? _trainee;
  int? _deviceNumber;
  double _lastSpeed = 0;
  late ExerciseData exercise;
  bool _isNFCPolling = true;

  FencingTrainingViewModel() {
    _repository.status.listen((status) {
      _onDeviceData(status);
      debugPrint(
          'Device ${status.deviceNumber}: ${status.state}, ${status.message}, nfcUid: ${status.nfcUid}, point: ${status.point}, speed: ${status.speed}');
    });
  }

  @override
  void start() {
    WakelockPlus.enable();
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    Map<String, dynamic> exerciseJson =
        jsonDecode(_appPreferences.getTraining()![0]);
    exercise = ExerciseData.fromJson(exerciseJson);
  }

  void setContext(BuildContext c) {
    context = c;
  }

  Future<void> connectToDevice(int deviceNumber) async {
    _deviceNumber = deviceNumber;
    try {
      inputState.add(ContentState());
      await _repository.connect(deviceNumber, "training");
      _status.add(TrainingStatus.waitingNFC);
      _isNFCPolling = true;
      _repository.startNfcPolling(deviceNumber);
    } catch (e, stackTrace) {
      debugPrint("Connection error for device $deviceNumber: $e");
      debugPrintStack(stackTrace: stackTrace, label: "Connection error");
      _onDisconnected("Connection failed: $e", isManual: false);
    }
  }

  Future<void> scanQRCode(BuildContext context) async {
    _isNFCPolling = false;
    _repository.stopNfcPolling(_deviceNumber!);
    try {
      final controller = MobileScannerController();
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                String? code = capture.barcodes.first.rawValue;
                debugPrint(code);
                if (code != null) {
                  code += '00000000000000000000';
                  Navigator.pop(context, code);
                }
              },
            ),
          ),
        ),
      );

      controller.dispose();

      if (result != null && result is String) {
        await _checkNFC(result, _deviceNumber!);
      } else {
        inputState.add(
          ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: "Invalid QR code",
            retryAction: () {
              inputState.add(ContentState());
              _status.add(TrainingStatus.waitingNFC);
              _isNFCPolling = true;
              _repository.startNfcPolling(_deviceNumber!);
            },
          ),
        );
        _status.add(TrainingStatus.errorNFC);
      }
    } catch (e) {
      inputState.add(
        ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: "Failed to scan QR code: $e",
          retryAction: () {
            inputState.add(ContentState());
            _status.add(TrainingStatus.waitingNFC);
            _isNFCPolling = true;
            _repository.startNfcPolling(_deviceNumber!);
          },
        ),
      );
      _status.add(TrainingStatus.errorNFC);
    }
  }

  void _onDeviceData(ConnectionStatus status) async {
    if (status.deviceNumber != _deviceNumber) {
      return; // Ignore responses from other devices
    }
    debugPrint(
        "Device ${status.deviceNumber}: ${status.state}, ${status.message}, nfcUid: ${status.nfcUid}, point: ${status.point}, speed: ${status.speed}");

    // Handle NFC
    if (_isNFCPolling &&
        status.state == ConnectionState.nfcSuccess &&
        status.nfcUid != null) {
      await _checkNFC(status.nfcUid!, status.deviceNumber);
    } else if (status.state == ConnectionState.nfcError) {
      inputState.add(
        ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: status.message ?? "NFC Error",
          retryAction: () {
            inputState.add(ContentState());
            _isNFCPolling = true;
            _repository.startNfcPolling(_deviceNumber!);
          },
        ),
      );
      _status.add(TrainingStatus.errorNFC);
    } else if (status.state == ConnectionState.disconnected &&
        !_endedAlready &&
        !['manual', 'time', 'points', 'paused'].contains(_endedBy)) {
      _repository.stopPointPolling(_deviceNumber!);
      _repository.stopSpeedPolling(_deviceNumber!);
      _onDisconnected(status.message ?? "Disconnected", isManual: false);
    }

    // Ignore updates if paused or disconnected
    if (_isPaused || _status.value == TrainingStatus.disconnected) return;

    // Handle Speed
    if (status.state == ConnectionState.connected && status.speed != null) {
      _lastSpeed = status.speed!;
      final movementData = PlayerMovementData(
        speed: status.speed!,
        direction: status.direction ?? 1,
        timeInMs: _timerStarted
            ? (DateTime.now().millisecondsSinceEpoch - _startTimestampMs)
            : 0,
      );
      if (!_movementData.isClosed) {
        _movementData.add(movementData);
        _movementRecords.add(movementData);
      }
    }

    // Handle Point
    if (status.state == ConnectionState.connected &&
        status.point != null &&
        status.point!) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // Test mode: update point indicator for 500ms
      if (_inTestMode) {
        _pointIndicator.add(true);
        Timer(const Duration(milliseconds: 500), () {
          if (!_pointIndicator.isClosed) {
            _pointIndicator.add(false);
          }
        });
        return;
      }

      // Training mode: only add points if not exceeding target
      if (targetPoints != null && _points.value >= targetPoints!) {
        return; // Prevent adding points beyond target
      }

      // First point -> start timer
      if (!_timerStarted) {
        _startTimestampMs = nowMs;
        _startTimer();
        _timerStarted = true;
        _status.add(TrainingStatus.inTraining);
      }

      final tsFromStartMs = _timerStarted ? (nowMs - _startTimestampMs) : 0;
      _pointRecordsList.add(PointDataEntity(
        timeInMs: tsFromStartMs,
        speed: _lastSpeed,
      ));
      if (!_pointRecords.isClosed) {
        _pointRecords.add(_pointRecordsList.last);
      }

      _points.add(_points.value + 1);

      _checkStopByTargets();
    }
  }

  List<PointDataEntity> get recordedPoints => _pointRecordsList;

  Future<void> _checkNFC(String rfidUID, int deviceNumber) async {
    if (_status.value != TrainingStatus.waitingNFC &&
        _status.value != TrainingStatus.errorNFC) {
      return;
    }
    debugPrint("[checkNFC]Checking NFC: $rfidUID");
    _status.add(TrainingStatus.checkingNFC);

    Either<Failure, TraineeData> res =
        await _trainingUsecase.checkTraineeExistence(rfidUID);
    res.fold(
      (failure) {
        if (failure.code == 10) {
          _status.add(TrainingStatus.errorNFC);
          inputState.add(ContentState());
          _isNFCPolling = true;
          _repository.startNfcPolling(deviceNumber);
        } else {
          inputState.add(
            ErrorState(
              stateRenderType: StateRenderType.popupErrorState,
              message: failure.message,
              retryAction: () {
                inputState.add(ContentState());
                _status.add(TrainingStatus.waitingNFC);
                _isNFCPolling = true;
                _repository.startNfcPolling(deviceNumber);
              },
            ),
          );
        }
        _repository.confirmNfc(deviceNumber, false);
      },
      (trainee) async {
        if (!trainee.isFencer) {
          inputState.add(
            ErrorState(
              stateRenderType: StateRenderType.popupErrorState,
              message: "The player is not a fencer",
              retryAction: () {
                inputState.add(ContentState());
                _status.add(TrainingStatus.waitingNFC);
                _isNFCPolling = true;
                _repository.startNfcPolling(deviceNumber);
              },
            ),
          );
          _status.add(TrainingStatus.errorNFC);
          await _repository.confirmNfc(deviceNumber, false);
          return;
        }
        _trainee = trainee;
        _playerData.add(trainee);

        await _repository.confirmNfc(deviceNumber, true);
        await _repository.resetFlags(deviceNumber);
        await _repository.start(deviceNumber);
        _repository.startPointPolling(deviceNumber);
        _inTestMode = true;
        _status.add(TrainingStatus.testMode);
      },
    );
  }

  Future<void> finishTestAndArmTraining({
    required int? minutes,
    required int? targetPts,
  }) async {
    if (minutes == null && targetPts == null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        const SnackBar(content: Text('Please provide time or points target')),
      );
      return;
    }

    targetMinutes = minutes;
    targetPoints = targetPts;

    await _repository.stop(_deviceNumber!);
    await _repository.start(_deviceNumber!);
    _repository.startPointPolling(_deviceNumber!);
    _repository.startSpeedPolling(_deviceNumber!);

    _points.add(0);
    _pointIndicator.add(false);
    _pointRecordsList.clear();
    _movementRecords.clear();
    _pointRecords.add(null);
    _timerStarted = false;
    _elapsedMs.add(0);

    _inTestMode = false;
    _status.add(TrainingStatus.ready);

    if (targetMinutes != null) {
      _timeLeftMs.add(targetMinutes! * 60 * 1000);
    } else {
      _timeLeftMs.add(null);
    }
  }

  void _startTimer() {
    if (_isPaused) return;

    final durationMs =
        targetMinutes != null ? targetMinutes! * 60 * 1000 : null;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (_isPaused) return;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final elapsed = nowMs - _startTimestampMs;
      _elapsedMs.add(elapsed);
      if (durationMs != null) {
        final left = durationMs - elapsed;
        _timeLeftMs.add(left);
        if (left <= 0) {
          _endedBy = 'time';
          stopTraining();
        }
      }
      _checkStopByTargets();
    });
  }

  void _checkStopByTargets() {
    if (targetPoints != null && _points.value >= targetPoints!) {
      _endedBy = 'points';
      stopTraining();
    }
  }

  void pauseTraining() {
    if (_isPaused || _inTestMode || _status.value == TrainingStatus.ended)
      return;

    _isPaused = true;
    _timer?.cancel();
    _repository.stopPointPolling(_deviceNumber!);
    _repository.stopSpeedPolling(_deviceNumber!);
    _status.add(TrainingStatus.inTraining);
  }

  void resumeTraining() {
    if (!_isPaused || _inTestMode || _status.value == TrainingStatus.ended)
      return;

    _isPaused = false;
    _startTimer();
    if (_status.value == TrainingStatus.inTraining ||
        _status.value == TrainingStatus.ready) {
      _repository.startPointPolling(_deviceNumber!);
      _repository.startSpeedPolling(_deviceNumber!);
    }
    _status.add(TrainingStatus.inTraining);
  }

  Future<void> saveTraining() async {
    if (_endedAlready) return;
    _endedAlready = true;
    debugPrint("Saving training...");
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));

    final duration = _elapsedMs.value;

    Either<Failure, void> result = await _saveTraining(
      TrainingFencingSession(
        playerId: _trainee?.traineeId ?? '',
        targetMinutes: targetMinutes,
        targetPoints: targetPoints,
        achievedPoints: _points.value,
        durationMs: duration,
        endedBy: _endedBy,
        traineeData: _trainee,
        movements: _movementRecords,
        pointRecords: _pointRecordsList,
      ),
    );

    result.fold(
      (failure) {
        _endedAlready = false;
        inputState.add(
          ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () => inputState.add(ContentState()),
          ),
        );
      },
      (_) {
        inputState.add(ContentState());
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(
            content: Text('Training session saved'),
            backgroundColor: Colors.green,
          ),
        );

        _points.add(0);
        _pointIndicator.add(false);
        _pointRecordsList.clear();
        _movementRecords.clear();
        _pointRecords.add(null);
        _timerStarted = false;
        _elapsedMs.add(0);
      },
    );
  }

  Future<void> stopTraining({bool byDisconnect = false}) async {
    _timer?.cancel();
    _timer = null;
    _repository.stopPointPolling(_deviceNumber!);
    _repository.stopSpeedPolling(_deviceNumber!);

    final duration = _elapsedMs.value;
    if (byDisconnect) {
      _endedBy = 'disconnect';
    } else if (_isPaused) {
      _endedBy = 'paused';
    }

    _status
        .add(byDisconnect ? TrainingStatus.disconnected : TrainingStatus.ended);

    if (context != null) {
      await showDialog(
        context: context!,
        builder: (_) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                byDisconnect ? 'Connection Lost' : 'Training Finished',
                style: const TextStyle(color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context!).pop();
                  _endedAlready = false;
                  if (_isPaused && !byDisconnect) {
                    resumeTraining();
                  } else if (byDisconnect) {
                    _onDisconnected("Reconnect to continue", isManual: false);
                  }
                  inputState.add(ContentState());
                },
              ),
            ],
          ),
          content: Text(
            byDisconnect
                ? 'Device disconnected. Save, save and exit, or retry connection?'
                : _endedBy == 'paused'
                    ? 'Training paused. Save, save and exit, or exit without saving?'
                    : 'Training finished (${_endedBy == 'time' ? 'time limit reached' : _endedBy == 'points' ? 'points target achieved' : 'manual'}). Save or save and exit',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            if (byDisconnect)
              TextButton(
                onPressed: () async {
                  Navigator.of(context!).pop();
                  await connectToDevice(_deviceNumber!);
                  if (_status.value == TrainingStatus.inTraining ||
                      _status.value == TrainingStatus.ready) {
                    _repository.startPointPolling(_deviceNumber!);
                    _repository.startSpeedPolling(_deviceNumber!);
                    if (_isPaused) {
                      resumeTraining();
                    }
                  }
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await saveTraining();
                _status.add(TrainingStatus.waitingNFC);
                _isNFCPolling = true;
                _repository.startNfcPolling(_deviceNumber!);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await saveTraining();
                await _repository.endSession(_deviceNumber!);
                Navigator.of(context!).pop();
              },
              child: const Text(
                'Save and Exit',
                style: TextStyle(color: Colors.black),
              ),
            ),
            if (byDisconnect)
              TextButton(
                onPressed: () async {
                  Navigator.of(context!).pop();
                  await _repository.endSession(_deviceNumber!);
                  Navigator.of(context!).pop();
                  _endedAlready = false;
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      );
    }
  }

  Future<void> _onDisconnected(String why, {required bool isManual}) async {
    debugPrint("Disconnected: $why, isManual: $isManual");
    _status.add(TrainingStatus.disconnected);

    if (isManual) {
      return;
    }

    _repository.stopPointPolling(_deviceNumber!);
    _repository.stopSpeedPolling(_deviceNumber!);

    if (context != null) {
      await showDialog(
        context: context!,
        builder: (_) => AlertDialog(
          title: const Text(
            'Connection Lost',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Device disconnected: $why. Retry connection, save, or exit?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await connectToDevice(_deviceNumber!);
                if (_status.value == TrainingStatus.inTraining ||
                    _status.value == TrainingStatus.ready) {
                  _repository.startPointPolling(_deviceNumber!);
                  _repository.startSpeedPolling(_deviceNumber!);
                  if (_isPaused) {
                    resumeTraining();
                  }
                }
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await saveTraining();
                _status.add(TrainingStatus.waitingNFC);
                _isNFCPolling = true;
                _repository.startNfcPolling(_deviceNumber!);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await saveTraining();
                await _repository.endSession(_deviceNumber!);
                Navigator.of(context!).pop();
              },
              child: const Text(
                'Save and Exit',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context!).pop();
                await _repository.endSession(_deviceNumber!);
                Navigator.of(context!).pop();
                _endedAlready = false;
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<Either<Failure, void>> _saveTraining(
      TrainingFencingSession req) async {
    debugPrint("Saving training session: playerId=${req.playerId}, "
        "targetMinutes=${req.targetMinutes}, targetPoints=${req.targetPoints}, "
        "achievedPoints=${req.achievedPoints}, durationMs=${req.durationMs}, "
        "endedBy=${req.endedBy}, points=${req.pointRecords.length}, "
        "traineeData=${req.traineeData}, movements=${req.movements.length}, "
        "pointRecords=${req.pointRecords.length}");
    SaveTrainingFencingRequest trainingDataRequest = SaveTrainingFencingRequest(
        traineeId: req.traineeData?.traineeId ?? '',
        exerciseId: exercise.exerciseId,
        trainingData: req);
    return await _trainingUsecase.saveFencingTraining(trainingDataRequest);
  }

  Future<void> getSpeed() async {
    if (_deviceNumber != null && _status.value != TrainingStatus.disconnected) {
      await _repository.getSpeed(_deviceNumber!);
    }
  }

  Future<void> getPoint() async {
    if (_deviceNumber != null && _status.value != TrainingStatus.disconnected) {
      await _repository.getPoint(_deviceNumber!);
    }
  }

  @override
  void dispose() async {
    if (_deviceNumber != null) {
      await _repository.endSession(_deviceNumber!);
    }
    _timer?.cancel();
    _status.close();
    _playerData.close();
    _points.close();
    _timeLeftMs.close();
    _pointIndicator.close();
    _movementData.close();
    _pointRecords.close();
    _repository.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}
