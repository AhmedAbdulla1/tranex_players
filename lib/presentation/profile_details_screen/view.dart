import 'dart:io';

import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/presentation/common/reusable/custom_button.dart';
import 'package:firesport_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

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
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final ProfileDetailsViewModel _viewModel =
      instance<ProfileDetailsViewModel>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _bind() {
    _viewModel.start();
    _nameController.addListener(() => _viewModel.setName(_nameController.text));
  }

  @override
  void initState() {
    _bind();
    super.initState();
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
      // Show the new image picked by the user
      return Image.file(
        localImage,
        fit: BoxFit.fill,
      );
    } else if (_viewModel.imagePath != null &&
        _viewModel.imagePath!.isNotEmpty) {
      // Show the existing network image if available
      return Image.network(
        _viewModel.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default image if the network image fails to load
          return Image.asset(
            ImageAssets.personal,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Show the default placeholder image
      return Image.asset(
        ImageAssets.personal,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _getContent() {
    return StreamBuilder(
      stream: _viewModel.outputData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _nameController.text = _viewModel.signupObject.name;
          _emailController.text = _viewModel.signupObject.email;
        }
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
              SizedBox(
                height: AppSize.s35.h,
              ),
              customRow(
                AppStrings.name,
                _viewModel.outNameIsValid,
                _nameController,
              ),
              SizedBox(height: AppSize.s14.h),
              // Row(
              //   children: [
              //     Text(
              //       AppStrings.email,
              //       style: Theme.of(context).textTheme.labelSmall,
              //     ),
              //     const SizedBox(
              //       width: AppSize.s14,
              //     ),
              //     Expanded(
              //       child: TextFormField(
              //         enabled: false,
              //         style: getLightStyle(
              //           color: ColorManager.simiBlue,
              //           fontSize: FontSize.s16,
              //         ),
              //         keyboardType: TextInputType.emailAddress,
              //         controller: _emailController,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height:200.h),
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
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget customRow(String text, Stream<String?> stream,
      TextEditingController textEditingController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(
          width: AppSize.s14,
        ),
        Expanded(
          child: SizedBox(
            width: 200,
            child: customTextFormField(
                stream: stream,
                textEditingController: textEditingController,
                hintText: ''),
          ),
        ),
      ],
    );
  }
}
