// speed_line_chart.dart
import 'dart:developer';

import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view_model.dart';

class SpeedLineChart extends StatefulWidget {
  final List<PlayerMovementData> matchData;
  final List<PointDataEntity> pointRecords;
  final int playerId;
  final Function(NumericAxisController) onRenderCreated;

  // final NumericAxisController xAxisController ;
  const SpeedLineChart({
    super.key,
    required this.matchData,
    required this.pointRecords,
    required this.playerId,
    required this.onRenderCreated,
  });

  @override
  _SpeedLineChartState createState() => _SpeedLineChartState();
}

class _SpeedLineChartState extends State<SpeedLineChart> {
  late ZoomPanBehavior zoomPanBehavior;
  @override
  void initState() {
    zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    super.initState();
  }
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
      ));
    }

    final double maxTime = widget.matchData.isNotEmpty
        ? widget.matchData.last.timeInMs / 1000.0
        : 1.0;
    log('maxTime: $maxTime');

    List<ChartData> chartData = widget.matchData
        .map((data) => ChartData(
            time: data.timeInMs / 1000.0, speed: data.speed * data.direction))
        .toList();

    List<ChartData> pointData = widget.pointRecords.map((point) {
      final matchingData = widget.matchData.firstWhere(
        (data) => data.timeInMs == point.timeInMs,
        orElse: () =>
            PlayerMovementData(timeInMs: point.timeInMs, speed: 0, direction: 0),
      );
      return ChartData(
          time: point.timeInMs / 1000.0,
          speed: matchingData.speed * matchingData.direction);
    }).toList();

    final double maxSpeed = chartData.isNotEmpty
        ? chartData
            .map((data) => data.speed.abs())
            .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double chartMaxY =
        (maxSpeed > 0 ? maxSpeed + 0.005 : 0.05).ceilToDouble();
    final double chartMinY = -chartMaxY;

    return SizedBox(
      height: 250.h,
      child: SfCartesianChart(
        zoomPanBehavior: zoomPanBehavior,
        primaryXAxis: NumericAxis(
          interval: 2,
          initialVisibleMaximum: 8,
          initialVisibleMinimum: 0,
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
            color: widget.playerId == 1 ? Colors.blue : Colors.red,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: false),
          ),
          ScatterSeries<ChartData, double>(
            dataSource: pointData,
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.speed,
            color: widget.playerId == 1 ? Colors.red : Colors.blue,
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
    );
  }
}

class ChartData {
  final double time;
  final double speed;

  ChartData({required this.time, required this.speed});
}
