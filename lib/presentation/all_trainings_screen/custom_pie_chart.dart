import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPieChart extends StatelessWidget {
  final double forwardPercent;
  final double backwardPercent;
  final double stoppedPercent;

  const CustomPieChart({
    super.key,
    required this.forwardPercent,
    required this.backwardPercent,
    required this.stoppedPercent,
  });

  @override
  Widget build(BuildContext context) {
    final List<PieChartData> chartData = [
      PieChartData('Forward', forwardPercent, Colors.green),
      PieChartData('Backward', backwardPercent, Colors.red),
      PieChartData('Stopped', stoppedPercent, Colors.grey),
    ];

    return ClipRect(
      child: SizedBox(
        height: 120.h,
        child: SfCircularChart(
          series: <CircularSeries>[
            PieSeries<PieChartData, String>(
              dataSource: chartData,
              xValueMapper: (PieChartData data, _) => data.category,
              yValueMapper: (PieChartData data, _) => data.value,
              pointColorMapper: (PieChartData data, _) => data.color,
              dataLabelMapper: (PieChartData data, _) =>
              '${data.value.toStringAsFixed(1)}%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                textStyle: const TextStyle(fontSize:12, color: Colors.black),
              ),
              explode: true,
              explodeIndex: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartData {
  final String category;
  final double value;
  final Color color;

  PieChartData(this.category, this.value, this.color);
}