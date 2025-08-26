import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/common/reusable/custom_button.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:firesport_users/presentation/session_screen/widgets/custom_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EndSessionView extends StatefulWidget {
  final Data currentData;
  final Data? previousData;
  final VoidCallback onSave;
  final VoidCallback onExit;

  const EndSessionView({
    super.key,
    required this.currentData,
    this.previousData,
    required this.onSave,
    required this.onExit,
  });

  @override
  State<EndSessionView> createState() => _EndSessionViewState();
}

class _EndSessionViewState extends State<EndSessionView> {
  late List<ChartData> currentChartData;
  List<ChartData>? previousChartData;

  @override
  void initState() {
    currentChartData = _convertToChartData(widget.currentData);
    previousChartData = widget.previousData != null
        ? _convertToChartData(widget.previousData!)
        : null;
    print(widget.currentData.toMap());
    print(widget.previousData?.toMap());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ChartData> _convertToChartData(Data data) {
    if (data.eccForce.length != data.conForce.length) {
      throw ArgumentError('Both lists must have the same length.');
    }

    List<ChartData> chartData = [];
    for (int index = 0; index < data.eccForce.length; index++) {
      double eccentricForce = data.eccForce[index];
      double concentricForce =data.conForce[index];

      chartData.add(ChartData(
        eccForce: eccentricForce,
        conForce: concentricForce,
        index: index,
      ));
    }
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            CustomBarChart(
              chartData: currentChartData,
            ),
            SizedBox(height: 20.h),
            ForceComparisonTable(
              previousData: widget.previousData,
              currentData: widget.currentData,
            ),
            SizedBox(height: 20.h),
            SpeedComparisonTable(
              previousData: widget.previousData,
              currentData: widget.currentData,
            ),
            SizedBox(height: 20.h),
            _buildSaveButton(AppStrings.save, widget.onSave),
            SizedBox(height: 20.h),
            _buildSaveButton(AppStrings.saveAndExit, widget.onExit),
            SizedBox(height: 20.h),
            _buildSaveButton('Exit', () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return customElevatedButtonWithoutStream(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}



class ForceComparisonTable extends StatelessWidget {
  final Data? previousData;
  final Data currentData;

  const ForceComparisonTable({
    super.key,
    required this.previousData,
    required this.currentData,
  });

  @override
  Widget build(BuildContext context) {
    print('currentData: $currentData');
    print('previousData: $previousData');
    double currentAvgEccForce = currentData.eccForce.isNotEmpty
        ? currentData.eccForce.reduce((a, b) => a + b) / currentData.eccForce.length
        : 0.0;
    double currentMaxEccForce = currentData.eccForce.isNotEmpty
        ? currentData.eccForce.reduce((a, b) => a > b ? a : b)
        : 0.0;
    double currentAvgConForce = currentData.conForce.isNotEmpty
        ? currentData.conForce.reduce((a, b) => a + b) / currentData.conForce.length
        : 0.0;
    double currentMaxConForce = currentData.conForce.isNotEmpty
        ? currentData.conForce.reduce((a, b) => a > b ? a : b)
        : 0.0;

    double previousAvgEccForce = previousData?.eccForce.isNotEmpty ?? false
        ? previousData!.eccForce.reduce((a, b) => a + b) / previousData!.eccForce.length
        : 0.0;
    double previousMaxEccForce = previousData?.eccForce.isNotEmpty ?? false
        ? previousData!.eccForce.reduce((a, b) => a > b ? a : b)
        : 0.0;
    double previousAvgConForce = previousData?.conForce.isNotEmpty ?? false
        ? previousData!.conForce.reduce((a, b) => a + b) / previousData!.conForce.length
        : 0.0;
    double previousMaxConForce = previousData?.conForce.isNotEmpty ?? false
        ? previousData!.conForce.reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Force:',
            style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
          ),
          const SizedBox(height: 8),
          buildTable(
            ['Ecc', 'Con'],
            [
              [currentAvgEccForce, previousAvgEccForce],
              [currentAvgConForce, previousAvgConForce],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Max Force:',
            style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
          ),
          const SizedBox(height: 8),
          buildTable(
            ['Ecc', 'Con'],
            [
              [currentMaxEccForce, previousMaxEccForce],
              [currentMaxConForce, previousMaxConForce],
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTable(List<String> labels, List<List<double>> data) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            const Text(''),
            Text(
              'Current',
              textAlign: TextAlign.center,
              style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
            ),
            Text(
              'Prev',
              textAlign: TextAlign.center,
              style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
            ),
          ],
        ),
        for (int i = 0; i < labels.length; i++)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data[i][0].toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data[i][1].toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class SpeedComparisonTable extends StatelessWidget {
  final Data? previousData;
  final Data currentData;

  const SpeedComparisonTable(
      {super.key, required this.previousData, required this.currentData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Speed:',
            style:
                getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
          ),
          const SizedBox(height: 8),
          buildTable(
            ['Ecc', 'Con'],
            [
              [
                currentData.avgEccSpeed,
                previousData?.avgEccSpeed ?? 0.0,
              ],
              [
                currentData.avgConSpeed,
                previousData?.avgConSpeed ?? 0.0,
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Max Speed:',
            style:
                getBoldStyle(fontSize: FontSize.s16, color: ColorManager.black),
          ),
          const SizedBox(height: 8),
          buildTable(
            ['Ecc', 'Con'],
            [
              [
                currentData.maxEccSpeed,
                previousData?.maxEccSpeed ?? 0.0,
              ],
              [
                currentData.maxConSpeed,
                previousData?.maxConSpeed ?? 0.0,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTable(List<String> labels, List<List<double>> data) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            const Text(''),
            Text(
              'Current',
              textAlign: TextAlign.center,
              style: getBoldStyle(
                  fontSize: FontSize.s16, color: ColorManager.black),
            ),
            Text(
              'Prev',
              textAlign: TextAlign.center,
              style: getBoldStyle(
                  fontSize: FontSize.s16, color: ColorManager.black),
            ),
          ],
        ),
        for (int i = 0; i < labels.length; i++)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                      fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data[i][0].toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                      fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data[i][1].toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                      fontSize: FontSize.s16, color: ColorManager.black),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
