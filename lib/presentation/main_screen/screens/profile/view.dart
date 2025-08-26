import 'dart:io';

import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/constant.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/main_screen/screens/profile/view_model.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final ProfileViewModel _viewModel = instance<ProfileViewModel>();

  @override
  void initState() {
    _viewModel.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StateFlow>(
      stream: _viewModel.outputState,
      builder: (context, snapshot) =>
      snapshot.data?.getScreenWidget(
        context,
        _getContent(),
      ) ??
          _getContent(),
    );
  }

  Widget _getContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.profile,
                style: Theme
                    .of(context)
                    .textTheme
                    .labelLarge,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: AppSize.s20.h,
                      ),
                      Visibility(
                        visible: !(_appPreferences.getLoginMethod() ==
                            LoginMethod.anonymous.name),
                        child: Center(
                          child: CircleAvatar(
                            minRadius: 55,
                            backgroundColor: ColorManager.primary,
                            child: StreamBuilder<TraineeData>(
                                stream: _viewModel.outData,
                                builder: (context, snapshot) {
                                  return CircleAvatar(
                                    radius: 52,
                                    backgroundImage: (snapshot.data != null &&
                                        snapshot.data!.photo.isNotEmpty)
                                        ? NetworkImage(snapshot.data!.photo)
                                        : const AssetImage(
                                      ImageAssets.personal,
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !(_appPreferences.getLoginMethod() ==
                            LoginMethod.anonymous.name),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppPadding.p8.h),
                            child: StreamBuilder<TraineeData>(
                                stream: _viewModel.outData,
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data != null
                                        ? snapshot.data!.traineeName as String? ??
                                        ""
                                        : '',
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .labelMedium,
                                  );
                                }),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.s20.h,
                      ),
                      Visibility(
                        visible: !(_appPreferences.getLoginMethod() ==
                            LoginMethod.anonymous.name),
                        child: customListTile(
                          'Profile Detail',
                          Icons.person,
                              () {
                            Navigator.pushNamed(
                              context,
                              Routes.profileDetailsScreen,
                            ).then((value) => _viewModel.start());
                          },
                        ),
                      ),
                      SizedBox(
                        height: AppSize.s40.h,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Divider(
                            thickness: 3,
                            color: ColorManager.grey,
                          ),
                        ),
                      ),
                      customListTile(
                        'privacy policy',
                        Icons.privacy_tip,
                            () {
                          Navigator.pushNamed(context, Routes.privacyScreen);
                        },
                      ),
                      SizedBox(
                        height: AppSize.s20.h,
                      ),
                      Visibility(
                        visible: !(_appPreferences.getLoginMethod() ==
                            LoginMethod.anonymous.name),
                        child: customListTile(
                          "Delete Account",
                          Icons.delete,
                              () {
                            _viewModel.inputState
                                .add(DeleteState(retryAction: () {
                              _viewModel.deleteAccount().then((value) {
                                Navigator.pushReplacementNamed(
                                    context, Routes.loginScreen);
                              });
                              _viewModel.inputState.add(ContentState());
                            }, onCancel: () {
                              _viewModel.inputState.add(ContentState());
                            }));
                          },
                        ),
                      ),
                      SizedBox(
                        height: AppSize.s20.h,
                      ),
                      Visibility(
                        visible: !(_appPreferences.getLoginMethod() ==
                            LoginMethod.anonymous.name),
                        child: customListTile(
                          'Logout',
                          Icons.logout_outlined,
                              () {
                            _viewModel.logout().then((value) {
                              Navigator.pushReplacementNamed(
                                  context, Routes.loginScreen);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customListTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.grey,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListTile(
        onTap: onTap,
        minLeadingWidth: 40,
        minVerticalPadding: 20,
        leading: CircleAvatar(
          backgroundColor: ColorManager.white,
          child: Icon(
            icon,
            color: ColorManager.primary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ColorManager.simiBlack,
        ),
        title: Text(
          title,
          style: Theme
              .of(context)
              .textTheme
              .labelMedium,
        ),
      ),
    );
  }

  Widget _personPicketByUser(File? image) {
    if (image != null && image.path.isNotEmpty) {
      return Image.file(
        image,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        ImageAssets.personal,
        fit: BoxFit.cover,
      );
    }
  }
}
