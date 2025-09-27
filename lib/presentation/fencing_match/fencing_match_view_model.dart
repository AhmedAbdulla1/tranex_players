import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:rxdart/rxdart.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/usecase/fencing_usecase.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/wifi_scanner/connection_repo.dart';
import 'package:tranex_users/presentation/wifi_scanner/device_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerInfo {
  TraineeData playerData;
  List<PlayerMovementData> matchData;
  List<PointDataEntity> pointRecords;

  PlayerInfo({
    required this.playerData,
    required this.matchData,
    required this.pointRecords,
  });
}

enum MatchStatus {
  waitingBluetoothPlayer1,
  waitingBluetoothPlayer2,
  waitingNFC1,
  waitingNFC2,
  checkingNFC1,
  checkingNFC2,
  errorNFC1,
  errorNFC2,
  paused,
  inMatch,
  ended,
  disconnected,
}

class FencingMatchViewModel extends BaseViewModel
    implements FencingMatchViewModelInput, FencingMatchViewModelOutput {
  final TrainingUsecase _trainingUsecase = TrainingUsecase();
  final FencingUsecase _fencingUsecase = FencingUsecase();
  final ConnectionRepository _repository = ConnectionRepository();
  BuildContext? context;
  double lastPlayer1Speed = 0;
  double lastPlayer2Speed = 0;
  DateTime? lastPointTimePlayer1;
  DateTime? lastPointTimePlayer2;
  static const Duration _pointWindow = Duration(milliseconds: 100);
  bool _isDisposing = false;

  // Stream Controllers
  final _matchStatusController =
      BehaviorSubject<MatchStatus>.seeded(MatchStatus.waitingBluetoothPlayer1);
  final StreamController<TraineeData> _player1DataController =
      BehaviorSubject<TraineeData>();
  final StreamController<TraineeData> _player2DataController =
      BehaviorSubject<TraineeData>();
  final StreamController<PlayerMovementData> _player1MatchDataController =
      BehaviorSubject<PlayerMovementData>();
  final StreamController<PlayerMovementData> _player2MatchDataController =
      BehaviorSubject<PlayerMovementData>();
  final StreamController<PointDataEntity?> _player1PointsController =
      BehaviorSubject<PointDataEntity?>();
  final StreamController<PointDataEntity?> _player2PointsController =
      BehaviorSubject<PointDataEntity?>();

  // Player data
  late PlayerInfo player1Info;
  late PlayerInfo player2Info;

  // Match state
  MatchStatus currentStatus = MatchStatus.waitingBluetoothPlayer1;
  int _currentMatchTimeInMs = 0;
  int? _deviceNumber1;
  int? _deviceNumber2;
  bool _matchStarted = false;

  FencingMatchViewModel() {
    _repository.status.listen((status) {
      _onDeviceData(status);
    });
  }

  // Streams
  @override
  Stream<MatchStatus> get outputMatchStatus => _matchStatusController.stream;

  @override
  Stream<TraineeData> get outputPlayer1Data => _player1DataController.stream;

  @override
  Stream<TraineeData> get outputPlayer2Data => _player2DataController.stream;

  @override
  Stream<PlayerMovementData> get outputPlayer1MatchData =>
      _player1MatchDataController.stream;

  @override
  Stream<PlayerMovementData> get outputPlayer2MatchData =>
      _player2MatchDataController.stream;

  @override
  Stream<PointDataEntity> get outputPlayer1Points =>
      _player1PointsController.stream
          .map((event) => event ?? PointDataEntity(timeInMs: -1, speed: 0));

  @override
  Stream<PointDataEntity> get outputPlayer2Points =>
      _player2PointsController.stream
          .map((event) => event ?? PointDataEntity(timeInMs: -1, speed: 0));

  // Sinks
  @override
  Sink get inputMatchStatus => _matchStatusController.sink;

  @override
  Sink get inputPlayer1Data => _player1DataController.sink;

  @override
  Sink get inputPlayer2Data => _player2DataController.sink;

  @override
  Sink get inputPlayer1MatchData => _player1MatchDataController.sink;

  @override
  Sink get inputPlayer2MatchData => _player2MatchDataController.sink;

  @override
  Sink get inputPlayer1Points => _player1PointsController.sink;

  @override
  Sink get inputPlayer2Points => _player2PointsController.sink;

  // Direct data access
  PlayerInfo getPlayer1Info() => player1Info;

  PlayerInfo getPlayer2Info() => player2Info;

  @override
  void start() {
    WakelockPlus.enable();
    inputMatchStatus.add(MatchStatus.waitingBluetoothPlayer1);
    player1Info = PlayerInfo(
      playerData: TraineeData(
          exercise: {},
          isActive: false,
          isFencer: false,
          traineeName: '',
          photo: '',
          traineeId: ''),
      matchData: [PlayerMovementData(speed: 0, direction: 0, timeInMs: 0)],
      pointRecords: [],
    );
    player2Info = PlayerInfo(
      playerData: TraineeData(
          exercise: {},
          isActive: false,
          isFencer: false,
          traineeName: '',
          photo: '',
          traineeId: ''),
      matchData: [PlayerMovementData(speed: 0, direction: 0, timeInMs: 0)],
      pointRecords: [],
    );
  }

  @override
  void chooseDevice(BuildContext context) async {
    this.context = context;
    try {
      final deviceNumber = await DeviceScanner.scanDevices(context);
      if (deviceNumber != 0) {
        connectToDevice(deviceNumber);
      } else {
        if (context.mounted) {
          inputState.add(ContentState());
          inputState.add(ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: "No devices found",
            retryAction: () => chooseDevice(context),
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: "Error scanning devices: $e",
          retryAction: () => chooseDevice(context),
        ));
      }
    }
  }

  @override
  void connectToDevice(int deviceNumber) async {
    if (_deviceNumber1 != null && _deviceNumber2 != null) {
      if (context?.mounted ?? false) {
        inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: "Already connected to two devices",
          retryAction: () => inputState.add(ContentState()),
        ));
      }
      return;
    }

    try {
      inputState.add(LoadingState(
          stateRenderType: StateRenderType.fullScreenLoadingState));
      await _repository.connect(deviceNumber, "match");
      if (_deviceNumber1 == null) {
        _deviceNumber1 = deviceNumber;
        currentStatus = MatchStatus.waitingBluetoothPlayer2;
        inputMatchStatus.add(currentStatus);
        if (context?.mounted ?? false) {
          chooseDevice(context!); // Scan for second device
        }
      } else {
        _deviceNumber2 = deviceNumber;
        currentStatus = MatchStatus.waitingNFC1;
        inputMatchStatus.add(currentStatus);
        startNfcPollingForBothDevices(); // Start NFC polling for both devices
      }
      inputState.add(ContentState());
    } catch (e) {
      if (context?.mounted ?? false) {
        inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: "Connection error for device $deviceNumber: $e",
          retryAction: () => connectToDevice(deviceNumber),
        ));
      }
      currentStatus = _deviceNumber1 == null
          ? MatchStatus.waitingBluetoothPlayer1
          : MatchStatus.waitingBluetoothPlayer2;
      inputMatchStatus.add(currentStatus);
    }
  }

  void startNfcPollingForBothDevices() {
    if (_deviceNumber1 != null && _deviceNumber2 != null) {
      _repository.startNfcPolling(_deviceNumber1!);
      _repository.startNfcPolling(_deviceNumber2!);
    }
  }

  void _onDeviceData(ConnectionStatus status) async {
    if (_isDisposing) return;

    if (status.deviceNumber != _deviceNumber1 &&
        status.deviceNumber != _deviceNumber2) {
      return; // Ignore responses from other devices
    }

    final playerId = status.deviceNumber == _deviceNumber1 ? 1 : 2;

    // Handle NFC
    if (status.state == ConnectionState.nfcSuccess && status.nfcUid != null) {
      if ((playerId == 1 &&
              (currentStatus == MatchStatus.waitingNFC1 ||
                  currentStatus == MatchStatus.errorNFC1)) ||
          (playerId == 2 &&
              (currentStatus == MatchStatus.waitingNFC1 ||
                  currentStatus == MatchStatus.waitingNFC2 ||
                  currentStatus == MatchStatus.errorNFC2))) {
        currentStatus =
            playerId == 1 ? MatchStatus.checkingNFC1 : MatchStatus.checkingNFC2;
        inputMatchStatus.add(currentStatus);
        await checkNFC(status.nfcUid!, status.deviceNumber);
      }
    } else if (status.state == ConnectionState.nfcError) {
      currentStatus =
          playerId == 1 ? MatchStatus.errorNFC1 : MatchStatus.errorNFC2;
      inputMatchStatus.add(currentStatus);
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: status.message ?? "NFC Error",
        retryAction: () => inputState.add(ContentState()),
      ));
    } else if (status.state == ConnectionState.disconnected) {
      _onDisconnected(status.deviceNumber, status.message ?? "Disconnected");
    }

    // Handle Point and Speed
    if (status.state == ConnectionState.connected &&
        currentStatus == MatchStatus.inMatch) {
      if (status.speed != null) {
        final playerData = PlayerMovementData(
          speed: status.speed!,
          direction: status.direction ?? 1,
          timeInMs: _currentMatchTimeInMs,
        );
        if (playerId == 1) {
          lastPlayer1Speed = status.speed!;
          _addMatchData(player1Info.matchData, playerData);
          if (!_player1MatchDataController.isClosed) {
            inputPlayer1MatchData.add(playerData);
          }
        } else {
          lastPlayer2Speed = status.speed!;
          _addMatchData(player2Info.matchData, playerData);
          if (!_player2MatchDataController.isClosed) {
            inputPlayer2MatchData.add(playerData);
          }
        }
      }

      if (status.point != null && status.point!) {
        final now = DateTime.now();
        if (playerId == 1) {
          lastPointTimePlayer1 = now;
          if (lastPointTimePlayer2 != null &&
              now.difference(lastPointTimePlayer2!) <= _pointWindow) {
            addPointManually(1);
            addPointManually(2);
          } else {
            addPointManually(1);
          }
        } else {
          lastPointTimePlayer2 = now;
          if (lastPointTimePlayer1 != null &&
              now.difference(lastPointTimePlayer1!) <= _pointWindow) {
            addPointManually(1);
            addPointManually(2);
          } else {
            addPointManually(2);
          }
        }
      }
    }
  }

  void _addMatchData(
      List<PlayerMovementData> matchData, PlayerMovementData newData) {
    if (matchData.length >= 2) {
      final last = matchData.last;
      final secondLast = matchData[matchData.length - 2];

      if (last.speed == 0.0 &&
          secondLast.speed == 0.0 &&
          newData.speed == 0.0) {
        matchData.removeLast();
        matchData.add(newData);
      } else {
        matchData.add(newData);
      }
    } else {
      matchData.add(newData);
    }
  }

  @override
  Future<bool> checkNFC(String rfidUID, int deviceNumber) async {
    if ((currentStatus != MatchStatus.waitingNFC1 &&
            currentStatus != MatchStatus.errorNFC1 &&
            currentStatus != MatchStatus.checkingNFC1 &&
            deviceNumber == _deviceNumber1) ||
        (currentStatus != MatchStatus.waitingNFC1 &&
            currentStatus != MatchStatus.waitingNFC2 &&
            currentStatus != MatchStatus.errorNFC2 &&
            currentStatus != MatchStatus.checkingNFC2 &&
            deviceNumber == _deviceNumber2)) {
      return false;
    }

    Either<Failure, TraineeData> request =
        await _trainingUsecase.checkTraineeExistence(rfidUID.trim());
    return request.fold(
      (failure) {
        final playerId = deviceNumber == _deviceNumber1 ? 1 : 2;
        currentStatus =
            playerId == 1 ? MatchStatus.errorNFC1 : MatchStatus.errorNFC2;
        inputMatchStatus.add(currentStatus);
        if (failure.code == 10) {
          inputState.add(ContentState());
        } else {
          inputState.add(ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () {
              if (context?.mounted ?? false) {
                inputState.add(ContentState());
                _repository.startNfcPolling(deviceNumber);
              }
            },
          ));
        }
        _repository.confirmNfc(deviceNumber, false);
        return false;
      },
      (traineeData) async {
        if (!traineeData.isFencer) {
          inputState.add(ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: "The player is not a fencer",
            retryAction: () => inputState.add(ContentState()),
          ));
          final playerId = deviceNumber == _deviceNumber1 ? 1 : 2;
          currentStatus =
              playerId == 1 ? MatchStatus.errorNFC1 : MatchStatus.errorNFC2;
          inputMatchStatus.add(currentStatus);
          await _repository.confirmNfc(deviceNumber, false);
          return false;
        }

        final playerId = deviceNumber == _deviceNumber1 ? 1 : 2;
        if (playerId == 1) {
          player1Info.playerData = traineeData;
          if (!_player1DataController.isClosed) {
            inputPlayer1Data.add(traineeData);
          }
          currentStatus = MatchStatus.waitingNFC2;
          await _repository.confirmNfc(deviceNumber, true);
          await _repository.start(deviceNumber);
        } else {
          player2Info.playerData = traineeData;
          if (!_player2DataController.isClosed) {
            inputPlayer2Data.add(traineeData);
          }
          currentStatus = MatchStatus.paused;
          await _repository.confirmNfc(deviceNumber, true);
          await _repository.start(deviceNumber);
        }
        inputMatchStatus.add(currentStatus);
        inputState.add(ContentState());
        return true;
      },
    );
  }

  @override
  void startMatch() {
    if (_deviceNumber1 == null || _deviceNumber2 == null) return;
    _repository.start(_deviceNumber1!);
    _repository.start(_deviceNumber2!);
    // note: this for get the points from the device during the match
    // _repository.startPointPolling(_deviceNumber1!);
    // _repository.startPointPolling(_deviceNumber2!);
    _repository.startSpeedPolling(_deviceNumber1!);
    _repository.startSpeedPolling(_deviceNumber2!);
    _matchStarted = true;
    currentStatus = MatchStatus.inMatch;
    inputMatchStatus.add(currentStatus);
    _startTimer();
  }

  @override
  void resumeMatch() {
    if (_deviceNumber1 == null || _deviceNumber2 == null) return;
    _repository.start(_deviceNumber1!);
    _repository.start(_deviceNumber2!);
    // note: this for get the points from the device during the match
    // _repository.startPointPolling(_deviceNumber1!);
    // _repository.startPointPolling(_deviceNumber2!);
    _repository.startSpeedPolling(_deviceNumber1!);
    _repository.startSpeedPolling(_deviceNumber2!);
    currentStatus = MatchStatus.inMatch;
    inputMatchStatus.add(currentStatus);
    _startTimer();
  }

  @override
  void sendOk() {
    if (_deviceNumber1 == null || _deviceNumber2 == null) return;
    _repository.start(_deviceNumber1!);
    _repository.start(_deviceNumber2!);
    currentStatus = MatchStatus.paused;
    inputMatchStatus.add(currentStatus);
  }

  @override
  void sendPause() {
    if (_deviceNumber1 == null || _deviceNumber2 == null) return;
    _repository.stop(_deviceNumber1!);
    _repository.stop(_deviceNumber2!);

    // _repository.stopPointPolling(_deviceNumber1!);
    // _repository.stopPointPolling(_deviceNumber2!);
    _repository.stopSpeedPolling(_deviceNumber1!);
    _repository.stopSpeedPolling(_deviceNumber2!);
    currentStatus = MatchStatus.paused;
    inputMatchStatus.add(currentStatus);
  }

  @override
  void endMatch() async {
    if (_deviceNumber1 == null || _deviceNumber2 == null) return;
    if (_isDisposing) return;

    _stopTimer();
    // _repository.stopPointPolling(_deviceNumber1!);
    // _repository.stopPointPolling(_deviceNumber2!);
    _repository.stopSpeedPolling(_deviceNumber1!);
    _repository.stopSpeedPolling(_deviceNumber2!);
    currentStatus = MatchStatus.ended;
    inputMatchStatus.add(currentStatus);
  }

  Future<bool> saveMatchData() async {
    if (context?.mounted ?? false) {
      inputState.add(LoadingState(
          stateRenderType: StateRenderType.fullScreenLoadingState));
    }
    Either<Failure, void> result = await _fencingUsecase.addMatch(
      MatchRequest(
        player1Id: player1Info.playerData.traineeId,
        player2Id: player2Info.playerData.traineeId,
        durationMs: _currentMatchTimeInMs,
        player1MatchData: player1Info.matchData,
        player1PointRecords: player1Info.pointRecords,
        player2MatchData: player2Info.matchData,
        player2PointRecords: player2Info.pointRecords,
      ),
    );
    return result.fold(
      (failure) {
        if (context?.mounted ?? false) {
          inputState.add(ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () => inputState.add(ContentState()),
          ));
        }
        return false;
      },
      (success) {
        if (context?.mounted ?? false) {
          inputState.add(ContentState());
        }
        return true;
      },
    );
  }

  @override
  Future<bool?> saveMatch() async {
    bool? result;
    if (_isDisposing) return null;
    if (context?.mounted ?? false) {
      result = await showDialog(
        context: context!,
        builder: (_) => AlertDialog(
          title: const Text(
            'Match Finished',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Match finished. Save or save and exit?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool saved = await saveMatchData();
                Navigator.of(context!).pop(saved); // close dialog
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                bool saved = await saveMatchData();
                await _repository.endSession(_deviceNumber1!);
                await _repository.endSession(_deviceNumber2!);
                Navigator.of(context!).pop(saved); // close dialog
                Navigator.of(context!).pop(); // pop screen
              },
              child: const Text(
                'Save and Exit',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
      if (result == null) return null;
    }
    if (!result!) return result;

    if (_deviceNumber1 != null && _deviceNumber2 != null) {
      await _repository.resetFlags(_deviceNumber1!);
      await _repository.resetFlags(_deviceNumber2!);
    }

    player1Info.pointRecords.clear();
    player2Info.pointRecords.clear();
    player1Info.matchData.clear();
    player2Info.matchData.clear();
    player1Info.matchData
        .add(PlayerMovementData(speed: 0, direction: 0, timeInMs: 0));
    player2Info.matchData
        .add(PlayerMovementData(speed: 0, direction: 0, timeInMs: 0));
    _currentMatchTimeInMs = 0;
    _matchStarted = false;
    lastPlayer1Speed = 0;
    lastPlayer2Speed = 0;
    lastPointTimePlayer1 = null;
    lastPointTimePlayer2 = null;

    currentStatus = MatchStatus.waitingNFC1;
    inputMatchStatus.add(currentStatus);

    if (_deviceNumber1 != null && _deviceNumber2 != null) {
      startNfcPollingForBothDevices();
    }

    if (context?.mounted ?? false) {
      ScaffoldMessenger.of(context!).showSnackBar(
        const SnackBar(
          content: Text('Match session saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
    return result;
  }

  @override
  void addPointManually(int playerId) {
    sendPause(); // This already stops point and speed polling
    final pointRecord = PointDataEntity(
      timeInMs: _currentMatchTimeInMs,
      speed: playerId == 1 ? lastPlayer1Speed : lastPlayer2Speed,
    );
    if (playerId == 1) {
      player1Info.pointRecords.add(pointRecord);
      if (!_player1PointsController.isClosed) {
        inputPlayer1Points.add(pointRecord);
      }
    } else {
      player2Info.pointRecords.add(pointRecord);
      if (!_player2PointsController.isClosed) {
        inputPlayer2Points.add(pointRecord);
      }
    }
  }

  @override
  void subtractPointManually(int playerId) {
    if (playerId == 1 && player1Info.pointRecords.isNotEmpty) {
      player1Info.pointRecords.removeLast();
      if (!_player1PointsController.isClosed) {
        inputPlayer1Points.add(player1Info.pointRecords.lastOrNull);
      }
    } else if (playerId == 2 && player2Info.pointRecords.isNotEmpty) {
      player2Info.pointRecords.removeLast();
      if (!_player2PointsController.isClosed) {
        inputPlayer2Points.add(player2Info.pointRecords.lastOrNull);
      }
    }
  }

  void _startTimer() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (currentStatus != MatchStatus.inMatch || _isDisposing) {
        timer.cancel();
        return;
      }
      _currentMatchTimeInMs += 200;
    });
  }

  void _stopTimer() {
    // Timer is handled by periodic cancellation in _startTimer
  }

  void _onDisconnected(int deviceNumber, String reason) {
    currentStatus = MatchStatus.disconnected;
    inputMatchStatus.add(currentStatus);
    if (context?.mounted ?? false) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: "Device $deviceNumber disconnected: $reason",
        retryAction: () => chooseDevice(context!),
      ));
    }
  }

  void updateMatchTime(int timeInMs) {
    _currentMatchTimeInMs = timeInMs;
  }

  @override
  void dispose() async {
    _isDisposing = true;
    if (_deviceNumber1 != null) {
      await _repository.endSession(_deviceNumber1!);
    }
    if (_deviceNumber2 != null) {
      await _repository.endSession(_deviceNumber2!);
    }
    _matchStatusController.close();
    _player1DataController.close();
    _player2DataController.close();
    _player1MatchDataController.close();
    _player2MatchDataController.close();
    _player1PointsController.close();
    _player2PointsController.close();
    _repository.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}

abstract class FencingMatchViewModelInput {
  Sink get inputMatchStatus;

  Sink get inputPlayer1Data;

  Sink get inputPlayer2Data;

  Sink get inputPlayer1MatchData;

  Sink get inputPlayer2MatchData;

  Sink get inputPlayer1Points;

  Sink get inputPlayer2Points;

  void chooseDevice(BuildContext context);

  void connectToDevice(int deviceNumber);

  Future<bool> checkNFC(String rfidUID, int deviceNumber);

  void startMatch();

  void resumeMatch();

  void endMatch();

  Future<bool?> saveMatch();

  void addPointManually(int playerId);

  void subtractPointManually(int playerId);

  void sendPause();

  void sendOk();
}

abstract class FencingMatchViewModelOutput {
  Stream<MatchStatus> get outputMatchStatus;

  Stream<PlayerMovementData> get outputPlayer1MatchData;

  Stream<PlayerMovementData> get outputPlayer2MatchData;

  Stream<PointDataEntity> get outputPlayer1Points;

  Stream<PointDataEntity> get outputPlayer2Points;

  Stream<TraineeData> get outputPlayer1Data;

  Stream<TraineeData> get outputPlayer2Data;
}
