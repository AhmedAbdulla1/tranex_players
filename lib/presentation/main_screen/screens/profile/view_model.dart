import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/domain/usecase/user_usecase.dart';
import 'package:firesport_users/presentation/base/base_view_model.dart';
import 'package:firesport_users/presentation/bluetooth/bluetooth_model.dart';
import 'package:firesport_users/presentation/common/state_render/state_render.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class ProfileViewModel extends ProfileViewModelOutput {
  final UserUsecase _usecaseUser;
  final AppPreferences _appPreferences = instance<AppPreferences>();

  ProfileViewModel(this._usecaseUser);

  final StreamController<String> _profilePictureController =
      StreamController<String>.broadcast();
  final StreamController<TraineeData> _dataStreamController = BehaviorSubject<TraineeData>();

  final BluetoothModel _bluetoothModel = BluetoothModel();


  Future<File> convertUint8ListToFile(
      Uint8List uint8List, String fileName) async {
    // Create a temporary directory
    Directory tempDir = Directory.systemTemp;

    // Create a temporary file
    File tempFile = File('${tempDir.path}/$fileName.png');
    if (uint8List.isEmpty) {
      final bytes = await rootBundle.load(ImageAssets.personal);
      tempFile.writeAsBytesSync(Uint8List.view(bytes.buffer));
    } else {
      // Write the Uint8List data to the file
      tempFile.writeAsBytesSync(uint8List);
    }
    return tempFile;
  }
  void showBluetoothDialog(BuildContext context) {
    _bluetoothModel.showDeviceDiscoveryDialog(
      context: context,
      onDeviceSelected: (device) {
        print("Device selected: ${device.name}");
        Navigator.pushNamed(
          context,
          Routes.fencingMatchScreen,
          arguments: device,
        );
      },
    );
  }
  @override
  void start() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.fullScreenLoadingState,
      ),
    );
    _usecaseUser.getUser().fold((error) {
      inputState.add(
        ErrorState(
            stateRenderType: StateRenderType.fullScreenErrorState,
            message: error.message,
            retryAction: () {
              inputState.add(ContentState());
            }),
      );
    }, (trainee) {
      inputData.add(trainee);
      setProfilePicture(trainee.photo ?? '');
    });

    // debugPrint(userData.get(0)!.image);
    _bluetoothModel.requestBluetoothPermissions();
    inputState.add(ContentState());
    // });
  }

  @override
  Sink<String> get profilePictureInput => _profilePictureController.sink;

  @override
  Stream<String> get profilePictureOutput => _profilePictureController.stream;

  @override
  setProfilePicture(String profilePicture) {
    profilePictureInput.add(profilePicture);
  }

  Future deleteAccount() async {
    inputState
        .add(LoadingState(stateRenderType: StateRenderType.popupLoadingState));
    Either<Failure, void> request = await _usecaseUser.deleteAccount();
    request.fold((l) {
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: l.message,
          retryAction: () {
            inputState.add(ContentState());
          }));
      debugPrint(l.message);
    }, (r) {
      _appPreferences.logout();
      inputState.add(ContentState());
      debugPrint('Account deleted successfully.');
    });
  }


  Future logout() async {
    inputState
        .add(LoadingState(stateRenderType: StateRenderType.popupLoadingState));
    Either<Failure, void> request = await _usecaseUser.logout();
    request.fold((l) {
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: l.message,
          retryAction: () {
            inputState.add(ContentState());
          }));
      debugPrint(l.message);
    }, (r) {
      _appPreferences.logout();
      inputState.add(ContentState());
      debugPrint('Logout successfully.');
    });
  }

  @override
  Sink<TraineeData> get inputData => _dataStreamController.sink;

  @override
  Stream<TraineeData> get outData => _dataStreamController.stream;
}

abstract class ProfileViewModelInput extends BaseViewModel {
  setProfilePicture(String profilePicture);

  Sink<String> get profilePictureInput;

  Sink<TraineeData> get inputData;
}

abstract class ProfileViewModelOutput extends ProfileViewModelInput {
  Stream<String> get profilePictureOutput;

  Stream<TraineeData> get outData;
}
