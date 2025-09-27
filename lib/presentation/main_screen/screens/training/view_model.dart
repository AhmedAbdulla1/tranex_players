import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/usecase/add_new_exercise_usecase.dart';
import 'package:tranex_users/presentation/bluetooth/bluetooth_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/freezed/freezed.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/routes_manager.dart';
import 'package:tranex_users/presentation/wifi_scanner/device_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:rxdart/subjects.dart';
import 'package:tranex_users/presentation/fencing_training/fencing_view.dart';
class TrainingViewModel extends TrainingViewModelOutput {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final AddNewExerciseUseCase _addNewExerciseUseCase =
      instance<AddNewExerciseUseCase>();

  // موديل الـ Bluetooth
  final BluetoothModel _bluetoothModel = BluetoothModel();

  // Subjects for state management
  final _exerciseController = BehaviorSubject<String>();
  final _deviceTypeController = BehaviorSubject<DeviceData>();
  final _traineeController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject<String>();
  final _weightController = BehaviorSubject<double>();
  final _idleTimeController = BehaviorSubject<int>();
  final _autoStartController = BehaviorSubject<bool>();
  final _accessPointController = BehaviorSubject<DiscoveredDevice?>();
  final _trainerController = BehaviorSubject<bool>();

  late TrainingObject _trainingObject =
      TrainingObject("Set Exercise", '', null, 1, true, 3);

  // Inputs
  @override
  Sink get inputExercise => _exerciseController.sink;

  @override
  Sink get inputWeight => _weightController.sink;

  @override
  Sink get inputAutoStart => _autoStartController.sink;

  @override
  Sink get inputIdleTime => _idleTimeController.sink;

  @override
  Sink get inputAccessPoint => _accessPointController.sink;

  @override
  Sink get inputTrainerDataIsRight => _trainerController.sink;

  @override
  Sink get inputTrainee => _traineeController.sink;

  @override
  Sink get inputDeviceType => _deviceTypeController.sink;

  @override
  Sink get inputImage => _imageController.sink;

  // Outputs
  @override
  Stream<String> get outExercise => _exerciseController.stream;

  @override
  Stream<double> get outWeight => _weightController.stream;

  @override
  Stream<bool> get outAutoStart => _autoStartController.stream;

  @override
  Stream<int> get outIdleTime => _idleTimeController.stream;

  @override
  Stream<DiscoveredDevice?> get outDevice => _accessPointController.stream;

  @override
  Stream<String> get outImage => _imageController.stream;

  @override
  Stream<String> get outTrainee => _traineeController.stream;

  @override
  Stream<DeviceData> get outDeviceType => _deviceTypeController.stream;

  @override
  Stream<bool> get outTrainerDataIsRight => _trainerController.stream;

  @override
  void start() {
    print("start");
    inputTrainerDataIsRight.add(false);
    inputState.add(ContentState());
    final training = _appPreferences.getTraining();
    if (training != null) {
      Map<String, dynamic> exercise = jsonDecode(training[0]);
      ExerciseData exerciseData = ExerciseData.fromJson(exercise);
      setExercise(exerciseData.exerciseName);
      setImage(exerciseData.exerciseImage);
      getDeviceTypeData(exerciseData.deviceId);
      setWeight(double.parse(training[1]));
      setAutostart(bool.parse(training[2]));
      setIdleTime(int.parse(training[3]));
    } else {
      setImage(ImageAssets.trainingImage);
    }

    // طلب الـ Permissions في بداية الشاشة
    _bluetoothModel.requestBluetoothPermissions();
  }

  // دالة جديدة لعرض الـ Dialog
  void showScanner(BuildContext context) async {
    if (_trainingObject.deviceType!.deviceId == 5) {
      final selectedIp = await DeviceScanner.scanDevices(context);
      print("device: $selectedIp");

      if (selectedIp!=0 && context.mounted) {
        Navigator.of(context, rootNavigator: true).pushNamed(
          FencingTrainingView.routeName,
          arguments: selectedIp,
        );
      }
    } else {
      _bluetoothModel.showDeviceDiscoveryDialog(
        context: context,
        onDeviceSelected: (device) {
          print("Device selected: ${device.name}");
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pushNamed(
              _trainingObject.deviceType!.deviceId != 5
                  ? Routes.inTrainingScreen
                  : FencingTrainingView.routeName,
              arguments: [device],
            );
          }
        },
      );
    }
  }

  // Update training object and add to streams
  void _updateTrainingObject({
    String? exercise,
    String? image,
    DeviceData? deviceType,
    double? weight,
    bool? autoStart,
    int? idleTime,
  }) {
    _trainingObject = _trainingObject.copyWith(
      exercises: exercise ?? _trainingObject.exercises,
      image: image ?? _trainingObject.image,
      deviceType: deviceType ?? _trainingObject.deviceType,
      weight: weight ?? _trainingObject.weight,
      autoStart: autoStart ?? _trainingObject.autoStart,
      idleTime: idleTime ?? _trainingObject.idleTime,
    );
    print(weight);
    if (exercise != null) inputExercise.add(exercise);
    if (image != null) inputImage.add(image);
    if (deviceType != null) inputDeviceType.add(deviceType);
    if (weight != null) inputWeight.add(weight);
    if (autoStart != null) inputAutoStart.add(autoStart);
    if (idleTime != null) inputIdleTime.add(idleTime);
    checkDataIsRight();
  }

  checkDataIsRight() {
    if(_trainingObject.deviceType?.deviceId == 5) {
      return inputTrainerDataIsRight.add(true);
    }
    if (_trainingObject.exercises.isNotEmpty &&
        _trainingObject.weight != 0 &&
        _trainingObject.deviceType != null) {
      inputTrainerDataIsRight.add(true);
    } else {
      inputTrainerDataIsRight.add(false);
    }
  }

  getDeviceTypeData(int deviceId) async {
    print(deviceId);
    Either<Failure, List<DeviceData>> result =
        await _addNewExerciseUseCase.getDevices();
    result.fold((e) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        retryAction: () {
          inputState.add(ContentState());
        },
        message: e.message,
      ));
    }, (r) {
      print(r);
      setDeviceType(r.where((device) => device.deviceId == deviceId).first);
      checkDataIsRight();
      inputState.add(ContentState());
    });
  }

  @override
  void dispose() {
    _exerciseController.close();
    _deviceTypeController.close();
    _traineeController.close();
    _imageController.close();
    _weightController.close();
    _idleTimeController.close();
    _autoStartController.close();
    _accessPointController.close();
    _trainerController.close();
    _bluetoothModel.dispose();
  }

  // Helper methods
  @override
  void setExercise(String exercise) =>
      _updateTrainingObject(exercise: exercise);

  @override
  void setImage(String imageUrl) => _updateTrainingObject(image: imageUrl);

  @override
  void setDeviceType(DeviceData deviceType) =>
      _updateTrainingObject(deviceType: deviceType);

  @override
  void setWeight(double num) => _updateTrainingObject(weight: num);

  @override
  void setAutostart(bool status) => _updateTrainingObject(autoStart: status);

  @override
  void setIdleTime(int num) => _updateTrainingObject(idleTime: num);

  @override
  setTrainee(String teamId, String name, String id) {
    // _traineeController.add(name);
    // _trainerController.add(true);
    // _appPreferences.setTrainee([teamId, name, id]);
  }

  @override
  setTraining({ExerciseData? exercise}) {
    _appPreferences.setTraining([
      exercise != null
          ? jsonEncode(exercise.toJson())
          : _appPreferences.getTraining()![0],
      _trainingObject.weight.toString(),
      _trainingObject.autoStart ? "true" : 'false',
      _trainingObject.idleTime.toString(),
    ]);
  }
}

abstract class TrainingViewModelInput extends BaseViewModel {
  setExercise(String exercise);

  setImage(String imageUrl);

  setDeviceType(DeviceData deviceType);

  setWeight(double num);

  setAutostart(bool status);

  setIdleTime(int num);

  setTraining({ExerciseData? exercise});

  setTrainee(String teamId, String name, String id);

  Sink get inputAutoStart;

  Sink get inputImage;

  Sink get inputIdleTime;

  Sink get inputDeviceType;

  Sink get inputExercise;

  Sink get inputWeight;

  Sink get inputAccessPoint;

  Sink get inputTrainee;

  Sink get inputTrainerDataIsRight;
}

abstract class TrainingViewModelOutput extends TrainingViewModelInput {
  Stream<double> get outWeight;

  Stream<String> get outImage;

  Stream<DeviceData> get outDeviceType;

  Stream<int> get outIdleTime;

  Stream<bool> get outAutoStart;

  Stream<String> get outExercise;

  Stream<String> get outTrainee;

  Stream<DiscoveredDevice?> get outDevice;

  Stream<bool> get outTrainerDataIsRight;
}
