import 'dart:io';

import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/add_new_exercise/view.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/exercises/view_model.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({super.key});
  static const String routeName = 'Exercises';
  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  final ExercisesViewModel _viewModel = instance<ExercisesViewModel>();
  final TextEditingController _searchEditingController =
      TextEditingController();

  bind() {
    _viewModel.start();
    _searchEditingController.addListener(() {
      _viewModel.setSearch(_searchEditingController.text);
    });
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
    );
    String path = result!.path;

    // Create a File object using the path
    File imageFile = File(path);

    return imageFile;
  }

  @override
  void initState() {
    bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.exercises,
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
      floatingActionButton:  FloatingActionButton(
        backgroundColor: ColorManager.primary,
        onPressed: () {
          initAddNewExerciseModule();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddNewExercise(
                        categories: _viewModel.exercisesData,
                      ))).then((value) {
            if (value != null && value == true) {
              bind();
            }
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _getContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
      child: RefreshIndicator(
        color: ColorManager.primary,
        onRefresh: () async {
          bind();
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p14.h),
              child: StreamBuilder<String?>(
                stream: _viewModel.outputSearch,
                builder: (context, snapshot) => TextFormField(
                  style: getLightStyle(
                    color: ColorManager.simiBlue,
                    fontSize: FontSize.s16,
                  ),
                  controller: _searchEditingController,
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    errorText: snapshot.data,
                    suffixIcon: const Icon(
                      Icons.search,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<CategoryData>>(
                stream: _viewModel.outFilteredMap,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final CategoryData category = snapshot.data![index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: ColorManager.grey,
                                  padding: EdgeInsets.symmetric(
                                      vertical: AppPadding.p12.h),
                                  child: Text(
                                    snapshot.data![index].categoryName
                                        .toUpperCase(),
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: category.exercises.isEmpty
                                      ? 0
                                      : category.exercises.length,
                                  itemBuilder: (context, index) {
                                    final ExerciseData exercise =
                                        category.exercises[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onLongPress: () {
                                          // _viewModel.inputState
                                          //     .add(DeleteState(retryAction: () {
                                          //   _viewModel.delete(key, value);
                                          // }));
                                        },
                                        onTap: () {
                                          Navigator.pop(context,
                                               exercise);
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: AppSize.s32,
                                              backgroundColor:
                                                  ColorManager.primary,
                                              child: CircleAvatar(
                                                radius: AppSize.s30,
                                                foregroundImage: exercise
                                                        .exerciseImage
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                        exercise.exerciseImage)
                                                    : const AssetImage(
                                                            ImageAssets
                                                                .trainingImage)
                                                        as ImageProvider,
                                              ),
                                            ),
                                            SizedBox(
                                              width: AppSize.s14.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                exercise.exerciseName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        )
                      : const SizedBox();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
