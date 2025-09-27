import 'dart:async';
import 'dart:developer';

import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/usecase/user_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/freezed/freezed.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';

import '../../../app/app_prefs.dart';

class LoginViewModel extends LoginViewModelOutput {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final StreamController _emailController =
      StreamController<String>.broadcast();
  final StreamController _passwordController =
      StreamController<String>.broadcast();
  final StreamController _visibilityController =
      StreamController<bool>.broadcast();
  final StreamController _areInputValidController =
      StreamController<void>.broadcast();
  final StreamController<bool> isUserLoginSuccessfullyStreamController =
      StreamController.broadcast();
  LoginObject _loginObject = LoginObject('', '');
  final UserUsecase _loginUseCase;

  LoginViewModel(this._loginUseCase);

  bool visible = false;

  @override
  void start() {
    inputState.add(ContentState());
  }

  @override
  Sink get inputAreAllInputValid => _areInputValidController.sink;

  @override
  Sink get inputEmailValid => _emailController.sink;

  @override
  Sink get inputPassword => _passwordController.sink;

  @override
  Sink get inputPasswordVisible => _visibilityController.sink;

  @override
  Stream<bool> get outAreAllInputValid =>
      _areInputValidController.stream.map((_) => _areInputValid());

  @override
  Stream<String?> get outEmailIsValid =>
      _emailController.stream.map((email) => _emailOutError(email));

  @override
  Stream<String?> get outPasswordIsValid =>
      _passwordController.stream.map((password) => _passwordOutError(password));

  @override
  Stream<bool> get outPasswordIsVisible =>
      _visibilityController.stream.map((visible) => visible);

  @override
  login() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.popupLoadingState,
      ),
    );
    (await _loginUseCase.loginWithEmail(
      LoginRequest(
        email: _loginObject.email,
        password: _loginObject.password,
      ),
    ))
        .fold((failure) {
      log(failure.toString(), name: "Failure ");
      log(failure.message, name: "Failure message ");
      inputState.add(
        ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () {
              inputState.add(ContentState());
            }),
      );
    }, (data) async {
      // await _appPreferences.setCoachId(data);
      // await _appPreferences.setToken(data.id);
      inputState.add(
        ContentState(),
      );

      isUserLoginSuccessfullyStreamController.add(true);
    });
  }

  @override
  setEmail(String email) {
    _emailController.add(email);
    if (email.isNotEmpty) {
      _loginObject = _loginObject.copyWith(
        email: email,
      );
    } else {
      _loginObject = _loginObject.copyWith(
        email: "",
      );
    }
    _areInputValidController.add(null);
  }

  @override
  setPassword(String password) {
    _passwordController.add(password);
    if (password.isNotEmpty) {
      _loginObject = _loginObject.copyWith(
        password: password,
      );
    } else {
      _loginObject = _loginObject.copyWith(
        password: "",
      );
    }
    _areInputValidController.add(null);
  }

  @override
  setVisibility(bool visible) {
    _visibilityController.add(visible);
  }

  String? _emailOutError(String email) {
    if (email.isEmpty) {
      return AppStrings.emailError;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return AppStrings.emailError2;
    }
    return null;
  }

  bool _emailIsValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  String? _passwordOutError(String password) {
    if (password.isEmpty) {
      return AppStrings.passwordError;
    }
    return null;
  }

  bool _areInputValid() {
    return _emailIsValid(_loginObject.email) &&
        _loginObject.password.isNotEmpty;
  }

  @override
  loginWithGoogle() async {
    (await _loginUseCase.loginWithGoogle()).fold((failure) {
      inputState.add(
        ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () {
              inputState.add(ContentState());
            }),
      );
    }, (data) async {
      await _appPreferences.setUid(data.id);
      log("Login with google: ${data.id}");
      log("Uid : ${_appPreferences.getUid()}");
      inputState.add(
        ContentState(),
      );

      isUserLoginSuccessfullyStreamController.add(true);
    });
  }
}

abstract class LoginViewModelInput extends BaseViewModel {
  setEmail(String email);

  setPassword(String password);

  setVisibility(bool visible);

  login();

  loginWithGoogle();

  Sink get inputEmailValid;

  Sink get inputPassword;

  Sink get inputPasswordVisible;

  Sink get inputAreAllInputValid;
}

abstract class LoginViewModelOutput extends LoginViewModelInput {
  Stream<String?> get outEmailIsValid;

  Stream<String?> get outPasswordIsValid;

  Stream<bool> get outPasswordIsVisible;

  Stream<bool> get outAreAllInputValid;
}
