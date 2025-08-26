// fencing_analysis_landscape_view.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/custom_pie_chart.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/range_selector.dart';
import 'package:flutter/material.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import '../common/reusable/custom_button.dart';
import 'widgets/speed_line_chart.dart';

class FencingAnalysisLandscapeView extends StatefulWidget {
  final PlayerInfo player1Info;
  final PlayerInfo player2Info;
  final VoidCallback onSave;

  const FencingAnalysisLandscapeView({
    super.key,
    required this.onSave,
    required this.player1Info,
    required this.player2Info,
  });

  @override
  _FencingAnalysisLandscapeViewState createState() =>
      _FencingAnalysisLandscapeViewState();
}

class _FencingAnalysisLandscapeViewState
    extends State<FencingAnalysisLandscapeView> {
  bool _isDataPrinted = false;
  late ZoomPanBehavior zoomPanBehavior;
  late double rangeStart;
  late double rangeEnd;
  late StreamController<SfRangeValues> _rangeStreamController;
  late NumericAxisController _xAxisController1;
  late NumericAxisController _xAxisController2;

  @override
  void initState() {
    super.initState();
    if (!_isDataPrinted) {
      _printMatchData(widget.player1Info, "Player 1");
      _printMatchData(widget.player2Info, "Player 2");
      _isDataPrinted = true;
    }

    // Calculate the initial range based on the full data
    final double maxTime1 = widget.player1Info.matchData.isNotEmpty
        ? widget.player1Info.matchData.last.timeInMs / 1000.0
        : 1.0;
    final double maxTime2 = widget.player2Info.matchData.isNotEmpty
        ? widget.player2Info.matchData.last.timeInMs / 1000.0
        : 1.0;
    final double maxTime = math.max(maxTime1, maxTime2);

    rangeStart = 0.0;
    rangeEnd = maxTime;

    // Initialize ZoomPanBehavior
    zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );

    // Initialize the StreamController for range updates
    _rangeStreamController = StreamController<SfRangeValues>.broadcast();
  }

  @override
  void dispose() {
    _rangeStreamController.close();
    super.dispose();
  }

  void _printMatchData(PlayerInfo playerInfo, String playerName) {
    print("=== $playerName Match Data ===");
    for (var data in playerInfo.matchData) {
      print(
          "Time: ${data.timeInMs}ms, Speed: ${data.speed}, Direction: ${data.direction}");
    }
    print('pointRecords: ${playerInfo.pointRecords.length}');
  }

  // Filter matchData and pointRecords based on the selected range
  PlayerInfo _filterPlayerInfo(
      PlayerInfo playerInfo, double start, double end) {
    final startMs = start * 1000;
    final endMs = end * 1000;

    final filteredMatchData = playerInfo.matchData
        .where((data) => data.timeInMs >= startMs && data.timeInMs <= endMs)
        .toList();

    final filteredPointRecords = playerInfo.pointRecords
        .where(
            (record) => record.timeInMs >= startMs && record.timeInMs <= endMs)
        .toList();

    return PlayerInfo(
      playerData: playerInfo.playerData,
      matchData: filteredMatchData,
      pointRecords: filteredPointRecords,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.player1Info.matchData.isEmpty &&
        widget.player2Info.matchData.isEmpty) {
      return const Center(child: Text("No data available for analysis",style: TextStyle(color: Colors.black),));
    }

    final double maxTime1 = widget.player1Info.matchData.isNotEmpty
        ? widget.player1Info.matchData.last.timeInMs / 1000.0
        : 1.0;
    final double maxTime2 = widget.player2Info.matchData.isNotEmpty
        ? widget.player2Info.matchData.last.timeInMs / 1000.0
        : 1.0;
    final double maxTime = math.max(maxTime1, maxTime2);

    return Column(
      children: [
        _buildPlayerHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSize.s20.h),
                      CustomRangeSelector(
                        min: 0.0,
                        max: maxTime,
                        initialValues: SfRangeValues(rangeStart, rangeEnd),
                        rangeStreamController: _rangeStreamController,
                        interval: 8,
                      ),
                      SizedBox(height: AppSize.s20.h),
                      StreamBuilder<SfRangeValues>(
                        stream: _rangeStreamController.stream,
                        initialData: SfRangeValues(rangeStart, rangeEnd),
                        builder: (context, snapshot) {
                          final range = snapshot.data ??
                              SfRangeValues(rangeStart, rangeEnd);
                          final filteredPlayer1Info = _filterPlayerInfo(
                              widget.player1Info, range.start, range.end);
                          final filteredPlayer2Info = _filterPlayerInfo(
                              widget.player2Info, range.start, range.end);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSpeedOverTimeSection(
                                  filteredPlayer1Info, filteredPlayer2Info),
                              _buildDirectionBreakdownSection(
                                  filteredPlayer1Info, filteredPlayer2Info),
                              _buildQuickStatsSection(
                                  filteredPlayer1Info, filteredPlayer2Info),
                              SizedBox(height: AppSize.s10),
                              _buildSaveButton(),

                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerHeader() {
    final isPlayer1Winner = widget.player1Info.pointRecords.length > widget.player2Info.pointRecords.length;
    final isPlayer2Winner = widget.player2Info.pointRecords.length > widget.player1Info.pointRecords.length;
    final isTie = widget.player1Info.pointRecords.length == widget.player2Info.pointRecords.length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p10.h, horizontal: AppPadding.p16.w),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s20.r,
                backgroundColor: Colors.blue,
                foregroundImage: widget.player1Info.playerData.photo.isNotEmpty
                    ? NetworkImage(widget.player1Info.playerData.photo)
                    : null,
                child: widget.player1Info.playerData.photo.isEmpty
                    ? Text(
                  widget.player1Info.playerData.traineeName.isNotEmpty
                      ? widget.player1Info.playerData.traineeName[0].toUpperCase()
                      : 'P1',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
              SizedBox(width: AppSize.s8.w),
              Text(
                widget.player1Info.playerData.traineeName,
                style: TextStyle(
                  fontSize: FontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              if (isPlayer1Winner) ...[
                SizedBox(width: AppSize.s8.w),
                Text(
                  '👑',
                  style: TextStyle(fontSize: FontSize.s18),
                ),
              ],
            ],
          ),
          if (isTie) ...[
            Text(
              '🤝',
              style: TextStyle(fontSize: FontSize.s22),
            ),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s20.r,
                backgroundColor: Colors.red,
                foregroundImage: widget.player2Info.playerData.photo.isNotEmpty
                    ? NetworkImage(widget.player2Info.playerData.photo)
                    : null,
                child: widget.player2Info.playerData.photo.isEmpty
                    ? Text(
                  widget.player2Info.playerData.traineeName.isNotEmpty
                      ? widget.player2Info.playerData.traineeName[0].toUpperCase()
                      : 'P2',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
              SizedBox(width: AppSize.s8.w),
              Text(
                widget.player2Info.playerData.traineeName,
                style: TextStyle(
                  fontSize: FontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (isPlayer2Winner) ...[
                SizedBox(width: AppSize.s8.w),
                Text(
                  '👑',
                  style: TextStyle(fontSize: FontSize.s18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedOverTimeSection(
      PlayerInfo player1Info, PlayerInfo player2Info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Speed Over Time'),
        Row(
          children: [
            Expanded(
              child: SpeedLineChart(
                matchData: player1Info.matchData,
                pointRecords: player1Info.pointRecords,
                playerId: 1,
                onRenderCreated: (controller) {
                  _xAxisController1 = controller;
                },
              ),
            ),
            // SizedBox(width: AppSize.s16.w),
            Expanded(
              child: SpeedLineChart(
                matchData: player2Info.matchData,
                pointRecords: player2Info.pointRecords,
                playerId: 2,
                onRenderCreated: (controller) {
                  _xAxisController2 = controller;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionBreakdownSection(
      PlayerInfo player1Info, PlayerInfo player2Info) {
    final player1Forward =
        player1Info.matchData.where((d) => d.direction == 1).length;
    final player1Backward =
        player1Info.matchData.where((d) => d.direction == -1).length;
    final player1Total = player1Info.matchData.length;
    final player2Forward =
        player2Info.matchData.where((d) => d.direction == 1).length;
    final player2Backward =
        player2Info.matchData.where((d) => d.direction == -1).length;
    final player2Total = player2Info.matchData.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Direction Breakdown'),
        SizedBox(height: AppSize.s10.h),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, "Forward"),
                _buildLegendItem(Colors.red, "Backward"),
                _buildLegendItem(Colors.grey, "Stopped"),
              ],
            ),
            Expanded(
              child: player1Total > 0
                  ? CustomPieChart(
                      forwardPercent: (player1Forward / player1Total) * 100,
                      backwardPercent: (player1Backward / player1Total) * 100,
                      stoppedPercent: 100 -
                          (player1Forward / player1Total) * 100 -
                          (player1Backward / player1Total) * 100,
                    )
                  : const Center(child: Text("No data")),
            ),
            SizedBox(width: AppSize.s16.w),
            Expanded(
              child: player2Total > 0
                  ? CustomPieChart(
                      forwardPercent: (player2Forward / player2Total) * 100,
                      backwardPercent: (player2Backward / player2Total) * 100,
                      stoppedPercent: 100 -
                          (player2Forward / player2Total) * 100 -
                          (player2Backward / player2Total) * 100,
                    )
                  : const Center(child: Text("No data")),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        SizedBox(width: AppSize.s8.w),
        Text(
          label,
          style: TextStyle(fontSize: FontSize.s14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection(
      PlayerInfo player1Info, PlayerInfo player2Info) {
    final player1Stats = _calculateStats(player1Info);
    final player2Stats = _calculateStats(player2Info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Stats'),
        Table(
          border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                _buildTableCell('Stat', isHeader: true),
                _buildTableCell(widget.player1Info.playerData.traineeName,
                    isHeader: true, color: Colors.blue),
                _buildTableCell(widget.player2Info.playerData.traineeName,
                    isHeader: true, color: Colors.red),
              ],
            ),
            _buildTableRow('Average Speed', "${player1Stats['avgSpeed']} m/s",
                "${player2Stats['avgSpeed']} m/s"),
            _buildTableRow(
                'Max Forward Speed',
                "${player1Stats['maxForwardSpeed']} m/s",
                "${player2Stats['maxForwardSpeed']} m/s"),
            _buildTableRow(
                'Max Backward Speed',
                "${player1Stats['maxBackwardSpeed']} m/s",
                "${player2Stats['maxBackwardSpeed']} m/s"),
            _buildTableRow(
                'Direction Changes',
                "${player1Stats['directionChanges']}",
                "${player2Stats['directionChanges']}"),
            _buildTableRow('Total Points', "${player1Stats['totalPoints']}",
                "${player2Stats['totalPoints']}"),
            _buildTableRow(
                'Avg Time Between Points',
                "${player1Stats['avgTimeBetweenPoints']} s",
                "${player2Stats['avgTimeBetweenPoints']} s"),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(
      String title, String player1Value, String player2Value) {
    return TableRow(
      children: [
        _buildTableCell(title),
        _buildTableCell(player1Value, color: Colors.blue),
        _buildTableCell(player2Value, color: Colors.red),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.all(AppPadding.p8.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? FontSize.s16 : FontSize.s15,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: customElevatedButtonWithoutStream(
        onPressed: () {
          widget.onSave();
        },
        child:
            const Text('Save Analysis', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p8.h),
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

  double _calculateAverageSpeed(List<MatchDataEntity> matchData) {
    if (matchData.isEmpty) return 0.0;
    double totalSpeed =
        matchData.fold(0.0, (sum, data) => sum + data.speed.abs());
    return double.parse((totalSpeed / matchData.length).toStringAsFixed(1));
  }

  double _calculateMaxForwardSpeed(List<MatchDataEntity> matchData) {
    var forwardSpeeds = matchData
        .where((data) => data.direction == 1)
        .map((data) => data.speed.abs());
    return forwardSpeeds.isEmpty
        ? 0.0
        : double.parse(forwardSpeeds.reduce(math.max).toStringAsFixed(1));
  }

  double _calculateMaxBackwardSpeed(List<MatchDataEntity> matchData) {
    var backwardSpeeds = matchData
        .where((data) => data.direction == -1)
        .map((data) => data.speed.abs());
    return backwardSpeeds.isEmpty
        ? 0.0
        : double.parse(backwardSpeeds.reduce(math.max).toStringAsFixed(1));
  }

  int _calculateDirectionChanges(List<MatchDataEntity> matchData) {
    if (matchData.length < 2) return 0;
    return matchData
        .asMap()
        .entries
        .skip(1)
        .where((entry) =>
            entry.value.direction != matchData[entry.key - 1].direction)
        .length;
  }

  double _calculateAverageTimeBetweenPoints(List<PointDataEntity> pointRecords) {
    if (pointRecords.length < 2) return 0.0;
    double totalTime = 0.0;
    for (int i = 1; i < pointRecords.length; i++) {
      totalTime += pointRecords[i].timeInMs - pointRecords[i - 1].timeInMs;
    }
    return double.parse(
        ((totalTime / 1000) / (pointRecords.length - 1)).toStringAsFixed(1));
  }

  Map<String, dynamic> _calculateStats(PlayerInfo playerInfo) {
    return {
      'avgSpeed': _calculateAverageSpeed(playerInfo.matchData),
      'maxForwardSpeed': _calculateMaxForwardSpeed(playerInfo.matchData),
      'maxBackwardSpeed': _calculateMaxBackwardSpeed(playerInfo.matchData),
      'directionChanges': _calculateDirectionChanges(playerInfo.matchData),
      'totalPoints': playerInfo.pointRecords.length,
      'avgTimeBetweenPoints':
          _calculateAverageTimeBetweenPoints(playerInfo.pointRecords),
    };
  }
}
