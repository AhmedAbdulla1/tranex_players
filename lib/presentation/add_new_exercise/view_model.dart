import 'dart:async';
import 'dart:io';
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/constant.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/usecase/add_new_exercise_usecase.dart';
import 'package:firesport_users/domain/usecase/user_usecase.dart';
import 'package:firesport_users/presentation/base/base_view_model.dart';
import 'package:firesport_users/presentation/common/freezed/freezed.dart';
import 'package:firesport_users/presentation/common/reusable/upload_image_service.dart';
import 'package:firesport_users/presentation/common/state_render/state_render.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:dartz/dartz.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class AddNewExerciseViewModel extends AddNewExerciseInput {
  final StreamController<DeviceData> _deviceTypeController =
      BehaviorSubject<DeviceData>();
  final StreamController<bool> _inputAreRight = BehaviorSubject<bool>();
  final StreamController<bool> _inputExerciseAreRight = BehaviorSubject<bool>();
  AddNewExerciseObject _addNewExerciseObject = AddNewExerciseObject(
      exerciseName: '',
      imageUrl: '',
      categoryId: 0,
      categoryName: '',
      deviceType: null);
  final AppPreferences _appPreferences = instance<AppPreferences>();
  File? imageFile;
  final StreamController<File?> _addImageStreamController =
      BehaviorSubject<File>();
  final StreamController<CategoryData> _categoryStreamController =
      BehaviorSubject<CategoryData>();
  final StreamController<String> _exerciseNameStreamController =
      BehaviorSubject<String>();
  final UserUsecase _useCaseUser = instance<UserUsecase>();
  final AddNewExerciseUseCase _useCase = instance<AddNewExerciseUseCase>();

  List<CategoryData> categoriesData = [];
  List<DeviceData> devices = [];

  @override
  Sink get inputDeviceType => _deviceTypeController.sink;

  @override
  void start() {
    if (categoriesData.isNotEmpty) {
      setCategory(categoriesData.first);
    }
    getDevices();
  }

  getDevices() async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    (await _useCase.getDevices()).fold((l) {
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.fullScreenErrorState,
          message: l.message,
          retryAction: () {
            inputState.add(ContentState());
          }));
    }, (r) {
      devices = r;
      setDeviceType(r.firstOrNull);
      print(r);
      inputState.add(ContentState());
    });
  }

  @override
  void setDeviceType(DeviceData? deviceType) {
    inputDeviceType.add(deviceType!);
    _addNewExerciseObject = _addNewExerciseObject.copyWith(
      deviceType: deviceType,
    );
  }

  @override
  void setImage(File? image) {
    inputImage.add(image);
    imageFile = image;
  }

  @override
  void setCategory(CategoryData category) {
    inputCategory.add(category);
    _addNewExerciseObject = _addNewExerciseObject.copyWith(
      categoryId: category.categoryId,
      categoryName: category.categoryName,
    );
  }

  Future getCategory() async {
    // (await _useCase.()).fold((l) {
    //   inputState.add(ErrorState(
    //       stateRenderType: StateRenderType.fullScreenErrorState,
    //       message: l.message,retryAction: (){
    //     inputState.add(ContentState());
    //   }));
    // }, (r) {
    //   categoriesData = r;
    //   if (r.isNotEmpty) {
    //     setCategory(r.first);
    //   }
    //   inputState.add(ContentState());
    // });
  }

  void addNewCategory(CategoryData category) {
    categoriesData.add(category);
    setCategory(category);
    inputCategory.add(category);
  }

  Future<bool> addNewExercise(BuildContext context) async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    if (_appPreferences.getLoginMethod() == LoginMethod.anonymous.name) {
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: 'يرجى تسجيل الدخول',
          retryAction: () {
            _useCaseUser.deleteAccount();
            Navigator.pushReplacementNamed(context, Routes.loginScreen);
          }));
      return false;
    }
    if (imageFile != null) {
      Either<Failure, String> imageResult =
          await uploadImage(imageFile!, ImageDestination.exercise);
      bool result = imageResult.fold((l) {
        inputState.add(ErrorState(
          stateRenderType: StateRenderType.fullScreenErrorState,
          message: l.message,
          retryAction: () {
            inputState.add(ContentState());
          },
        ));
        return false;
      }, (r) {
        debugPrint(r);
        _addNewExerciseObject = _addNewExerciseObject.copyWith(
          imageUrl: r,
        );
        return true;
      });
      if (!result) return false;
    }
    bool result = (await _useCase.addNewExercise(AddNewExerciseRequest(
      categoryId: _addNewExerciseObject.categoryId,
      exerciseName: _addNewExerciseObject.exerciseName,
      image: _addNewExerciseObject.imageUrl,
      deviceId: _addNewExerciseObject.deviceType!.deviceId,
      categoryName: _addNewExerciseObject.categoryName,
    )))
        .fold(
      (l) {
        inputState.add(
          ErrorState(
              stateRenderType: StateRenderType.popupErrorState,
              message: l.message,
              retryAction: () {
                inputState.add(ContentState());
              }),
        );
        debugPrint(l.message);
        return false;
      },
      (r) {

        if (_addNewExerciseObject.categoryId == 'new') {
          setCategory(CategoryData(
            categoryId: r,
            categoryName: _addNewExerciseObject.categoryName,
            exercises: [],
          ));
        }
        Navigator.pop(context, true);
        return true;
      },
    );

    return result;
  }

  @override
  Sink get inputCategoryNameRight => _inputAreRight.sink;

  @override
  Stream<bool> get outputCategoryNameRight => _inputAreRight.stream;

  @override
  Stream<DeviceData> get outputDeviceType => _deviceTypeController.stream;

  @override
  Sink get inputExerciseNameRight => _inputExerciseAreRight.sink;

  @override
  Stream<bool> get outputExerciseNameRight => _inputExerciseAreRight.stream;

  @override
  Sink get inputCategory => _categoryStreamController.sink;

  @override
  Sink get inputExercise => _exerciseNameStreamController.sink;

  @override
  Sink get inputImage => _addImageStreamController.sink;

  @override
  Stream<File?> get outAddImage => _addImageStreamController.stream;

  @override
  Stream<CategoryData> get outCategory => _categoryStreamController.stream;

  @override
  Stream<String> get outExerciseName => _exerciseNameStreamController.stream;

  @override
  setNewCategory(String name) {
    if (name.isNotEmpty) {
      _inputAreRight.add(true);
    } else {
      _inputAreRight.add(false);
    }
  }

  @override
  setNewExercise(String exerciseName) async {
    if (exerciseName.isNotEmpty) {
      _addNewExerciseObject = _addNewExerciseObject.copyWith(
        exerciseName: exerciseName,
      );
      _inputExerciseAreRight.add(true);
    } else {
      _inputExerciseAreRight.add(false);
    }
  }

  @override
  Stream<String?> get outCategoryValid => _exerciseNameStreamController.stream;
}

abstract class AddNewExerciseInput extends AddNewExerciseOutput {
  setNewCategory(String name);

  setNewExercise(
    String exerciseName,
  );

  setCategory(CategoryData category);

  setImage(File image);

  setDeviceType(DeviceData deviceType);

  Sink get inputImage;

  Sink get inputCategory;

  Sink get inputExercise;

  Sink get inputDeviceType;

  Sink get inputCategoryNameRight;

  Sink get inputExerciseNameRight;
}

abstract class AddNewExerciseOutput extends BaseViewModel {
  Stream<File?> get outAddImage;

  Stream<CategoryData> get outCategory;

  Stream<String?> get outCategoryValid;

  Stream<String> get outExerciseName;

  Stream<DeviceData> get outputDeviceType;

  Stream<bool> get outputCategoryNameRight;

  Stream<bool> get outputExerciseNameRight;
}
