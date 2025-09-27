import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/usecase/user_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/reusable/upload_image_service.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/freezed/freezed.dart';
import '../resources/string_manager.dart';

class ProfileDetailsViewModel extends ProfileDetailsViewModelOutput {
  final StreamController<File> _profilePictureController =
      StreamController<File>.broadcast();
  final StreamController<User> _streamController = BehaviorSubject<User>();
  final StreamController _nameController = StreamController<String>.broadcast();
  final StreamController<bool> isUserRegisterSuccessfullyStreamController =
      StreamController.broadcast();
  final StreamController<void> _allInputsValid = StreamController.broadcast();
  SignupObject signupObject = SignupObject("", "", "", "", "", "", "");
  final UserUsecase _userUsecase;
  String token = '';
  File? image;
  String? imagePath;

  ProfileDetailsViewModel(this._userUsecase);

  @override
  void start() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.fullScreenLoadingState,
      ),
    );
    _userUsecase.getUser().fold((error) {
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.fullScreenLoadingState,
        message: error.message,
        retryAction: () {
          inputState.add(ContentState());
        },
      ));
    }, (user) {
      inputData.add(
        user,
      );
      if (user.userMetadata != null &&
          user.userMetadata!['photo_url'] != null) {
        imagePath = user.userMetadata!['photo_url']!;
      }

      signupObject = signupObject.copyWith(
        name: user.userMetadata!['display_name'] ?? '',
        email: user.email ?? '',
      );
      inputState.add(
        ContentState(),
      );
    });
  }

  Future<bool> connectToHeadCoach(String code) async {
    inputState
        .add(LoadingState(stateRenderType: StateRenderType.popupLoadingState));
    final Either<Failure, bool> result =
        await _userUsecase.connectToHeadCoach(code: code);
    return result.fold((l) {
      log("$l", name: "Left");
      inputState.add(ErrorState(
        stateRenderType: StateRenderType.popupErrorState,
        message: l.message,
        retryAction: () {
          inputState.add(ContentState());
        },
      ));
      return false;
    }, (r) {
      log("$r", name: "Right");
      inputState.add(SuccessState("Connected Successfully"));

      inputState.add(ContentState());
      return true;
    });
  }

  @override
  Future<bool> updateProfile(BuildContext context) async {
    String? imageUrl;
    bool uploadImageResult = true;
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.fullScreenLoadingState,
      ),
    );
    if (image != null) {
      Either<Failure, String> result =
          await uploadImage(image!, ImageDestination.profile);
      uploadImageResult = result.fold((failure) {
        inputState.add(
          ErrorState(
              stateRenderType: StateRenderType.popupErrorState,
              message: failure.message,
              retryAction: () {
                inputState.add(ContentState());
              }),
        );
        return false;
      }, (data) {
        imageUrl = data;
        log("image url $imageUrl");
        return true;
      });
    }
    if (uploadImageResult) {
      return (await _userUsecase.updateProfile(UpdateProfileRequest(
        name: signupObject.name,
        profilePicture: imageUrl,
      )))
          .fold((failure) {
        inputState.add(
          ErrorState(
              stateRenderType: StateRenderType.popupErrorState,
              message: failure.message,
              retryAction: () {
                inputState.add(ContentState());
              }),
        );
        return false;
      }, (data) {
        debugPrint('update profile success');
        inputState.add(
          ContentState(),
        );
        return true;
      });
    }
    return uploadImageResult;
  }

  @override
  setName(String name) {
    _nameController.add(name);
    if (_nameIsValid(name)) {
      signupObject = signupObject.copyWith(
        name: name,
      );
    } else {
      signupObject = signupObject.copyWith(
        name: '',
      );
    }

    _allInputsValid.add(null);
  }

  @override
  void dispose() {
    _nameController.close();
    _profilePictureController.close();
    super.dispose();
  }

  @override
  Sink get inputNameIsValid => _nameController.sink;

  @override
  Sink get inputAreInputsValid => _allInputsValid.sink;

  @override
  Stream<String?> get outNameIsValid => _nameController.stream.map(
        (name) => _nameOutError(name),
      );

  @override
  Stream<bool> get outAreInputValid =>
      _allInputsValid.stream.map((_) => _areInputsValid());

  String? _nameOutError(String name) {
    if (name.isEmpty) {
      return AppStrings.nameError1;
    }
    return null;
  }

  _nameIsValid(String name) {
    return name.length >= 3;
  }

  bool _areInputsValid() {
    return true;
  }

  @override
  Sink<File> get profilePictureInput => _profilePictureController.sink;

  @override
  Stream<File> get profilePictureOutput => _profilePictureController.stream;

  @override
  setProfilePicture(File profilePicture) {
    image = profilePicture;
    _profilePictureController.add(profilePicture);
    _allInputsValid.add(null);
  }

  @override
  Sink get inputData => _streamController.sink;

  @override
  Stream<User> get outputData => _streamController.stream;
}

abstract class ProfileDetailsViewModelInput extends BaseViewModel {
  setProfilePicture(File profilePicture);

  Sink<File> get profilePictureInput;

  setName(String name);

  Future<bool> updateProfile(BuildContext context);

  Sink get inputData;

  Sink get inputNameIsValid;

  Sink get inputAreInputsValid;
}

abstract class ProfileDetailsViewModelOutput
    extends ProfileDetailsViewModelInput {
  Stream<User> get outputData;

  Stream<File> get profilePictureOutput;

  Stream<String?> get outNameIsValid;

  Stream<bool> get outAreInputValid;
}

class DashBoardObject {
  String name;
  String email;
  String image;

  DashBoardObject({
    required this.name,
    required this.email,
    required this.image,
  });
}
