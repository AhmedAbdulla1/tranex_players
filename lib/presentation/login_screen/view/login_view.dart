import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/login_screen/view_model/login_view_model.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/routes_manager.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final LoginViewModel _loginViewModel = instance<LoginViewModel>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey<FormState>();
  bool visible = true;

  void _bind() {
    _loginViewModel.start();
    _emailController.addListener(
      () => _loginViewModel.setEmail(
        _emailController.text,
      ),
    );
    _passwordController.addListener(
      () => _loginViewModel.setPassword(
        _passwordController.text,
      ),
    );
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
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 500), // Max width set to 500
        child: SizedBox(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppPadding.p16.w),
                child: Form(
                  key: _globalKey,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/images/splash.jpeg",
                            height: 150.h,
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
                        customTextFormField(
                          stream: _loginViewModel.outEmailIsValid,
                          textEditingController: _emailController,
                          hintText: AppStrings.email,
                        ),
                        const SizedBox(height: AppSize.s14),
                        customPasswordFormField(
                          stream1: _loginViewModel.outPasswordIsValid,
                          stream2: _loginViewModel.outPasswordIsVisible,
                          textEditingController: _passwordController,
                          onPressed: () {
                            visible = !visible;
                            _loginViewModel.setVisibility(visible);
                          },
                        ),
                        const SizedBox(
                          height: AppSize.s20,
                        ),
                        customElevatedButton(
                          stream: _loginViewModel.outAreAllInputValid,
                          onPressed: () {
                            _loginViewModel.login();
                          },
                          text: AppStrings.login,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: textButton(
                            context: context,
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, Routes.recoverPasswordScreen);
                            },
                            text: AppStrings.forgotPassword,
                          ),
                        ),
                        20.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 2,
                                color: ColorManager.grey,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontFamily: FontConstants.fontFamily,
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeightManager.regular,
                                  color: ColorManager.simiBlue,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 2,
                                color: ColorManager.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize.s30.h),
                        InkWell(
                          splashColor: ColorManager.white,
                          onTap: () {
                            _loginViewModel.loginWithGoogle();
                          },
                          child: Container(
                            height: AppSize.s55.h,
                            decoration: BoxDecoration(
                              color: ColorManager.grey,
                              borderRadius: BorderRadius.circular(
                                AppSize.s12.r,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: AppSize.s28.w,
                                ),
                                SvgPicture.asset(
                                  ImageAssets.google,
                                ),
                                Expanded(
                                  child: Text(
                                    AppStrings.google,
                                    style: getMediumStyle(
                                        fontSize: FontSize.s16,
                                        color: ColorManager.black),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(height: AppSize.s14.h),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       AppStrings.dontHaveAnAccount,
                        //       style: Theme.of(context).textTheme.labelSmall,
                        //     ),
                        //     textButton(
                        //       context: context,
                        //       onPressed: () {
                        //         Navigator.pushNamed(
                        //             context, Routes.registerScreen);
                        //       },
                        //       text: "Sign Up",
                        //       buttonStyle: Theme.of(context)
                        //           .textTheme
                        //           .bodyLarge
                        //           ?.copyWith(
                        //             color: ColorManager.black,
                        //             fontWeight: FontWeightManager.medium,
                        //           ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: AppSize.s14.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContinueAsGuest extends StatelessWidget {
  const ContinueAsGuest({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorManager.primary,
        borderRadius: BorderRadius.circular(
          AppSize.s12.r,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          AppStrings.guest,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ColorManager.white,
                fontWeight: FontWeightManager.bold,
              ),
        ),
      ),
    );
  }
}
