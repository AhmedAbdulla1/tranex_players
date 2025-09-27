import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tranex_users/data/network/requests.dart';

class TrainingSpeedLineChart extends StatefulWidget {
  final List<PlayerMovementData> matchData;
  final List<PointDataEntity> pointRecords;
  final ZoomPanBehavior zoomPanBehavior;
  final Function(NumericAxisController) onRenderCreated;

  const TrainingSpeedLineChart({
    super.key,
    required this.matchData,
    required this.pointRecords,
    required this.zoomPanBehavior,
    required this.onRenderCreated,
  });

  @override
  _SpeedLineChartState createState() => _SpeedLineChartState();
}

class _SpeedLineChartState extends State<TrainingSpeedLineChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.matchData.isEmpty) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final double maxTime = widget.matchData.isNotEmpty
        ? widget.matchData.last.timeInMs / 1000.0
        : 1.0;

    List<ChartData> chartData = widget.matchData
        .map(
          (data) => ChartData(
            time: data.timeInMs / 1000.0,
            speed: data.speed * data.direction,
          ),
        )
        .toList();

    List<ChartData> pointData = widget.pointRecords.map((point) {
      final matchingData = widget.matchData.firstWhere(
        (data) => data.timeInMs == point.timeInMs,
        orElse: () => PlayerMovementData(
          timeInMs: point.timeInMs,
          speed: 0,
          direction: 0,
        ),
      );
      return ChartData(
        time: point.timeInMs / 1000.0,
        speed: matchingData.speed * matchingData.direction,
      );
    }).toList();

    final double maxSpeed = chartData.isNotEmpty
        ? chartData
              .map((data) => data.speed.abs())
              .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double chartMaxY = (maxSpeed > 0 ? maxSpeed + 0.005 : 0.05)
        .ceilToDouble();
    final double chartMinY = -chartMaxY;

    return ClipRect(
      child: SizedBox(
        height: 180.h,
        child: SfCartesianChart(
          zoomPanBehavior: widget.zoomPanBehavior,
          primaryXAxis: NumericAxis(
            interval: 2,
            minimum: 0,
            maximum: maxTime < 8 ? 8 : maxTime,
            labelFormat: '{value}s',
            onRendererCreated: widget.onRenderCreated,
            majorGridLines: const MajorGridLines(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            minimum: chartMinY,
            maximum: chartMaxY,
            majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.3)),
            minorGridLines: MinorGridLines(color: Colors.grey.withOpacity(0.3)),
          ),
          series: <CartesianSeries>[
            LineSeries<ChartData, double>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.time,
              yValueMapper: (ChartData data, _) => data.speed,
              color: Colors.blue,
              width: 2,
              markerSettings: const MarkerSettings(isVisible: false),
            ),
            ScatterSeries<ChartData, double>(
              dataSource: pointData,
              xValueMapper: (ChartData data, _) => data.time,
              yValueMapper: (ChartData data, _) => data.speed,
              color: Colors.red,
              markerSettings: const MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
              ),
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            color: Colors.blueGrey.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final double time;
  final double speed;

  ChartData({required this.time, required this.speed});
}
