import 'dart:async';
import 'dart:math' as math;
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/custom_pie_chart.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/range_selector.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/speed_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FencingAnalysisView extends StatefulWidget {
  final MatchEntity matchEntity;
  final TraineeData traineeData;
  static const String routeName = '/fencing_analysis_view';

  const FencingAnalysisView({
    super.key,
    required this.matchEntity,
    required this.traineeData,
  });

  @override
  _FencingAnalysisViewState createState() => _FencingAnalysisViewState();
}

class _FencingAnalysisViewState extends State<FencingAnalysisView> {
  late ZoomPanBehavior zoomPanBehavior;
  late double rangeStart;
  late double rangeEnd;
  late StreamController<SfRangeValues> _rangeStreamController;
  late NumericAxisController _xAxisController1;
  late MatchDetailsEntity playerMatchData;
  late MatchDetailsEntity opponentMatchData;
  late String playerName;
  late String opponentName;

  @override
  void initState() {
    super.initState();

    // Determine player and opponent data based on opponentNum
    if (widget.matchEntity.opponentNum == 1) {
      playerMatchData = widget.matchEntity.player2MatchData;
      opponentMatchData = widget.matchEntity.player1MatchData;
      playerName = widget.traineeData.traineeName;
      opponentName = widget.matchEntity.opponent.traineeName;
    } else {
      playerMatchData = widget.matchEntity.player1MatchData;
      opponentMatchData = widget.matchEntity.player2MatchData;
      playerName = widget.traineeData.traineeName;
      opponentName = widget.matchEntity.opponent.traineeName;
    }

    // Calculate the initial range based on player data only
    final double maxTimePlayer = playerMatchData.matchData.isNotEmpty
        ? playerMatchData.matchData.last.timeInMs / 1000.0
        : 1.0;

    rangeStart = 0.0;
    rangeEnd = maxTimePlayer;

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

  // Filter matchData and pointData based on the selected range
  MatchDetailsEntity _filterMatchData(
      MatchDetailsEntity matchData, double start, double end) {
    final startMs = start * 1000;
    final endMs = end * 1000;

    final filteredMatchData = matchData.matchData
        .where((data) => data.timeInMs >= startMs && data.timeInMs <= endMs)
        .toList();

    final filteredPointData = matchData.pointData
        .where((data) => data.timeInMs >= startMs && data.timeInMs <= endMs)
        .toList();

    return MatchDetailsEntity(
      matchData: filteredMatchData,
      pointData: filteredPointData,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (playerMatchData.matchData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analysis'),
        ),
        body: const Center(
            child: Text("No data available for analysis",
                style: TextStyle(color: Colors.black))),
      );
    }

    final double maxTimePlayer = playerMatchData.matchData.isNotEmpty
        ? playerMatchData.matchData.last.timeInMs / 1000.0
        : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
      ),
      body: Column(
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
                          max: maxTimePlayer,
                          initialValues: SfRangeValues(rangeStart, rangeEnd),
                          rangeStreamController: _rangeStreamController,
                          interval: (maxTimePlayer / 20).toInt(),
                        ),
                        SizedBox(height: AppSize.s20.h),
                        StreamBuilder<SfRangeValues>(
                          stream: _rangeStreamController.stream,
                          initialData: SfRangeValues(rangeStart, rangeEnd),
                          builder: (context, snapshot) {
                            final range = snapshot.data ??
                                SfRangeValues(rangeStart, rangeEnd);
                            final filteredPlayerMatchData = _filterMatchData(
                                playerMatchData, range.start, range.end);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSpeedOverTimeSection(filteredPlayerMatchData),
                                _buildDirectionBreakdownSection(filteredPlayerMatchData),
                                _buildQuickStatsSection(filteredPlayerMatchData),
                                SizedBox(height: AppSize.s10),
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
      ),
    );
  }

  Widget _buildPlayerHeader() {
    final isPlayerWinner =
        playerMatchData.pointData.length > opponentMatchData.pointData.length;
    final isOpponentWinner =
        opponentMatchData.pointData.length > playerMatchData.pointData.length;
    final isTie =
        playerMatchData.pointData.length == opponentMatchData.pointData.length;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppPadding.p10.h, horizontal: AppPadding.p16.w),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s20.r,
                backgroundColor: Colors.blue,
                foregroundImage: widget.traineeData.photo.isNotEmpty
                    ? NetworkImage(widget.traineeData.photo)
                    : null,
                child: widget.traineeData.photo.isEmpty
                    ? Text(
                  widget.traineeData.traineeName.isNotEmpty
                      ? widget.traineeData.traineeName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
              SizedBox(width: AppSize.s8.w),
              Text(
                playerName,
                style: TextStyle(
                  fontSize: FontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              if (isPlayerWinner) ...[
                SizedBox(width: AppSize.s8.w),
                Text(
                  "🏆",
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
                foregroundImage: widget.matchEntity.opponent.photo.isNotEmpty
                    ? NetworkImage(widget.matchEntity.opponent.photo)
                    : null,
                child: widget.matchEntity.opponent.photo.isEmpty
                    ? Text(
                  widget.matchEntity.opponent.traineeName.isNotEmpty
                      ? widget.matchEntity.opponent.traineeName[0]
                      .toUpperCase()
                      : 'O',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
              SizedBox(width: AppSize.s8.w),
              Text(
                opponentName,
                style: TextStyle(
                  fontSize: FontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (isOpponentWinner) ...[
                SizedBox(width: AppSize.s8.w),
                Text(
                  "🏆",
                  style: TextStyle(fontSize: FontSize.s18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedOverTimeSection(MatchDetailsEntity playerMatchData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Speed Over Time'),
        Row(
          children: [
            Expanded(
              child: SpeedLineChart(
                matchData: playerMatchData.matchData,
                pointRecords: playerMatchData.pointData,
                playerId: widget.matchEntity.opponentNum == 1 ? 2 : 1,
                onRenderCreated: (controller) {
                  _xAxisController1 = controller;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionBreakdownSection(MatchDetailsEntity playerMatchData) {
    final playerForward = playerMatchData.matchData.where((d) => d.direction == 1).length;
    final playerBackward = playerMatchData.matchData.where((d) => d.direction == -1).length;
    final playerTotal = playerMatchData.matchData.length;

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
              child: playerTotal > 0
                  ? CustomPieChart(
                forwardPercent: (playerForward / playerTotal) * 100,
                backwardPercent: (playerBackward / playerTotal) * 100,
                stoppedPercent: 100 -
                    (playerForward / playerTotal) * 100 -
                    (playerBackward / playerTotal) * 100,
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

  Widget _buildQuickStatsSection(MatchDetailsEntity playerMatchData) {
    final playerStats = _calculateStats(playerMatchData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Stats'),
        Table(
          border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                _buildTableCell('Stat', isHeader: true),
                _buildTableCell(playerName, isHeader: true, color: Colors.blue),
              ],
            ),
            _buildTableRow('Average Speed', "${playerStats['avgSpeed']} m/s"),
            _buildTableRow('Max Forward Speed', "${playerStats['maxForwardSpeed']} m/s"),
            _buildTableRow('Max Backward Speed', "${playerStats['maxBackwardSpeed']} m/s"),
            _buildTableRow('Direction Changes', "${playerStats['directionChanges']}"),
            _buildTableRow('Total Points', "${playerStats['totalPoints']}"),
            _buildTableRow('Avg Time Between Points', "${playerStats['avgTimeBetweenPoints']} s"),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String title, String playerValue) {
    return TableRow(
      children: [
        _buildTableCell(title),
        _buildTableCell(playerValue, color: Colors.blue),
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

  double _calculateAverageTimeBetweenPoints(List<PointDataEntity> pointData) {
    if (pointData.length < 2) return 0.0;
    double totalTime = 0.0;
    for (int i = 1; i < pointData.length; i++) {
      totalTime += pointData[i].timeInMs - pointData[i - 1].timeInMs;
    }
    return double.parse(
        ((totalTime / 1000) / (pointData.length - 1)).toStringAsFixed(1));
  }

  Map<String, dynamic> _calculateStats(MatchDetailsEntity matchData) {
    return {
      'avgSpeed': _calculateAverageSpeed(matchData.matchData),
      'maxForwardSpeed': _calculateMaxForwardSpeed(matchData.matchData),
      'maxBackwardSpeed': _calculateMaxBackwardSpeed(matchData.matchData),
      'directionChanges': _calculateDirectionChanges(matchData.matchData),
      'totalPoints': matchData.pointData.length,
      'avgTimeBetweenPoints':
      _calculateAverageTimeBetweenPoints(matchData.pointData),
    };
  }
}