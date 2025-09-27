import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:tranex_users/domain/models/fencing_training_enitity.dart';
import 'package:tranex_users/domain/models/fitness_training_enttity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/models/training_entity.dart';
import 'package:tranex_users/presentation/all_trainings_screen/live_chart.dart';
import 'package:tranex_users/presentation/all_trainings_screen/range_selector.dart';
import 'package:tranex_users/presentation/fencing_match/widgets/custom_pie_chart.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';


class TrainingAnalysisView extends StatefulWidget {
  final TrainingEntity training;
  final TrainingEntity? previousTraining;

  const TrainingAnalysisView({
    super.key,
    required this.training,
    this.previousTraining,
  });

  @override
  State<TrainingAnalysisView> createState() => _TrainingAnalysisViewState();
}

class _TrainingAnalysisViewState extends State<TrainingAnalysisView> {
  late double rangeStart;
  late double rangeEnd;
  late ValueNotifier<SfRangeValues> rangeNotifier;

  @override
  void initState() {
    super.initState();

    if (widget.training.trainingDetails is FencingTrainingDetails) {
      final fencing = widget.training.trainingDetails as FencingTrainingDetails;

      final maxTime = fencing.movements.isNotEmpty
          ? fencing.movements.last.timeInMs / 1000.0
          : 1.0;

      rangeStart = 0.0;
      rangeEnd = maxTime;

      rangeNotifier = ValueNotifier<SfRangeValues>(
        SfRangeValues(rangeStart, rangeEnd),
      );
    }
  }

  @override
  void dispose() {
    if (widget.training.trainingDetails is FencingTrainingDetails) {
      rangeNotifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.training.trainingDetails;

    if (details is FitnessTrainingDetails) {
      return FitnessTraningDetailsView(
        currentData: details,
        previousData:
            widget.previousTraining?.trainingDetails is FitnessTrainingDetails
            ? widget.previousTraining!.trainingDetails as FitnessTrainingDetails
            : null,
        onSave: () {},
        onExit: () {},
      );
    } else if (details is FencingTrainingDetails) {
      return _buildFencingDetails(details);
    } else {
      return const Text("⚠️ Unknown training type");
    }
  }

  /// ----------- Fencing Training -----------
  Widget _buildFencingDetails(FencingTrainingDetails fencing) {
    final maxTime = fencing.movements.isNotEmpty
        ? fencing.movements.last.timeInMs / 1000.0
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomRangeSelector(
          min: 0.0,
          max: maxTime,
          initialValues: SfRangeValues(rangeStart, rangeEnd),
          onChanged: (values) => rangeNotifier.value = values,
          interval: 10,
        ),
        SizedBox(height: 12.h),
        ValueListenableBuilder<SfRangeValues>(
          valueListenable: rangeNotifier,
          builder: (context, range, child) {
            final filteredMovements = fencing.movements
                .where(
                  (m) =>
                      m.timeInMs >= range.start * 1000 &&
                      m.timeInMs <= range.end * 1000,
                )
                .toList();

            final filteredPoints = fencing.pointRecords
                .where(
                  (p) =>
                      p.timeInMs >= range.start * 1000 &&
                      p.timeInMs <= range.end * 1000,
                )
                .toList();

            return Column(
              children: [
                _buildSpeedSection(
                  filteredMovements,
                  filteredPoints,
                  widget.training,
                ),
                14.verticalSpace,
                _buildDirectionBreakdown(filteredMovements),
                14.verticalSpace,
                _buildQuickStatsTable(filteredMovements, filteredPoints),
              ],
            );
          },
        ),
      ],
    );
  }

  /// -------- UI Components ----------
  Widget _buildSpeedSection(
    List movements,
    List points,
    TrainingData training,
  ) {
    final fencing = training.trainingDetails as FencingTrainingDetails;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Speed Over Time"),
        SizedBox(
          height: 180.h,
          child: TrainingSpeedLineChart(
            matchData: fencing.movements,
            pointRecords: fencing.pointRecords,
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              enablePanning: true,
              enableMouseWheelZooming: true,
              zoomMode: ZoomMode.x,
            ),
            onRenderCreated: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionBreakdown(List movements) {
    final forward = movements.where((m) => m.direction == 1).length;
    final backward = movements.where((m) => m.direction == -1).length;
    final total = movements.length;

    final forwardPercent = total > 0 ? (forward / total) * 100 : 0;
    final backwardPercent = total > 0 ? (backward / total) * 100 : 0;
    final stoppedPercent = total > 0
        ? 100 - forwardPercent - backwardPercent
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Direction Breakdown"),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(Colors.green, "Forward"),
                _buildLegendItem(Colors.red, "Backward"),
                _buildLegendItem(Colors.grey, "Stopped"),
              ],
            ),
            CustomPieChart(
              forwardPercent: double.parse(forwardPercent.toStringAsFixed(1)),
              backwardPercent: double.parse(backwardPercent.toStringAsFixed(1)),
              stoppedPercent: double.parse(stoppedPercent.toStringAsFixed(1)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        SizedBox(width: AppSize.s8.w),
        Text(
          label,
          style: TextStyle(fontSize: FontSize.s14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildQuickStatsTable(List movements, List points) {
    final stats = {
      "Average Speed": "${_calcAvgSpeed(movements)} m/s",
      "Max Forward Speed": "${_calcMaxSpeed(movements, 1)} m/s",
      "Max Backward Speed": "${_calcMaxSpeed(movements, -1)} m/s",

      "Total Points": "${points.length}",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quick Stats"),
        SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: DataTable(
              headingRowHeight: 48,
              dataRowHeight: 56,
              columnSpacing: 32,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: const [
                DataColumn(
                  label: Text(
                    "Stat",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 🔹 كبر الخط
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Value",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16, // 🔹 كبر الخط
                    ),
                  ),
                ),
              ],
              rows: stats.entries.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// -------- Utils ----------
  double _calcAvgSpeed(List movements) {
    if (movements.isEmpty) return 0.0;
    final total = movements.fold(0.0, (sum, m) => sum + m.speed.abs());
    return double.parse((total / movements.length).toStringAsFixed(1));
  }

  double _calcMaxSpeed(List movements, int dir) {
    final speeds = movements
        .where((m) => m.direction == dir)
        .map((m) => m.speed.abs().toDouble())
        .toList();

    return speeds.isEmpty
        ? 0.0
        : double.parse(
            speeds.reduce((a, b) => math.max(a, b)).toStringAsFixed(1),
          );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: FontSize.s18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
