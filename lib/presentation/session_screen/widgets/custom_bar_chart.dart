import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';

class ChartData {
  final double eccForce; // Eccentric
  final double conForce; // Concentric
  final int index;

  ChartData({required this.eccForce, required this.conForce, required this.index});
}

class CustomBarChart extends StatelessWidget {
  final List<ChartData> chartData;

  const CustomBarChart({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;


    return SizedBox(
      // width: chartWidth,
      height: 200,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
          autoScrollingDelta: 3,
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(size: 0),
          // labelRotation: -45, // تدوير التسميات بزاوية -45 درجة عشان ما تركبش
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          labelStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
          anchorRangeToVisiblePoints: true,
          majorGridLines: MajorGridLines(width: 1, color: Colors.black),
          majorTickLines: MajorTickLines(size: 0),
          title: AxisTitle(text: 'Force (N)'),
        ),
        series: [
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => 'Set ${data.index + 1}',
            yValueMapper: (ChartData data, _) => data.eccForce,
            pointColorMapper: (ChartData data, _) => Colors.amber,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(
                color: ColorManager.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflowMode: OverflowMode.trim,

            ),
            // width: 0.35, // عرض العمود
            spacing: 0.2, // مسافة بين العمدان
          ),
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => 'Set ${data.index + 1}',
            yValueMapper: (ChartData data, _) => data.conForce,
            pointColorMapper: (ChartData data, _) => ColorManager.simiBlue,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(
                color: ColorManager.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: ColorManager.white,
          textStyle: TextStyle(color: ColorManager.black),
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
      ),
    );
  }
}