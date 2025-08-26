import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:firesport_users/app/app.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/usecase/fencing_usecase.dart';
import 'package:firesport_users/domain/usecase/training_data_usecase.dart';
import 'package:firesport_users/presentation/base/base_view_model.dart';
import 'package:firesport_users/presentation/common/state_render/state_render.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/session_screen/ble_device_connector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/rxdart.dart';

// class PointRecord {
//   final int playerId;
//   final int timeInMs; // تغيير من timeInSeconds لـ timeInMs
//   final double speed;
//
//   PointRecord({
//     required this.speed,
//     required this.playerId,
//     required this.timeInMs,
//   });
//
//   String get formattedTime {
//     final minutes = (timeInMs ~/ 60000).toString().padLeft(2, '0');
//     final seconds = ((timeInMs % 60000) ~/ 1000).toString().padLeft(2, '0');
//     final milliseconds = (timeInMs % 1000).toString().padLeft(3, '0');
//     return '$minutes:$seconds.$milliseconds';
//   }
// }

// class MatchData {
//   final double speed;
//   final int direction;
//   final int timeInMs;
//
//   MatchData({
//     required this.speed,
//     required this.direction,
//     required this.timeInMs,
//   });
//
//   factory MatchData.fromJson(Map<String, dynamic> json, int timeInMs) {
//     int direction = json['direction'] as int;
//     return MatchData(
//       speed: (json['speed'] as num).toDouble(),
//       direction: direction,
//       timeInMs: timeInMs,
//     );
//   }
// }

class PlayerInfo {
  TraineeData playerData;
  List<MatchDataEntity> matchData;
  List<PointDataEntity> pointRecords;

  PlayerInfo({
    required this.playerData,
    required this.matchData,
    required this.pointRecords,
  });
}

enum MatchStatus {
  waitingNFC1,
  waitingNFC2,
  errorNFC1,
  errorNFC2,
  paused,
  inMatch,
  ended,
  waitingForCheck1,
  waitingForCheck2
  // This state should be set before calling _trainingUsecase.checkTraineeExistence in the checkNFC function.
}

abstract class FencingMatchViewModelInput {
  Sink get inputMatchStatus;

  Sink get inputPlayer1Data;

  Sink get inputPlayer2Data;

  Sink get inputPlayer1MatchData;

  Sink get inputPlayer2MatchData;

  Sink get inputPlayer2Points;

  Sink get inputPlayer1Points;

  void connectToDevice(DiscoveredDevice device);

  // void checkNFC(String rfidUID);

  void startMatch();

  void resumeMatch();

  void endMatch();

  void saveMatchData();

  void addPointManually(int playerId);
}

abstract class FencingMatchViewModelOutput {
  Stream<MatchStatus> get outputMatchStatus;

  Stream<MatchDataEntity> get outputPlayer1MatchData;

  Stream<MatchDataEntity> get outputPlayer2MatchData;

  Stream<PointDataEntity> get outputPlayer1Points;

  Stream<PointDataEntity> get outputPlayer2Points;

  Stream<TraineeData> get outputPlayer1Data;

  Stream<TraineeData> get outputPlayer2Data;
}

class FencingMatchViewModel extends BaseViewModel
    implements FencingMatchViewModelInput, FencingMatchViewModelOutput {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late QualifiedCharacteristic _txCharacteristic;
  late QualifiedCharacteristic _rxCharacteristic;
  late DiscoveredDevice device;
  late BuildContext context;
  final TrainingUsecase _trainingUsecase = TrainingUsecase();
  late BleDeviceConnector _bleConnector;
  double lastPlayer1Speed = 0;
  double lastPlayer2Speed = 0;

  // Stream Controllers
  final StreamController<MatchStatus> _matchStatusController =
      StreamController.broadcast();
  final StreamController<TraineeData> _player1DataController =
      BehaviorSubject<TraineeData>();
  final StreamController<TraineeData> _player2DataController =
      BehaviorSubject<TraineeData>();
  final StreamController<MatchDataEntity> _player1MatchDataController =
      StreamController.broadcast();
  final StreamController<MatchDataEntity> _player2MatchDataController =
      StreamController.broadcast();

  final StreamController<PointDataEntity?> _player1PointsController =
      StreamController.broadcast();
  final StreamController<PointDataEntity?> _player2PointsController =
      StreamController.broadcast();

  // بيانات اللاعبين
  late PlayerInfo player1Info;
  late PlayerInfo player2Info;

  // حالة المباراة
  MatchStatus currentStatus = MatchStatus.waitingNFC1;

  // متغير لتخزين وقت المباراة بالمللي ثانية
  int _currentMatchTimeInMs = 0;

  FencingMatchViewModel() {
    _matchStatusController.add(currentStatus);
  }

  // Streams
  @override
  Stream<MatchStatus> get outputMatchStatus => _matchStatusController.stream;

  @override
  Stream<TraineeData> get outputPlayer1Data => _player1DataController.stream;

  @override
  Stream<TraineeData> get outputPlayer2Data => _player2DataController.stream;

  // Sinks
  @override
  Sink get inputMatchStatus => _matchStatusController.sink;

  @override
  Sink get inputPlayer1Data => _player1DataController.sink;

  @override
  Sink get inputPlayer2Data => _player2DataController.sink;

  // دوال للوصول المباشر للبيانات
  PlayerInfo getPlayer1Info() => player1Info;

  PlayerInfo getPlayer2Info() => player2Info;

  @override
  void start() {
    _bleConnector = BleDeviceConnector(
      ble: _ble,
      logMessage: (logMessage) {
        print(logMessage);
      },
    );
    // inputMatchStatus.add(MatchStatus.waitingNFC1);
    // checkNFC('00000000000000000000000000000000').then((value) {
    //   checkNFC('00000000000000000000000000000000');
    // });
    // simulateRandomMatchData();
    // todo remove comment
    connectToDevice(device);

    player1Info = PlayerInfo(
      playerData: TraineeData(
          isFencer: false,
          traineeName: '',
          photo: '',
          traineeId: 0),
      matchData: [MatchDataEntity(speed: 0, direction: 0, timeInMs: 0)],
      pointRecords: [],
    );
    player2Info = PlayerInfo(
      playerData: TraineeData(
          isFencer: false,
          traineeName: '',
          photo: '',
          traineeId: 0),
      matchData: [MatchDataEntity(speed: 0, direction: 0, timeInMs: 0)],
      pointRecords: [],
    );
  }

// افتراض إن MatchData و MatchStatus و الكلاسات الأخرى موجودة في الكود بتاعك
  void simulateRandomMatchData() {
    // استخدام Timer.periodic لتوليد بيانات كل 300 ميلي ثانية
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (currentStatus == MatchStatus.inMatch) {
        // توليد بيانات عشوائية للاعب 1
        final random = Random();
        final speed1 = random.nextDouble() * 2; // سرعة عشوائية بين 0 و 10
        final direction1 = random.nextBool() ? 1 : -1; // اتجاه عشوائي (1 أو -1)

        final player1Data = MatchDataEntity.fromBluetooth({
          'speed': speed1,
          'direction': direction1,
        }, _currentMatchTimeInMs);

        // إضافة البيانات للـ stream بتاع لاعب 1
        inputPlayer1MatchData.add(player1Data);
        _addMatchData(player1Info.matchData, player1Data);

        // توليد بيانات عشوائية للاعب 2
        final speed2 = random.nextDouble() * 2; // سرعة عشوائية بين 0 و 10
        final direction2 = random.nextBool() ? 1 : -1; // اتجاه عشوائي (1 أو -1)

        final player2Data = MatchDataEntity.fromBluetooth({
          'speed': speed2,
          'direction': direction2,
        }, _currentMatchTimeInMs);
        lastPlayer1Speed = speed1;
        lastPlayer2Speed = speed2;
        // إضافة البيانات للـ stream بتاع لاعب 2
        inputPlayer2MatchData.add(player2Data);
        _addMatchData(player2Info.matchData, player2Data);
      }
    });
  }

  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String txCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String rxCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  void connectToDevice(DiscoveredDevice device) async {
    print("connectToDevice");
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    try {
      this.device = device;

      _txCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(txCharacteristicUuid),
        deviceId: this.device.id,
      );

      _rxCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(rxCharacteristicUuid),
        deviceId: this.device.id,
      );

      print("Connecting to device: ${device.name}");
      await _bleConnector.connect(device.id);

      final mtu = await _ble.requestMtu(deviceId: device.id, mtu: 250);
      print("MTU: $mtu");

      final notificationsStream =
          _ble.subscribeToCharacteristic(_rxCharacteristic);
      currentStatus = MatchStatus.waitingNFC1;
      inputMatchStatus.add(currentStatus);
      inputState.add(ContentState());
      notificationsStream.listen(
        (List<int> data) async {
          _handleIncomingData(data);
        },
        onError: (error) {
          print('BLE Error: $error');
          inputState.add(ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: "Bluetooth Connection Error",
            retryAction: () {
              Navigator.pop(context);
              connectToDevice(device);
            },
          ));
        },
        onDone: () {
          _handleConnectionClosed(device);
          // print("BLE connection closed");
        },
      );
    } catch (e) {
      print('BLE Connection Exception: $e');
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.fullScreenErrorState,
        message: "Bluetooth Connection Error",
        retryAction: () {
          Navigator.pop(context);
          connectToDevice(device);
        },
      ));
    }
  }

  void _handleConnectionClosed(DiscoveredDevice device) {
    inputState.add(
      ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: 'Connection to ${device.name} closed.',
        retryAction: () {
          // Navigator.pop(context);
          MyApp.instance.navigatorKey.currentState?.pop();
        },
      ),
    );
  }

  void _handleIncomingData(List<int> data) {
    final message = String.fromCharCodes(data);
    print("Received data: $message");
    try {
      final jsonData = jsonDecode(message);

      if (message.contains('rfidUID')) {
        // checkNFC(jsonData['rfidUID']);
      } else if (jsonData.containsKey('speed1') &&
          currentStatus == MatchStatus.inMatch) {
        final player1Data = MatchDataEntity.fromBluetooth({
          'speed': jsonData['speed1'],
          'direction': jsonData['direction1'],
        }, _currentMatchTimeInMs);
        inputPlayer1MatchData.add(player1Data);
        // تطبيق فكرة التسجيل الذكي للاعب 1
        _addMatchData(player1Info.matchData, player1Data);

        final player2Data = MatchDataEntity.fromBluetooth({
          'speed': jsonData['speed2'],
          'direction': jsonData['direction2'],
        }, _currentMatchTimeInMs);
        inputPlayer2MatchData.add(player2Data);
        lastPlayer1Speed = player1Data.speed;
        lastPlayer2Speed = player2Data.speed;
        // تطبيق فكرة التسجيل الذكي للاعب 2
        _addMatchData(player2Info.matchData, player2Data);
      }
    } catch (e) {
      print('Error parsing data: $e');
    }
  }

  // دالة مساعدة لتسجيل البيانات بذكاء
  void _addMatchData(List<MatchDataEntity> matchData, MatchDataEntity newData) {
    if (matchData.length >= 2) {
      final last = matchData.last;
      final secondLast = matchData[matchData.length - 2];

      if (last.speed == 0.0 &&
          secondLast.speed == 0.0 &&
          newData.speed == 0.0) {
        // لو آخر اتنين 0.0 والجديد 0.0، نمسح الأخير ونضيف الجديد
        matchData.removeLast();
        matchData.add(newData);
      } else {
        // لو مش كده، نضيف الجديد عادي
        matchData.add(newData);
      }
    } else {
      // لو الليستة لسه صغيرة (أقل من 2)، نضيف عادي
      matchData.add(newData);
    }
  }

  // @override
  // Future<void> checkNFC(String rfidUID) async {
  //   // تحديد playerId بناءً على الحالة الحالية مع مراعاة حالات الخطأ
  //   int playerId;
  //   if (currentStatus == MatchStatus.waitingNFC1 ||
  //       currentStatus == MatchStatus.errorNFC1) {
  //     playerId = 1;
  //   } else if (currentStatus == MatchStatus.waitingNFC2 ||
  //       currentStatus == MatchStatus.errorNFC2) {
  //     playerId = 2;
  //   } else {
  //     return;
  //   }
  //
  //   // تحديث الحالة لـ waitingForCheck بناءً على playerId
  //   currentStatus = playerId == 1
  //       ? MatchStatus.waitingForCheck1
  //       : MatchStatus.waitingForCheck2;
  //   print('match status: $currentStatus');
  //   _matchStatusController.add(currentStatus);
  //   Either<Failure, TraineeData> request =
  //       await _trainingUsecase.checkTraineeExistence(rfidUID.trim());
  //   request.fold(
  //     (failure) {
  //       if (failure.code == 10) {
  //         currentStatus =
  //             playerId == 1 ? MatchStatus.errorNFC1 : MatchStatus.errorNFC2;
  //         _matchStatusController.add(currentStatus);
  //         inputState.add(ContentState());
  //         return;
  //       } else {
  //         inputState.add(ErrorState(
  //             stateRenderType: StateRenderType.popupErrorState,
  //             message: failure.message,
  //             retryAction: () {
  //               inputState.add(ContentState());
  //               checkNFC(rfidUID);
  //             }));
  //       }
  //     },
  //     (traineeData) {
  //       print(traineeData.photo);
  //       if (playerId == 1) {
  //         currentStatus = MatchStatus.waitingNFC2;
  //
  //         inputPlayer1Data.add(traineeData);
  //         player1Info.playerData = traineeData;
  //       } else {
  //         sendOk();
  //         inputPlayer2Data.add(traineeData);
  //         player2Info.playerData = traineeData;
  //       }
  //       _matchStatusController.add(currentStatus);
  //       inputState.add(ContentState());
  //     },
  //   );
  // }

  @override
  void startMatch() {
    //todo remove comment
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Start'.codeUnits);
    currentStatus = MatchStatus.inMatch;
    _matchStatusController.add(currentStatus);
    // _currentMatchTimeInMs = 0;
  }

  @override
  void resumeMatch() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Resume'.codeUnits);
    currentStatus = MatchStatus.inMatch;
    _matchStatusController.add(currentStatus);
  }

  void sendOk() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'OK'.codeUnits);
    currentStatus = MatchStatus.paused;
    // _matchStatusController.add(currentStatus);
  }

  @override
  void endMatch() {
    //todo remove comment
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'end'.codeUnits);
    currentStatus = MatchStatus.ended;
    _matchStatusController.add(currentStatus);
  }

  void sendPause() {
    _ble.writeCharacteristicWithoutResponse(_rxCharacteristic,
        value: 'Pause'.codeUnits);
    currentStatus = MatchStatus.paused;
    _matchStatusController.add(currentStatus);
  }

  @override
  void addPointManually(int playerId) {
    //todo remove comment
    sendPause();
    if (playerId == 1) {
      PointDataEntity pointRecord = PointDataEntity(
        timeInMs: _currentMatchTimeInMs,
        speed: lastPlayer1Speed,
      );
      player1Info.pointRecords.add(pointRecord);
      print(player1Info.pointRecords.length);
      inputPlayer1Points.add(pointRecord);
    } else if (playerId == 2) {
      PointDataEntity pointRecord = PointDataEntity(
        timeInMs: _currentMatchTimeInMs,
        speed: lastPlayer1Speed,
      );
      player2Info.pointRecords.add(pointRecord);
      print(player2Info.pointRecords.length);
      inputPlayer2Points.add(pointRecord);
    }
  }

  void subtractPointManually(int playerId) {
    //todo remove comment
    if (playerId == 1 && player1Info.pointRecords.isNotEmpty) {
      player1Info.pointRecords.removeLast();
      print(player1Info.pointRecords.length);
      inputPlayer1Points.add(player1Info.pointRecords.lastOrNull);
    } else if (playerId == 2 && player2Info.pointRecords.isNotEmpty) {
      player2Info.pointRecords.removeLast();
      print(player2Info.pointRecords.length);
      inputPlayer2Points.add(player2Info.pointRecords.lastOrNull);
    }
  }

  FencingUsecase fencingUsecase = FencingUsecase();

  @override
  void saveMatchData() async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    Either<Failure, void> result = await fencingUsecase.addMatch(
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
    result.fold((l) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: l.message,
        retryAction: () {
          inputState.add(ContentState());
        },
      ));
    }, (r) {
      inputState.add(ContentState());
      Navigator.pop(context);
    });
  }

  void updateMatchTime(int timeInMs) {
    _currentMatchTimeInMs = timeInMs;
  }

  @override
  void dispose() async {
    _matchStatusController.close();
    _player1DataController.close();
    _player2DataController.close();
    await _bleConnector.disconnect(device.id);
    _bleConnector.dispose();
    super.dispose();
  }

  @override
  Sink get inputPlayer1MatchData => _player1MatchDataController.sink;

  @override
  Sink get inputPlayer1Points => _player1PointsController.sink;

  @override
  Sink get inputPlayer2MatchData => _player2MatchDataController.sink;

  @override
  Sink get inputPlayer2Points => _player2PointsController.sink;

  @override
  Stream<MatchDataEntity> get outputPlayer1MatchData =>
      _player1MatchDataController.stream;

  @override
  Stream<PointDataEntity> get outputPlayer1Points =>
      _player1PointsController.stream
          .map((event) => event ?? PointDataEntity(timeInMs: -1, speed: 0));

  @override
  Stream<MatchDataEntity> get outputPlayer2MatchData =>
      _player2MatchDataController.stream;

  @override
  Stream<PointDataEntity> get outputPlayer2Points =>
      _player2PointsController.stream
          .map((event) => event ?? PointDataEntity(timeInMs: -1, speed: 0));
}
