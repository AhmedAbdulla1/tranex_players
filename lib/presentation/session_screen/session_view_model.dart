import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:tranex_users/app/app.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/app/extensions.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:dartz/dartz.dart';
import 'package:tranex_users/presentation/session_screen/ble_device_connector.dart';
import 'package:tranex_users/presentation/session_screen/widgets/custom_bar_chart.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/rxdart.dart';

class InTrainingViewModel extends InTrainingViewModelOutput {
  final StreamController<ChartData?> _dataStreamController =
      BehaviorSubject<ChartData?>();
  final StreamController<bool> _connectionStreamController =
      BehaviorSubject<bool>();
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final StreamController<String> _exerciseStreamController =
      BehaviorSubject<String>();
  final StreamController<bool> _isChargingStreamController =
      BehaviorSubject<bool>();
  final StreamController<int> _smallStreamController = BehaviorSubject<int>();
  final StreamController<int> _largeStreamController = BehaviorSubject<int>();
  final StreamController<int> _idleTimeStreamController =
      BehaviorSubject<int>();
  final StreamController<bool> _autoStartStreamController =
      BehaviorSubject<bool>();
  final StreamController<double> _batteryLevelStreamController =
      BehaviorSubject<double>();
  final StreamController<bool> _dataController = BehaviorSubject<bool>();
  final StreamController<SessionStatus> _statusStreamController =
      BehaviorSubject<SessionStatus>();

  final StreamController<double> _speedController = BehaviorSubject<double>();

  final TrainingUsecase _trainingUsecase = TrainingUsecase();

  final StreamController<FencingDataModel> fencingDataStreamController =
      BehaviorSubject();

  double avgEccSpeed = 0, avgConSpeed = 0, maxEccSpeed = 0, maxConSpeed = 0;
  List<double> eccentricForce = [], concentricForce = [];
  Data? previousData;

  // late int time;
  double weight = 0.0;
  late ExerciseData exercise;
  late TraineeData traineeData;
  late bool isFencing;
  double _internalTime = 0.0; // Internal time counter in seconds
  double _diskRadius = 0.15; // Default radius in meters

  // Analysis state
  List<double> _speedReadings = [];

  @override
  void start() {
    _bleConnector = BleDeviceConnector(ble: _ble, logMessage: (logMessage) {});
    Map<String, dynamic> exercise =
        jsonDecode(_appPreferences.getTraining()![0]);
    this.exercise = ExerciseData.fromJson(exercise);
    inputExercise.add(isFencing ? "Fencing" : this.exercise.exerciseName);
    weight = double.parse(_appPreferences.getTraining()![1]) / 1000;
    inputAutoStart
        .add(isFencing ? false : bool.parse(_appPreferences.getTraining()![2]));
    inputIdleTime
        .add(isFencing ? 0 : int.parse(_appPreferences.getTraining()![3]));
    _dataController.add(false);
    _internalTime = 0.0;
    _speedReadings.clear();
  }

  void sendOk() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'OK'.codeUnits);
  }

  void sendStart() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Start'.codeUnits);
  }

  void sendOnSave() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'OnSave'.codeUnits);
  }
  void sendEnd() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'end'.codeUnits);
  }

  void sendReconfirm() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Reconfirm'.codeUnits);
  }

  void sendPause() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Pause'.codeUnits);
  }

  @override
  Stream<SessionStatus> get statusStream => _statusStreamController.stream;

  @override
  Sink<SessionStatus> get inputStatus => _statusStreamController.sink;
  bool startListening = false;
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late BleDeviceConnector _bleConnector;
  late DiscoveredDevice _device;
  late QualifiedCharacteristic _rxCharacteristic;
  late Stream<List<int>> _notificationsStream;

  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  void setStartListening(bool value) {
    startListening = value;
    sendStart();
    // inputStatus.add(SessionStatus.fencing);
  }

  void connectToDevice(DiscoveredDevice device) async {
    try {
      _device = device;
      _rxCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(characteristicUuid),
        deviceId: _device.id,
      );
      await _bleConnector.connectAndWait(
        device.id,
        timeout: const Duration(seconds: 8),
        maxRetries: 3,
        initialBackoff: const Duration(milliseconds: 300),
      );

// سيب الجهاز يخلص الـ service discovery كويس
      await Future.delayed(const Duration(milliseconds: 400));

      // _bleConnector.connect(device.id);
      await _ble.requestMtu(deviceId: device.id, mtu: 250);
      _notificationsStream = _ble.subscribeToCharacteristic(_rxCharacteristic);
      inputConnection.add(true);
      inputStatus.add(SessionStatus.waitingRFID);
      inputState.add(ContentState());

      _monitorConnection(device);
      _notificationsStream.listen(
        (List<int> data) async {
          await _handleIncomingData(data);
        },
        onDone: () {
          _handleConnectionClosed(device);
        },
        onError: (error) {
          // Handle error
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleConnectionException(device, e);
    }
  }

  void _monitorConnection(DiscoveredDevice device) {}

  Future<void> _handleIncomingData(List<int> data) async {
    final message = utf8.decode(data);
    if (message.isNotEmpty) {
      try {
        final jsonData = jsonDecode(message);
        if (jsonData.containsKey('rfidUID')) {
          await checkTraineeExist(jsonData['rfidUID']);
        } else if (jsonData.containsKey('speed')) {
          print("Received data: $jsonData");
          startListening ? _processSpeedData(jsonData) : null;
        }
        else if (jsonData.containsKey('point')) {
          print("Received data: $jsonData");
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  List<double> eccSpeeds = [];
  List<double> conSpeeds = [];

  Sink get inputSpeed => _speedController.sink;

  Stream<double> get outSpeed => _speedController.stream;
  int? _lastDirection;
  final random = Random();

  void _processSpeedData(Map<String, dynamic> data) {
    double speed = DataModel._formatNum(data['speed']); // Speed in rps
    int dir = data['direction'] ?? 1; // Default direction if not provided
    double adjustedSpeed = speed * dir;
    // adjustedSpeed *= random.nextInt(5);
    _lastDirection ?? (_lastDirection = dir);
    inputSpeed.add(adjustedSpeed);
    _internalTime += 0.1; // 100ms interval

    WaveAnalysis? analysis = _analyzeSpeedData(
      speed: adjustedSpeed,
      time: _internalTime,
      weight: weight,
      radius: _diskRadius,
      direction: dir,
    );

    if (analysis != null) {
      // Add both Ecc and Con data for the same cycle (counter)
      inputData.add(
        ChartData(
          conForce: analysis.conForce ?? 0, // Con force
          eccForce: analysis.eccForce, // Ecc force
          index: counter,
        ),
      );

      _dataController.add(true);
    }
  }

  WaveAnalysis? _analyzeSpeedData({
    required double speed,
    required double time,
    required double weight,
    required double radius,
    required int direction,
  }) {
    if (radius == 0) {
      return null;
    }

    _speedReadings.add(speed);

    bool isDirectionChanged = _lastDirection != direction;

    if ((isDirectionChanged) && _speedReadings.length > 5) {
      bool hasMovement = _speedReadings.any((s) => s != 0);

      if (!hasMovement) {
        _speedReadings.clear();
        _lastDirection = direction;
        return null;
      }

      double peakSpeed =
      _speedReadings.reduce((a, b) => a.abs() > b.abs() ? a : b);
      int peakIndex = _speedReadings.indexOf(peakSpeed);
      double peakTime = time - (0.1 * (_speedReadings.length - peakIndex - 1));

      List<double> eccSpeedsForTrack =
      _speedReadings.sublist(0, peakIndex + 1); // Eccentric phase
      List<double> conSpeedsForTrack =
      _speedReadings.sublist(peakIndex + 1); // Concentric phase

      double avgEccSpeedForTrack = (eccSpeedsForTrack.isNotEmpty
          ? eccSpeedsForTrack.reduce((a, b) => a + b) /
          eccSpeedsForTrack.length
          : 0.0)
          .formatNum();
      double avgConSpeedForTrack = (conSpeedsForTrack.isNotEmpty
          ? conSpeedsForTrack.reduce((a, b) => a + b) /
          conSpeedsForTrack.length
          : 0.0)
          .formatNum();

      eccSpeeds.add(avgEccSpeedForTrack.abs());
      conSpeeds.add(avgConSpeedForTrack.abs());

      int numPointsEcc = peakIndex + 1;
      double deltaTimeEcc = numPointsEcc * 0.1;
      double omegaPeak = 2 * pi * peakSpeed.abs();
      double alphaEcc = deltaTimeEcc != 0 ? (omegaPeak - 0) / deltaTimeEcc : 0.0;

      double inertia = 0.5 * weight * pow(radius, 2);
      double torqueEcc = inertia * alphaEcc;
      double forceEcc = (torqueEcc / radius).formatNum();

      int numPointsCon = _speedReadings.length - peakIndex - 1;
      double deltaTimeCon = numPointsCon * 0.1;
      double alphaCon = deltaTimeCon != 0 ? (0 - omegaPeak) / deltaTimeCon : 0.0;
      double torqueCon = inertia * alphaCon;
      double forceCon = (torqueCon / radius).formatNum();

      _speedReadings.clear();

      eccentricForce.add(forceEcc.abs());
      concentricForce.add(forceCon.abs());

      counter++;

      _lastDirection = direction;

      return WaveAnalysis(
        eccForce: forceEcc.abs(),
        conForce: forceCon.abs(),
      );
    }

    _lastDirection = direction;
    return null;
  }

  void _handleConnectionClosed(DiscoveredDevice device) {
    inputState.add(
      ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: 'Connection to ${device.name} closed.',
        retryAction: () {
          MyApp.instance.navigatorKey.currentState?.pop();
        },
      ),
    );
    inputConnection.add(false);
  }

  void _handleConnectionException(DiscoveredDevice device, Object exception) {
    inputState.add(
      ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: 'Failed to connect: ${device.name}',
        retryAction: () {
          MyApp.instance.navigatorKey.currentState?.pop();
        },
      ),
    );
    inputConnection.add(false);
  }

  Future checkTraineeExist(String traineeId) async {
    inputStatus.add(SessionStatus.waitingForCheck);
    Either<Failure, TraineeData> request =
        await _trainingUsecase.checkTraineeExistence(traineeId);
    request.fold((l) {
      inputStatus.add(SessionStatus.errorRFID);
    }, (r) {
      inputStatus.add(SessionStatus.idle);
      traineeData = r;
      sendOk();
    });
  }

  int counter = 0;

  @override
  void dispose() async {
    await _bleConnector.disconnect();
    _bleConnector.dispose();
    _statusStreamController.close();
    _dataStreamController.close();
    _dataController.close();
    super.dispose();
  }

  void delete() {
    _dataStreamController.add(null);
    _dataController.add(false);
    eccentricForce = [];
    concentricForce = [];
    avgEccSpeed = 0;
    avgConSpeed = 0;
    maxEccSpeed = 0;
    maxConSpeed = 0;
    counter = 0;
    _internalTime = 0.0;
  }

  @override
  Sink get inputLargeWeight => _largeStreamController.sink;

  @override
  Sink get inputSmallWeight => _smallStreamController.sink;

  @override
  Sink get inputIsCharging => _isChargingStreamController.sink;

  @override
  Stream<bool> get outIsCharging => _isChargingStreamController.stream;

  @override
  Stream<int> get outLargeWeight => _largeStreamController.stream;

  @override
  Stream<int> get outSmallWeight => _smallStreamController.stream;

  @override
  Sink get inputAutoStart => _autoStartStreamController.sink;

  @override
  Sink get inputIdleTime => _idleTimeStreamController.sink;

  @override
  Stream<bool> get outAutoStart => _autoStartStreamController.stream;

  @override
  Stream<int> get outIdleTime => _idleTimeStreamController.stream;

  @override
  Sink<ChartData?> get inputData => _dataStreamController.sink;

  @override
  Stream<ChartData?> get outData => _dataStreamController.stream;

  @override
  Sink<bool> get inputConnection => _connectionStreamController.sink;

  @override
  Stream<bool> get outConnection => _connectionStreamController.stream;

  @override
  Sink get inputExercise => _exerciseStreamController.sink;

  @override
  Stream<String> get outExercise => _exerciseStreamController.stream;

  @override
  Sink get inputBatteryLevel => _batteryLevelStreamController.sink;

  @override
  Stream<double> get outBatteryLevel => _batteryLevelStreamController.stream;

  Data getData() {
    avgEccSpeed = eccSpeeds.isNotEmpty
        ? eccSpeeds.reduce((a, b) => a + b) / eccSpeeds.length
        : 0.0;
    maxEccSpeed =
        eccSpeeds.isNotEmpty ? eccSpeeds.reduce((a, b) => a > b ? a : b) : 0.0;
    avgConSpeed = conSpeeds.isNotEmpty
        ? conSpeeds.reduce((a, b) => a + b) / conSpeeds.length
        : 0.0;
    maxConSpeed =
        conSpeeds.isNotEmpty ? conSpeeds.reduce((a, b) => a > b ? a : b) : 0.0;
    return Data(
      date: DateTime.now(),
      weight: weight,
      eccForce: eccentricForce,
      conForce: concentricForce,
      maxConSpeed: maxConSpeed,
      maxEccSpeed: maxEccSpeed,
      avgConSpeed: avgConSpeed,
      avgEccSpeed: avgEccSpeed,
      timeBySeconds: timeBySeconds,
    );
  }

  int timeBySeconds = 0;

  Future<bool> save() async {
    inputState.add(
      LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState),
    );
    Either<Failure, void> request = await _trainingUsecase.addTrainingData(
      AddTrainingDataInput(
        traineeId: traineeData.traineeId.toString(),
        exerciseId: exercise.exerciseId,
        numberOfSets: counter,
        conForce: concentricForce,
        eccForce: eccentricForce,
        timeBySeconds: timeBySeconds,
        maxEccSpeed: maxEccSpeed,
        avgConSpeed: avgConSpeed,
        avgEccSpeed: avgEccSpeed,
        maxConSpeed: maxConSpeed,
        weight: weight,
      ),
    );
    return request.fold((l) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: l.message,
        retryAction: () {
          inputState.add(ContentState());
        },
      ));
      return false;
    }, (r) {
      inputState.add(ContentState());
      _dataStreamController.add(null);
      _dataController.add(false);
      return true;
    });
  }

  @override
  Stream<bool> get data => _dataController.stream;

  @override
  Future getPreviousAverage() async {
    inputState.add(
      LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState),
    );
    final result = await _trainingUsecase.getLastTrainingData(
      GetTrainingDataInput(
        traineeId: traineeData.traineeId,
        exerciseId: exercise.exerciseId,
      ),
    );
    result.fold((l) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: l.message,
        retryAction: () {
          inputState.add(ContentState());
        },
      ));
    }, (r) {
      previousData = r;
      inputState.add(ContentState());
    });
  }

  @override
  Sink get inputFencingData => fencingDataStreamController.sink;

  @override
  Stream<FencingDataModel> get outFencingData =>
      fencingDataStreamController.stream;
}

abstract class InTrainingViewModelInput extends BaseViewModel {
  getPreviousAverage();

  Sink<bool> get inputConnection;

  Sink<SessionStatus> get inputStatus;

  Sink get inputAutoStart;

  Sink get inputIsCharging;

  Sink get inputIdleTime;

  Sink get inputExercise;

  Sink get inputSmallWeight;

  Sink get inputBatteryLevel;

  Sink get inputLargeWeight;

  Sink get inputFencingData;

  Sink<ChartData?> get inputData;
}

abstract class InTrainingViewModelOutput extends InTrainingViewModelInput {
  Stream<ChartData?> get outData;

  Stream<bool> get outConnection;

  Stream<FencingDataModel> get outFencingData;

  Stream<SessionStatus> get statusStream;

  Stream<int> get outSmallWeight;

  Stream<bool> get outIsCharging;

  Stream<int> get outLargeWeight;

  Stream<int> get outIdleTime;

  Stream<bool> get outAutoStart;

  Stream<double> get outBatteryLevel;

  Stream<String> get outExercise;

  Stream<bool> get data;
}

class DataModel {
  static double _formatNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) {
      return double.parse(value.toStringAsFixed(2));
    }
    return 0.0;
  }
}

class FencingDataModel {
  double speed;
  int direction;

  FencingDataModel({
    required this.speed,
    required this.direction,
  });

  factory FencingDataModel.fromJson(Map<String, dynamic> data) {
    return FencingDataModel(
      speed: DataModel._formatNum(data["speed1"]),
      direction: data["direction1"] is int ? data["direction1"] : 0,
    );
  }
}

class WaveAnalysis {
  final double eccForce; // Ecc force
  final double conForce; // Con force

  WaveAnalysis({
    required this.eccForce,
    required this.conForce,
  });
}

enum SessionStatus {
  idle,
  waitingRFID,
  waitingForCheck,
  errorRFID,
  finished,
  analyzing,
  fencing
}

class PointRecord {
  final int playerId;
  final int timeInMs;

  PointRecord({
    required this.playerId,
    required this.timeInMs,
  });

  String get formattedTime {
    final minutes = (timeInMs ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((timeInMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    final milliseconds = (timeInMs % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$milliseconds';
  }
}

class PlayerData {
  final double speed;
  final int direction;
  final int timeInMs;

  PlayerData({
    required this.speed,
    required this.direction,
    required this.timeInMs,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json, int timeInMs) {
    return PlayerData(
      speed: (json['speed'] as num).toDouble(),
      direction: (json['direction'] as num).toInt(),
      timeInMs: timeInMs,
    );
  }
}

class PlayerInfo {
  String name;
  int traineeId;
  int points;
  List<PlayerData> matchData;
  List<PointRecord> pointRecords;

  PlayerInfo({
    required this.name,
    required this.traineeId,
    required this.points,
    required this.matchData,
    required this.pointRecords,
  });
}
