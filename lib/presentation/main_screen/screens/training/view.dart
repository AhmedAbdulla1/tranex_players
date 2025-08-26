// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/bluetooth/BluetoothDeviceListEntry.dart';
import 'package:firesport_users/presentation/main_screen/screens/training/widgets/weight_section.dart';
import 'package:firesport_users/presentation/main_screen/screens/training/widgets/weight_selector.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firesport_users/presentation/main_screen/screens/training/view_model.dart';
import '../../../resources/font_manager.dart';

class TrainingView extends StatefulWidget {
  const TrainingView({super.key});

  @override
  State<TrainingView> createState() => _TrainingViewState();
}

class _TrainingViewState extends State<TrainingView> {
  final TrainingViewModel _viewModel = TrainingViewModel();
  bool isDiscovering = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _viewModel.start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StateFlow>(
      stream: _viewModel.outputState,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Center( // توسيط المحتوى أفقيًا
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500), // أقصى عرض 500
              child: Padding(
                padding: EdgeInsets.all(AppPadding.p16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: AppSize.s14.h),
                    _buildExerciseImage(context),
                    SizedBox(height: AppSize.s14.h),
                    _buildExerciseSelection(context),
                    SizedBox(height: AppSize.s14.h),
                    _buildConnectButton(),
                    SizedBox(height: AppSize.s14.h),
                    StreamBuilder<DeviceData>(
                      stream: _viewModel.outDeviceType,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.accessories.isNotEmpty) {
                            return WeightSection(
                              onWeightChanged: (num) =>
                                  _viewModel.setWeight(num.toDouble()),
                              deviceDataStream: _viewModel.outDeviceType,
                            );
                          } else {
                            return const SizedBox();
                          }
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    _buildAdvancedSettings(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Text(
        'Training',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
  Widget _buildExerciseImage(BuildContext context) {
    // تحديد إذا كان الجهاز في وضع Portrait أو Landscape
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // حساب أبعاد الصورة بناءً على الـ Orientation
    final double imageHeight = isLandscape
        ? MediaQuery.of(context).size.width * 0.2 // ربع العرض في وضع Landscape
        : MediaQuery.of(context).size.height * 0.25; // ربع الارتفاع في وضع Portrait

    return StreamBuilder<String>(
      stream: _viewModel.outImage,
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;
        final isImageUrlValid = imageUrl != null &&
            imageUrl.isNotEmpty &&
            imageUrl != ImageAssets.trainingImage;

        return isImageUrlValid
            ? Image.network(
          imageUrl,
          height: imageHeight,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Image.asset(
            ImageAssets.trainingImage,
            fit: BoxFit.fitWidth,
            height: imageHeight,
            width: double.infinity,
          ),
        )
            : Image.asset(
          ImageAssets.trainingImage,
          fit: BoxFit.fitWidth,
          height: imageHeight,
          width: double.infinity,
        );
      },
    );
  }
  Widget _buildExerciseSelection(BuildContext context) {
    return StreamBuilder<String>(
      stream: _viewModel.outExercise,
      builder: (context, snapshot) {
        return _buildSelectionTile(
          context,
          title: snapshot.data ?? "Select Exercise",
          onTap: () async {
            final value = await Navigator.pushNamed(
              context,
              Routes.exercisesScreen,
            );
            if (value is ExerciseData) {
              _viewModel.setExercise(value.exerciseName);
              _viewModel.setImage(value.exerciseImage);
              _viewModel.getDeviceTypeData(value.deviceId);
              _viewModel.setTraining(exercise: value);
            }
          },
        );
      },
    );
  }

  Widget _buildSelectionTile(
      BuildContext context, {
        required String title,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.simiBlack, width: 1),
        borderRadius: BorderRadius.circular(AppSize.s8.r),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.keyboard_arrow_down_outlined),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      child: StreamBuilder<bool>(
        stream: _viewModel.outTrainerDataIsRight,
        initialData: false,
        builder: (context, snapshot) {
          print(snapshot.data);
          return SizedBox(
            width: double.infinity,
            height: AppSize.s55.h,
            child: ElevatedButton(
              onPressed: snapshot.data ?? false
                  ? () async {
                _viewModel.setTraining();
                _viewModel.showBluetoothDialog(context);
              }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.bluetooth_audio_sharp),
                  Text(
                    "Connect to Device",
                    style: TextStyle(
                      color: snapshot.data ?? false
                          ? ColorManager.white
                          : ColorManager.black,
                      fontSize: FontSize.s16,
                      fontWeight: FontWeightManager.medium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    int idleTime = 3;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: ColorManager.grey,
          padding: EdgeInsets.symmetric(vertical: AppPadding.p12.h),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Text(
              AppStrings.advanced,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
        ListTile(
          title: Text(
            AppStrings.autoStart,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          trailing: StreamBuilder<bool>(
            stream: _viewModel.outAutoStart,
            builder: (context, snapshot) {
              return Switch(
                activeColor: ColorManager.primary,
                activeTrackColor: ColorManager.starActive,
                value: snapshot.data ?? true,
                onChanged: (value) {
                  _viewModel.setAutostart(value);
                },
              );
            },
          ),
        ),
        ListTile(
          title: Text(
            AppStrings.idleTime,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (idleTime > 3) {
                    idleTime--;
                    _viewModel.setIdleTime(idleTime);
                  }
                },
              ),
              StreamBuilder<int>(
                stream: _viewModel.outIdleTime,
                builder: (context, snapshot) {
                  idleTime = snapshot.data ?? 3;
                  return Text(
                    idleTime.toString(),
                    style: Theme.of(context).textTheme.labelMedium,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (idleTime < 10) {
                    idleTime++;
                    _viewModel.setIdleTime(idleTime);
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.s14.h),
      ],
    );
  }
}