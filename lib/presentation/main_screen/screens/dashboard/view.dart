import 'dart:math';

import 'package:firesport_users/presentation/matches_screen/view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/app/extensions.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/main_screen/screens/dashboard/view_model.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/routes_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bind() {
    _viewModel.start();
  }

  @override
  void initState() {
    bind();
    super.initState();
  }

  final DashboardViewModel _viewModel = instance<DashboardViewModel>();

  bool training = false;
  bool progress = false;

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

  TraineeData? trainee;

  String exercise = '';
  bool weekly = true;

  Widget _getContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.p18.w),
        child: Center(
          // إضافة Center عشان المحتوى يبقى مركز في الـ Landscape Mode
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500, // تحديد أقصى عرض للمحتوى بـ 500 بكسل
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<TraineeData>(
                  stream: _viewModel.outputDashboard,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                       return _getAppBar(
                              snapshot.data!.traineeName,
                              snapshot.data!.photo,
                            );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(
                  height: AppSize.s14.h,
                ),
                SizedBox(
                  height: AppSize.s14.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: ColorManager.grey3,
                      border:
                          Border.all(color: ColorManager.simiBlack, width: 1),
                      borderRadius: BorderRadius.circular(AppSize.s8.r)),
                  child: StreamBuilder<String>(
                      stream: _viewModel.outExercise,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          exercise = snapshot.data!;
                          _viewModel.setTraineeData(trainee, weekly: weekly);
                        }
                        return ListTile(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              Routes.exercisesScreen,
                            ).then((value) {
                              if (value != null && value is ExerciseData) {
                                _viewModel.setExercise(value);
                              }
                            });
                          },
                          trailing: const Icon(
                            Icons.keyboard_arrow_right_outlined,
                          ),
                          splashColor: Colors.transparent,
                          title: Text(
                            snapshot.data ?? "Select Exercise",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: AppSize.s14.h,
                ),
                StreamBuilder<TraineeData>(
                    stream: _viewModel.outTrainee,
                    builder: (context, snapshot) {
                      return Visibility(
                        visible: snapshot.data?.isFencer ?? false,
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorManager.grey3,
                              border: Border.all(
                                  color: ColorManager.simiBlack, width: 1),
                              borderRadius:
                                  BorderRadius.circular(AppSize.s8.r)),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                               MatchesView.routeName,
                               arguments: snapshot.data,
                              );
                            },
                            trailing: const Icon(
                              Icons.keyboard_arrow_right_outlined,
                            ),
                            splashColor: Colors.transparent,
                            title: Text(
                              "Go To Matches",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: AppSize.s14.h,
                ),
                Container(
                  padding: const EdgeInsets.all(AppPadding.p10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorManager.simiBlue,
                    ),
                    color: ColorManager.grey3,
                    borderRadius: BorderRadius.circular(
                      AppSize.s12.r,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progression",
                            style: getSemiBoldStyle(
                              fontSize: FontSize.s24,
                              color: const Color(
                                0xffC4AE8A,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.s10.h,
                      ),
                      Row(
                        children: [
                          SizedBox(
                              height: AppSize.s28,
                              child: StreamBuilder<bool>(
                                  stream: _viewModel.outputProgressButton,
                                  builder: (context, snapshot) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        progress = true;
                                        weekly = true;
                                        _viewModel.setTraineeData(trainee,
                                            weekly: weekly);
                                        _viewModel.setProgressButton(progress);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: snapshot.data ?? true
                                              ? ColorManager.primary
                                              : ColorManager.grey),
                                      child: Text(
                                        'weekly',
                                        style: getRegularStyle(
                                          fontSize: FontSize.s14,
                                          color: snapshot.data ?? true
                                              ? ColorManager.white
                                              : ColorManager.simiBlack,
                                        ),
                                      ),
                                    );
                                  })),
                          SizedBox(
                            width: AppSize.s10,
                          ),
                          SizedBox(
                            height: AppSize.s28,
                            child: StreamBuilder<bool>(
                                stream: _viewModel.outputProgressButton,
                                builder: (context, snapshot) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      progress = false;
                                      weekly = false;
                                      _viewModel.setTraineeData(trainee,
                                          weekly: weekly);
                                      _viewModel.setProgressButton(progress);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: snapshot.data ?? false
                                            ? ColorManager.grey
                                            : ColorManager.primary),
                                    child: Text(
                                      'Monthly',
                                      style: getRegularStyle(
                                        fontSize: FontSize.s14,
                                        color: snapshot.data ?? false
                                            ? ColorManager.simiBlack
                                            : ColorManager.white,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.s10.h,
                      ),
                      Divider(
                        color: ColorManager.simiBlue,
                        indent: 0,
                      ),
                      StreamBuilder2<bool, Tuple<List<double>, List<double>>>(
                          streams: StreamTuple2(_viewModel.outputProgressButton,
                              _viewModel.outTrainerData),
                          builder: (context, snapshot) {
                            return StreamBuilder<bool>(
                                stream: _viewModel.outGetTraineeData,
                                builder: (context, snap) {
                                  if (!(snap.data ?? false)) {
                                    return LineChartView(
                                      weekly: snapshot.snapshot1.data ?? false,
                                      data: snapshot.snapshot2.data ??
                                          Tuple([0.0, 0, 0, 0, 0, 0],
                                              [0.0, 0, 0, 0, 0, 0]),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: 200.h,
                                      child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive(
                                        backgroundColor: ColorManager.primary,
                                      )),
                                    );
                                  }
                                });
                          }),
                      SizedBox(
                        height: AppSize.s10.h,
                      ),
                      Text(
                        "Training Volume",
                        style: getSemiBoldStyle(
                            fontSize: FontSize.s24,
                            color: const Color(0xffC4AE8A)),
                      ),
                      SizedBox(
                        height: AppSize.s10.h,
                      ),
                      Divider(
                        color: ColorManager.simiBlue,
                        indent: 0,
                      ),
                      StreamBuilder<TrainingData>(
                          stream: _viewModel.outputRepsData,
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                customColumn(
                                    value: (snapshot.data?.overAllSets ?? 0)
                                        .toString(),
                                    title: "Sets"),
                                customColumn(
                                    value: (snapshot.data?.overAllReps ?? 0)
                                        .toString(),
                                    title: "Reps"),
                                customColumn(
                                    value: (snapshot.data?.overAllTime ?? 0)
                                        .convertSecondsToHMS(),
                                    title: "Time"),
                              ],
                            );
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppSize.s14.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customColumn({required String value, required String title}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 43.r,
          backgroundColor: ColorManager.starActive,
          child: CircleAvatar(
            radius: 35.r,
            backgroundColor: ColorManager.grey3,
            child: AutoSizeText(
              value.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(
          height: AppSize.s10.h,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }

  Widget _getAppBar(String userName, String image) {
    return Container(
        padding: EdgeInsets.all(
          AppPadding.p10.h,
        ),
        decoration: BoxDecoration(
          color: ColorManager.grey3,
          border: Border.all(color: ColorManager.simiBlue),
          borderRadius: BorderRadius.circular(
            AppSize.s12.r,
          ),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            userName.substring(0, 1).toUpperCase() + userName.substring(1),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          CircleAvatar(
            radius: AppSize.s32,
            backgroundColor: ColorManager.primary,
            child: CircleAvatar(
              radius: AppSize.s30,
              foregroundImage: image.isEmpty
                  ? const AssetImage(
                      ImageAssets.personal,
                    )
                  : NetworkImage(
                      image,
                    ) as ImageProvider,
            ),
          ),
        ]));
  }
}

class LineChartView extends StatelessWidget {
  LineChartView({super.key, this.weekly = false, required this.data});

  final bool weekly;

  final Tuple<List<double>, List<double>> data;
  static List<Color> gradientColors = [
    ColorManager.starActive,
    ColorManager.simiBlue,
  ];
  static List<Color> gradientColors2 = [
    ColorManager.lightGreen,
    ColorManager.simiBlue,
  ];

  late double maxValue;

  @override
  Widget build(BuildContext context) {
    List<double> combinedList = [...data.item1, ...data.item2];
    maxValue = combinedList
        .reduce((value, element) => value > element ? value : element);
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: EdgeInsets.all(
          AppPadding.p5.w,
        ),
        child: LineChart(
          mainData(),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: ColorManager.simiBlack,
      fontWeight: FontWeightManager.semiBold,
      fontSize: AppSize.s12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(weekly ? 'Week1' : 'Month1', style: style);
        break;
      case 3:
        text = Text(weekly ? 'Week2' : 'Month2', style: style);
        break;
      case 6:
        text = Text(weekly ? 'Week3' : 'Month3', style: style);
        break;
      case 9:
        text = Text(weekly ? 'Week4' : 'Month4', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: ColorManager.simiBlack,
      fontWeight: FontWeightManager.semiBold,
      fontSize: AppSize.s10,
    );
    return Center(
        child: Text(
      meta.formattedValue,
      style: style,
    ));
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.w,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: (maxValue + max(maxValue * 0.1, 4.0)).toInt() + 0.0,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, data.item1[0]),
            FlSpot(3, data.item1[1]),
            FlSpot(6, data.item1[2]),
            FlSpot(9, data.item1[3]),
            FlSpot(10, data.item1[4]),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: [
            FlSpot(0, data.item2[0]),
            FlSpot(3, data.item2[1]),
            FlSpot(6, data.item2[2]),
            FlSpot(9, data.item2[3]),
            FlSpot(10, data.item2[4]),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors2
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
