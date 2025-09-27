import 'dart:async';
import 'package:tranex_users/domain/usecase/user_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/freezed/freezed.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';


class RecoverPasswordViewModel extends  RecoverPasswordViewModelOutput {


  final StreamController _emailController =
  StreamController<String>.broadcast();

  final StreamController _areInputValidController =
  StreamController<void>.broadcast();
  final StreamController<bool> isUserLoginSuccessfullyStreamController =
  StreamController.broadcast();
  ForgotPasswordObject _forgotPasswordObject = ForgotPasswordObject( '', '','');
  final UserUsecase _userUsecase ;
  String token ="";
  RecoverPasswordViewModel(this._userUsecase);
  @override

  void start() {
    inputState.add(ContentState());
  }

  @override
  Sink get inputAreAllInputValid => _areInputValidController.sink;

  @override
  Sink get inputEmailValid => _emailController.sink;





  @override
  sendEmail() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.popupLoadingState,
      ),
    );
    (await _userUsecase.sendResetPasswordEmail(
      _forgotPasswordObject.email
    ))
        .fold((failure) {
      inputState.add(
        ErrorState(
          stateRenderType: StateRenderType.popupErrorState,
          message: failure.message,retryAction: (){
          inputState.add(ContentState());
        }
        ),
      );
    }, (data) {
      inputState.add(
        ContentState(),
      );
      isUserLoginSuccessfullyStreamController.add(true);
    });
  }

  @override
  Stream<bool> get outAreAllInputValid =>
      _areInputValidController.stream.map((_) => _areInputValid());

  @override
  Stream<String?> get outEmailIsValid =>
      _emailController.stream.map((email) => _emailOutError(email));

  @override
  setEmail(String email) {
    _emailController.add(email);
    if (_emailIsValid(email)) {
      _forgotPasswordObject = _forgotPasswordObject.copyWith(
        email: email,
      );
    } else {
      _forgotPasswordObject = _forgotPasswordObject.copyWith(
        email: "",
      );
    }
    _areInputValidController.add(null);
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

  bool _areInputValid() {
    return _emailIsValid(_forgotPasswordObject.email);
  }


}

abstract class RecoverPasswordViewModelInput extends BaseViewModel {

  sendEmail();
  setEmail(String email);

  Sink get inputEmailValid;

  Sink get inputAreAllInputValid;
}

abstract class RecoverPasswordViewModelOutput extends RecoverPasswordViewModelInput{
  Stream<String?> get outEmailIsValid;
  Stream<bool> get outAreAllInputValid;
}
