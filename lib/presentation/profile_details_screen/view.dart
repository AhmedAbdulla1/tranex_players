import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/app/toast.dart';
import 'package:tranex_users/core/storage/hive_boxes.dart';
import 'package:tranex_users/core/storage/hive_keys.dart';
import 'package:tranex_users/core/storage/hive_manager.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/string_manager.dart';
import '../resources/values_manager.dart';
import 'view_model.dart';

class ProfileDetailsView extends StatefulWidget {
  const ProfileDetailsView({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsView> createState() => _ProfileDetailsViewState();
}

class _ProfileDetailsViewState extends State<ProfileDetailsView> {
  final ProfileDetailsViewModel _viewModel =
      instance<ProfileDetailsViewModel>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  TraineeData? traineeData;

  void _bind() {
    _viewModel.start();
    _nameController.addListener(() => _viewModel.setName(_nameController.text));
  }

  @override
  void initState() {
    super.initState();
    _bind();

    // ✅ هات الداتا من هايف
    traineeData = HiveManager.get(
      boxName: HiveBoxes.userDataBox,
      key: HiveKeys.userDataKey,
    );

    if (traineeData != null) {
      _nameController.text = traineeData!.traineeName;
      _emailController.text = traineeData!.traineeName;
      _viewModel.setName(traineeData!.traineeName);
      _viewModel.imagePath = traineeData!.photo;
    }

    log("Profile details traineeData: ${traineeData?.toJson()}");
  }

  Future<void> showConnectDialog(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Connect to Head Coach",
            style:
                getBoldStyle(fontSize: FontSize.s20, color: ColorManager.black),
          ),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: "Enter Code",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: getRegularStyle(
                    fontSize: FontSize.s16, color: ColorManager.simiBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isEmpty) {
                  ShowToast.showError("Please enter a code");
                  return;
                }

                log("Connecting with code: $code");

                Navigator.of(context).pop(code);
                _viewModel.connectToHeadCoach(code);
              },
              child: Text(
                "Connect",
                style: getRegularStyle(
                    fontSize: FontSize.s16, color: ColorManager.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Details',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: ColorManager.white),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: ColorManager.white,
            )),
        centerTitle: false,
      ),
      body: StreamBuilder<StateFlow>(
          stream: _viewModel.outputState,
          builder: (context, snapshot) =>
              snapshot.data?.getScreenWidget(
                context,
                _getContent(),
              ) ??
              _getContent()),
    );
  }

  _showPicker(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppSize.s30,
          ),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: Text(
                  AppStrings.photoGallery,
                  style: TextStyle(color: ColorManager.primary),
                ),
                onTap: () {
                  _imageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                ),
                title: Text(
                  AppStrings.photoCamera,
                  style: TextStyle(
                    color: ColorManager.primary,
                  ),
                ),
                onTap: () {
                  _imageFromCamera();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  _imageFromGallery() async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    _viewModel.setProfilePicture(File(image?.path ?? ""));
  }

  _imageFromCamera() async {
    var image = await _imagePicker.pickImage(source: ImageSource.camera);
    _viewModel.setProfilePicture(File(image?.path ?? ""));
  }

  Widget _personPicketByUser(File? localImage) {
    if (localImage != null && localImage.path.isNotEmpty) {
      return Image.file(localImage, fit: BoxFit.fill);
    } else if (_viewModel.imagePath != null &&
        _viewModel.imagePath!.isNotEmpty) {
      return Image.network(
        _viewModel.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(ImageAssets.personal, fit: BoxFit.cover);
        },
      );
    } else {
      return Image.asset(ImageAssets.personal, fit: BoxFit.cover);
    }
  }

  Widget _getContent() {
    return Padding(
      padding: EdgeInsets.all(AppPadding.p16.w),
      child: ListView(
        children: [
          Stack(
            children: [
              StreamBuilder<File>(
                stream: _viewModel.profilePictureOutput,
                builder: (context, snapshot) {
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    width: double.infinity,
                    height: 200.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: _personPicketByUser(_viewModel.image),
                  );
                },
              ),
              Positioned(
                bottom: AppSize.s12.w,
                right: AppSize.s12.w,
                child: CircleAvatar(
                  minRadius: AppSize.s18.r,
                  backgroundColor: ColorManager.white,
                  child: CircleAvatar(
                    maxRadius: AppSize.s16.r,
                    backgroundColor: ColorManager.primary,
                    child: IconButton(
                      splashColor: ColorManager.white,
                      onPressed: () {
                        _showPicker(context);
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: AppSize.s14,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: AppSize.s35.h),
          customRow(
              AppStrings.name, _viewModel.outNameIsValid, _nameController),
          SizedBox(height: AppSize.s14.h),
          Row(
            children: [
              Text(AppStrings.email,
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: AppSize.s14),
              Expanded(
                child: TextFormField(
                  enabled: false,
                  style: getLightStyle(
                    color: ColorManager.simiBlue,
                    fontSize: FontSize.s18,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),
            ],
          ),
          14.verticalSpace,
          ElevatedButton.icon(
            icon: const Icon(Icons.signal_cellular_alt_2_bar_rounded,
                color: Colors.white, size: 24),
            onPressed: () {
              showConnectDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.simiBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            label: Text(
              "Connect to Head Coach",
              style:
                  getMediumStyle(fontSize: FontSize.s16, color: Colors.white),
            ),
          ),
          SizedBox(height: 200.h),
          customElevatedButtonWithoutStream(
            onPressed: () {
              _viewModel.updateProfile(context).then((value) {
                _viewModel.inputState.add(SuccessState("Update Successfully"));
                Future.delayed(const Duration(seconds: 1), () {
                  _viewModel.inputState.add(ContentState());
                });
              });
            },
            child: const Text(
              AppStrings.updateProfile,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget customRow(String text, Stream<String?> stream,
      TextEditingController textEditingController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: AppSize.s14),
        Expanded(
          child: SizedBox(
            width: 200,
            child: customTextFormField(
              stream: stream,
              textEditingController: textEditingController,
              hintText: '',
            ),
          ),
        ),
      ],
    );
  }
}
