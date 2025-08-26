import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartData {
  final double timeInSeconds;
  final double speed;

  ChartData(this.timeInSeconds, this.speed);
}

class CustomLiveChart extends StatefulWidget {
  final Stream<MatchDataEntity> matchDataStream;
  final Stream<PointDataEntity> pointRecordStream;
  final int playerId;

  const CustomLiveChart({
    super.key,
    required this.playerId,
    required this.matchDataStream,
    required this.pointRecordStream,
  });

  @override
  _CustomLiveChartState createState() => _CustomLiveChartState();
}

class _CustomLiveChartState extends State<CustomLiveChart> {
  List<ChartData> speedData = [ChartData(0, 0)];
  List<ChartData> pointData = [];
  late ZoomPanBehavior _zoomPanBehavior;
  late NumericAxisController _yAxisController;
  late NumericAxisController _xAxisController;
  double minY = 0.0;
  double maxY = 10.0;
  double currentMaxTime = 0.0;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: false,
      zoomMode: ZoomMode.x,
    );
  }

  void _updateYAxisRange() {
    if (speedData.isNotEmpty) {
      final speeds = speedData.map((data) => data.speed).toList();
      minY = speeds.reduce((a, b) => a < b ? a : b) - 2;
      maxY = speeds.reduce((a, b) => a > b ? a : b) + 2;
      _yAxisController.visibleMinimum = minY;
      _yAxisController.visibleMaximum = maxY;
    }
  }

  void _updateXAxisRange() {
    if (speedData.isNotEmpty) {
      double newMinX = currentMaxTime - 6;
      double newMaxX = currentMaxTime;
      if (newMinX < 0) newMinX = 0;
      _xAxisController.visibleMinimum = newMinX;
      _xAxisController.visibleMaximum = newMaxX;
    }
  }
  int _lastPointTimeInMs=0;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder2<MatchDataEntity, PointDataEntity>(
              streams:
                  StreamTuple2(widget.matchDataStream, widget.pointRecordStream),
              builder: (context, snapshot) {
                if (snapshot.snapshot1.hasData) {
                  final matchData = snapshot.snapshot1.data!;
                  final timeInSeconds = matchData.timeInMs / 1000.0;
                  final adjustedSpeed = matchData.speed * matchData.direction;
                  speedData.add(ChartData(timeInSeconds, adjustedSpeed));
                  currentMaxTime = timeInSeconds;
                  _updateYAxisRange();
                  _updateXAxisRange();
                }
                if (snapshot.snapshot2.hasData) {
                  final pointRecord = snapshot.snapshot2.data!;
                  if(pointRecord.timeInMs!=_lastPointTimeInMs){
                  if (pointRecord.timeInMs == -1) {
                    if (pointData.isNotEmpty) {
                      pointData.removeLast();
                    }
                  } else {
                    print('pointRecord.timeInMs: ${pointRecord.timeInMs}');
                    final timeInSeconds = pointRecord.timeInMs / 1000.0;
                    pointData.add(ChartData(timeInSeconds, pointRecord.speed));
                  }
                  _lastPointTimeInMs=pointRecord.timeInMs;}
                }

                return SfCartesianChart(
                  zoomPanBehavior: _zoomPanBehavior,
                  primaryXAxis: NumericAxis(
                    interval: 2,
                    labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                    majorGridLines: MajorGridLines(
                      width: 0.5,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    onRendererCreated: (NumericAxisController controller) {
                      _xAxisController = controller;
                    },
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                    majorGridLines: MajorGridLines(
                      width: 0.5,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    onRendererCreated: (NumericAxisController controller) {
                      _yAxisController = controller;
                    },
                  ),
                  series: <CartesianSeries>[
                    LineSeries<ChartData, double>(
                      dataSource: speedData,
                      xValueMapper: (ChartData data, _) => data.timeInSeconds,
                      yValueMapper: (ChartData data, _) => data.speed,
                      color: widget.playerId == 1 ? Colors.blue : Colors.red,
                      width: 2,
                      markerSettings: const MarkerSettings(isVisible: false),
                    ),
                    ScatterSeries<ChartData, double>(
                      dataSource: pointData,
                      xValueMapper: (ChartData data, _) => data.timeInSeconds,
                      yValueMapper: (ChartData data, _) => data.speed,
                      color: widget.playerId == 2 ? Colors.blue : Colors.red,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        height: 5,
                        width: 5,
                        borderWidth: 5,
                        shape: DataMarkerType.circle,
                      ),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: Colors.blueGrey.withOpacity(0.8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
