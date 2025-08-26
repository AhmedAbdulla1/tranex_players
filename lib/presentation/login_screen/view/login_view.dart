import 'dart:typed_data';

import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/presentation/common/reusable/custom_button.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/login_screen/view_model/login_view_model.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final LoginViewModel _loginViewModel = instance<LoginViewModel>();
  bool visible = true;

  void _bind() {
    _loginViewModel.start();
    _loginViewModel.isUserLoginSuccessfullyStreamController.stream
        .listen((isLoading) {
      if (isLoading) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _appPreferences.setPressKeyLoginScreen();
          Navigator.pushReplacementNamed(context, Routes.mainScreen);
        });
      }
    });
  }

  @override
  void initState() {
    _bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: StreamBuilder<StateFlow>(
        stream: _loginViewModel.outputState,
        builder: (context, snapshot) =>
            snapshot.data?.getScreenWidget(
              context,
              _getContent(),
            ) ??
            _getContent(),
      ),
    );
  }

  Widget _getContent() {
    return SizedBox(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppPadding.p16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  ImageAssets.appLogo,
                  height: 270.h,
                ),
              ),
              SizedBox(
                height: AppSize.s35.h,
              ),
              Text(
                AppStrings.loginTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSize.s28),
              customElevatedButtonWithoutStream(
                onPressed: () {

                  _loginViewModel.scanQR();
                },
                child: Text("Scan QR",style: getRegularStyle(fontSize:20 , color: ColorManager.white),),
              ),
              //forgot password
            ],
          ),
        ),
      ),
    );
  }
}
