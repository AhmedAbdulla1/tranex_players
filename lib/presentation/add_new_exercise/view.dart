import 'dart:io';

import 'package:tranex_users/app/constant.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/add_new_exercise/view_model.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AddNewExercise extends StatefulWidget {
  const AddNewExercise({super.key, required this.categories});
  final List<CategoryData> categories;

  @override
  State<AddNewExercise> createState() => _AddNewExerciseState();
}

class _AddNewExerciseState extends State<AddNewExercise> {
  final AddNewExerciseViewModel _viewModel = AddNewExerciseViewModel();
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? imageFile;
  late Uint8List exerciseImage;
  late CategoryData category;

  setDefaultImage() async {
    ByteData data = await rootBundle.load(ImageAssets.trainingImage);
    exerciseImage = Uint8List.view(data.buffer);
  }

  Future fileToUint8List(File? file) async {
    if (file != null) {
      imageFile = file;
      List<int> bytes = await file.readAsBytes();
      exerciseImage = Uint8List.fromList(bytes);
    }
  }

  bind() {
    _viewModel.categoriesData = widget.categories;
    _viewModel.start();
    _categoryController.addListener(() {
      _viewModel.setNewCategory(_categoryController.text);
    });
    _exerciseNameController.addListener(() {
      _viewModel.setNewExercise(_exerciseNameController.text);
    });
  }

  @override
  void initState() {
    bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: const Text(
          'Add New Exercise',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 30.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.s8.r),
                  ),
                  child: Stack(
                    children: [
                      StreamBuilder<File?>(
                        stream: _viewModel.outAddImage,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            _viewModel.setImage(snapshot.data);
                          }
                          return _personPicketByUser(snapshot.data);
                        },
                      ),
                      Positioned(
                        bottom: AppSize.s12.w,
                        right: AppSize.s12.w,
                        child: CircleAvatar(
                          minRadius: 22.r,
                          backgroundColor: ColorManager.white,
                          child: CircleAvatar(
                            maxRadius: AppSize.s20.r,
                            backgroundColor: ColorManager.primary,
                            child: IconButton(
                              splashColor: ColorManager.white,
                              onPressed: () {
                                _imageFromGallery();
                              },
                              icon: Icon(
                                Icons.edit,
                                size: AppSize.s18,
                                color: ColorManager.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),
                Text(
                  "Category ",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: 16.0.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<CategoryData>(
                        stream: _viewModel.outCategory,
                        builder: (context, snapshot) {
                          return Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 50,
                              child: DropdownButton<CategoryData?>(
                                value: snapshot.data ??
                                    _viewModel.categoriesData.firstOrNull,
                                onChanged: (CategoryData? newValue) {
                                  if (newValue == null) return;
                                  _viewModel.setCategory(newValue);
                                },
                                isExpanded: true,
                                iconSize: 35.r,
                                borderRadius: BorderRadius.circular(AppSize.s12),
                                items: _viewModel.categoriesData
                                    .map<DropdownMenuItem<CategoryData>>(
                                        (CategoryData value) {
                                      return DropdownMenuItem<CategoryData>(
                                        value: value,
                                        child: Text(value.categoryName),
                                      );
                                    }).toList(),
                              ),
                            ),
                          );
                        }),
                    SizedBox(
                      width: AppSize.s14.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: AppSize.s40.h,
                        child: ElevatedButton(
                          onPressed: () {
                            _showAddNewCategorySheet();
                          },
                          child: Icon(
                            Icons.add,
                            color: ColorManager.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Device Type ',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SizedBox(
                      width: AppSize.s14.w,
                    ),
                    StreamBuilder<DeviceData>(
                        stream: _viewModel.outputDeviceType,
                        builder: (context, snapshot) {
                          return Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 50,
                              child: DropdownButton<DeviceData?>(
                                value: snapshot.data ?? _viewModel.devices.firstOrNull,
                                onChanged: (DeviceData? deviceData) {
                                  _viewModel.setDeviceType(deviceData);
                                },
                                isExpanded: true,
                                iconSize: 35.r,
                                borderRadius: BorderRadius.circular(AppSize.s12),
                                items: _viewModel.devices
                                    .map<DropdownMenuItem<DeviceData>>(
                                        (DeviceData value) {
                                      return DropdownMenuItem<DeviceData>(
                                        value: value,
                                        child: Text(value.deviceName),
                                      );
                                    }).toList(),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
                const SizedBox(height: 16.0),
                customTextFormField(
                  stream: _viewModel.outExerciseName,
                  textEditingController: _exerciseNameController,
                  hintText: 'Exercise Name',
                ),
                const SizedBox(height: AppSize.s65),
                customElevatedButton(
                  stream: _viewModel.outputExerciseNameRight,
                  onPressed: () {
                    _viewModel.addNewExercise(context);
                  },
                  text: 'ADD',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddNewCategorySheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AppSize.s20,
            ),
          ),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                customTextFormField(
                  stream: _viewModel.outCategoryValid,
                  textEditingController: _categoryController,
                  hintText: 'Category Name',
                ),
                const SizedBox(height: 16.0),
                customElevatedButton(
                  stream: _viewModel.outputCategoryNameRight,
                  onPressed: () {
                    category = CategoryData(
                        categoryName: _categoryController.text,
                        categoryId: 0,
                        exercises: []);
                    _viewModel.addNewCategory(category);
                    Navigator.pop(context);
                  },
                  text: 'ADD',
                ),
              ],
            ),
          );
        });
  }

  _imageFromGallery() async {
    var image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    _viewModel.inputImage.add(File(image?.path ?? ""));
  }

  Widget _personPicketByUser(File? image) {
    if (image != null && image.path.isNotEmpty) {
      return Image.file(
        image,
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      );
    } else {
      return Image.asset(
        ImageAssets.trainingImage,
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      );
    }
  }
}