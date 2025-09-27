import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/reset_password_screen/view_model/recover_password_view_model.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/routes_manager.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecoverPasswordView extends StatefulWidget {
  const RecoverPasswordView({Key? key}) : super(key: key);

  @override
  State<RecoverPasswordView> createState() => _RecoverPasswordViewState();
}

class _RecoverPasswordViewState extends State<RecoverPasswordView> {
  final RecoverPasswordViewModel _viewModel  = instance<RecoverPasswordViewModel>();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey<FormState>();

  bool visible = true;

  void _bind() {
    _viewModel.start();
    _emailController.addListener(
          () =>
          _viewModel.setEmail(
            _emailController.text,
          ),
    );
    _viewModel.isUserLoginSuccessfullyStreamController.stream
        .listen((isLoading) {
      if (isLoading) {
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
        stream: _viewModel.outputState,
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
    return Padding(
      padding: EdgeInsets.all(AppPadding.p16.w),
      child: Form(
        key: _globalKey,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                AppStrings.splashTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),
              SizedBox(
                height: AppSize.s35.h,
              ),
              Text(
                AppStrings.recoverPasswordTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineLarge,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: AppPadding.p14.h,
                  bottom: AppPadding.p28.h,
                ),
                child: Text(
                  AppStrings.recoverPasswordSubTitle,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium,
                ),
              ),
              customTextFormField(
                stream: _viewModel.outEmailIsValid,
                textEditingController: _emailController,
                hintText: AppStrings.email,
              ),
              const Spacer(
                flex: 1,
              ),
              customElevatedButton(
                stream: _viewModel.outAreAllInputValid,
                onPressed: () {
                  _viewModel.sendEmail();
                },
                text: AppStrings.submit,
              ),
              const SizedBox(
                height: AppSize.s10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontHaveAnAccount,
                    style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall,
                  ),
                  textButton(
                    context: context,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, Routes.registerScreen);
                    },
                    text: "Join In",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}