import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/core/storage/hive_keys.dart';
import 'package:tranex_users/core/storage/hive_manager.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view.dart';
import 'package:tranex_users/presentation/main_screen/screens/profile/view_model.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/routes_manager.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
          constraints: const BoxConstraints(maxWidth: 500),
          child: ValueListenableBuilder(
            valueListenable: HiveManager.userDataBox
                .listenable(keys: [HiveKeys.userDataKey]),
            builder: (context, Box box, _) {
              final traineeData = box.get(HiveKeys.userDataKey) as TraineeData?;
              log("Trainee data in profile is ${traineeData?.toJson()}");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.profile,
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppSize.s20.h),
                          Center(
                            child: CircleAvatar(
                              minRadius: 55,
                              backgroundColor: ColorManager.primary,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundImage: traineeData != null &&
                                        traineeData.photo.isNotEmpty
                                    ? NetworkImage(traineeData.photo)
                                    : const AssetImage(ImageAssets.personal)
                                        as ImageProvider,
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppPadding.p8.h),
                              child: Text(
                                traineeData?.traineeName ?? 'User',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          20.verticalSpace,
                          customListTile(
                            'Profile Detail',
                            Icons.person,
                            () {
                              Navigator.pushNamed(
                                context,
                                Routes.profileDetailsScreen,
                              );
                            },
                          ),
                          20.verticalSpace,
                          customListTile(
                            'Go to Fencing',
                            Icons.sports_kabaddi_rounded,
                            () {
                              Navigator.pushNamed(
                                  context, FencingMatchView.routeName);
                            },
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
                            'Privacy Policy',
                            Icons.privacy_tip,
                            () {
                              Navigator.pushNamed(
                                  context, Routes.privacyScreen);
                            },
                          ),
                          SizedBox(height: AppSize.s20.h),
                          customListTile(
                            "Delete Account",
                            Icons.delete,
                            () {
                              _viewModel.inputState.add(
                                DeleteState(
                                  retryAction: () {
                                    _viewModel.deleteAccount().then((_) {
                                      Navigator.pushReplacementNamed(
                                          context, Routes.loginScreen);
                                    });
                                    _viewModel.inputState.add(ContentState());
                                  },
                                  onCancel: () {
                                    _viewModel.inputState.add(ContentState());
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppSize.s20.h),
                          customListTile(
                            'Logout',
                            Icons.logout_outlined,
                            () {
                              _viewModel.logout().then((_) {
                                Navigator.pushReplacementNamed(
                                    context, Routes.loginScreen);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
        splashColor: ColorManager.white,
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
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
