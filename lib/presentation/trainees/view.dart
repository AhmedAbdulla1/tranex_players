import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:tranex_users/presentation/trainees/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrainersView extends StatefulWidget {
  const TrainersView({Key? key}) : super(key: key);
  static const String routeName = '/trainees';
  @override
  State<TrainersView> createState() => _TrainersViewState();
}

class _TrainersViewState extends State<TrainersView> {
  final TraineesViewModel _viewModel = TraineesViewModel();
  final TextEditingController _searchEditingController =
      TextEditingController();

  late Uint8List exerciseImage;
  late String category;

  bind() {
    _viewModel.start();
    _searchEditingController.addListener(() {
      _viewModel.setSearch(_searchEditingController.text);
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
      appBar: AppBar(
        title: const Text(
          "Trainees",
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
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
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
                  hintText: 'Search',
                  errorText: snapshot.data,
                  suffixIcon: const Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TraineeData>>(
              stream: _viewModel.outFilteredData,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (snapshot.data?.length != null &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.data!.isNotEmpty) {
                      TraineeData trainee = snapshot.data![index];
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: InkWell(
                          onLongPress: () {
                            _viewModel.inputState
                                .add(DeleteState(retryAction: () {
                              // _viewModel.delete(key, value);
                            }, onCancel: (){}));
                          },
                          onTap: () {
                            Navigator.pop(context,  trainee);
                          },
                          child:
                          Row
                            (
                            children: [
                              CircleAvatar(
                                radius: AppSize.s32,
                                backgroundColor:
                                ColorManager.primary,
                                child: CircleAvatar(
                                  radius: AppSize.s30,
                                  foregroundImage: trainee.photo
                                      .isNotEmpty
                                      ? NetworkImage(
                                      trainee.photo)
                                      : const AssetImage(
                                      ImageAssets
                                          .trainingImage)
                                  as ImageProvider,
                                ),
                              ),
                              SizedBox(
                                width: AppSize.s14,
                              ),
                              Expanded(
                                child: Text(
                                  trainee.traineeName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     SizedBox(
                          //       width: AppSize.s14.w,
                          //     ),
                          //     Expanded(
                          //       child: Text(
                          //         trainee.traineeName,
                          //         style:
                          //             Theme.of(context).textTheme.labelMedium,
                          //         overflow: TextOverflow.ellipsis,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No Trainers Available',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
