import 'dart:math' as math;
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:flutter/material.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import '../common/reusable/custom_button.dart';

// شاشة التحليل (تحويلها إلى StatefulWidget)
class FencingAnalysisView extends StatefulWidget {
  final PlayerInfo player1Info;
  final PlayerInfo player2Info;
  final VoidCallback onSave ;
  const FencingAnalysisView({
    super.key,
    required this.onSave,
    required this.player1Info,
    required this.player2Info,
  });

  @override
  _FencingAnalysisViewState createState() => _FencingAnalysisViewState();
}

class _FencingAnalysisViewState extends State<FencingAnalysisView> {
  bool _isDataPrinted = false; // متغير للتحكم في الطباعة

  @override
  void initState() {
    super.initState();
    // طباعة البيانات مرة واحدة فقط عند تحميل الشاشة
    if (!_isDataPrinted) {
      _printMatchData(widget.player1Info, "Player 1");
      _printMatchData(widget.player2Info, "Player 2");
      _isDataPrinted = true;
    }
  }

  // دالة لطباعة بيانات المباراة
  void _printMatchData(PlayerInfo playerInfo, String playerName) {
    print("=== $playerName Match Data ===");
    for (var data in playerInfo.matchData) {
      print("Time: ${data.timeInMs}ms, Speed: ${data.speed}, Direction: ${data.direction}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.player1Info.matchData.isEmpty && widget.player2Info.matchData.isEmpty) {
      return const Center(child: Text("No data available for analysis"));
    }

    // حساب أقصى سرعة وأقل سرعة لكلا اللاعبين لضبط المحور Y
    final double maxForwardSpeed1 = _calculateMaxForwardSpeed(widget.player1Info.matchData);
    final double maxBackwardSpeed1 = _calculateMaxBackwardSpeed(widget.player1Info.matchData);
    final double maxForwardSpeed2 = _calculateMaxForwardSpeed(widget.player2Info.matchData);
    final double maxBackwardSpeed2 = _calculateMaxBackwardSpeed(widget.player2Info.matchData);

    // أقصى سرعة إيجابية وأقل سرعة سلبية لكلا اللاعبين
    final double globalMaxForwardSpeed = math.max(maxForwardSpeed1, maxForwardSpeed2);
    final double globalMaxBackwardSpeed = math.max(maxBackwardSpeed1, maxBackwardSpeed2);

    // ضبط maxY و minY مع زيادة بسيطة للتناسب
    final double chartMaxY = (globalMaxForwardSpeed > 0 ? globalMaxForwardSpeed + 0.005 : 0.05).ceilToDouble();
    final double chartMinY = -(globalMaxBackwardSpeed > 0 ? globalMaxBackwardSpeed + 0.005 : 0.05).ceilToDouble();

    return Column(
      children: [
        // أسماء اللاعبين (ثابتة تحت الـ AppBar)
        _buildPlayerNames(),
        // المحتوى القابل للتمرير
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSize.s20.h),
                  // Speed Over Time
                  _buildSpeedOverTime(chartMaxY, chartMinY),
                  // Direction Breakdown
                  _buildDirectionBreakdown(),
                  // Quick Stats
                  _buildQuickStats(),
                  SizedBox(height: AppSize.s20.h),
                ],
              ),
            ),
          ),
        ),
        // زر Save Analysis (ثابت تحت الشاشة)
        _buildSaveButton(),
      ],
    );
  }

  // أسماء اللاعبين
  Widget _buildPlayerNames() {
    final isPlayer1Winner = widget.player1Info.pointRecords.length > widget.player2Info.pointRecords.length;
    final isPlayer2Winner = widget.player2Info.pointRecords.length > widget.player1Info.pointRecords.length;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppPadding.p10.h, horizontal: AppPadding.p16.w),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
          Row(
            children: [
              Text(
                widget.player2Info.playerData.traineeName  ,
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

  // Speed Over Time
  Widget _buildSpeedOverTime(double chartMaxY, double chartMinY) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Speed Over Time'),
        // Player 1
        _buildSpeedChart(widget.player1Info, Colors.blue, "Player 1", Colors.red, chartMaxY, chartMinY),
        SizedBox(height: AppSize.s20.h),
        // Player 2
        _buildSpeedChart(widget.player2Info, Colors.red, "Player 2", Colors.blue, chartMaxY, chartMinY),
      ],
    );
  }

  Widget _buildSpeedChart(
      PlayerInfo playerInfo, Color lineColor, String playerName, Color dotColor, double chartMaxY, double chartMinY) {
    if (playerInfo.matchData.isEmpty) {
      return Center(child: Text("No data for ${playerInfo.playerData.traineeName}"));
    }

    // حساب أقصى وقت بالثواني بناءً على آخر ريكورد (تحويل من ms لـ s)
    final double maxTime = playerInfo.matchData.isNotEmpty
        ? playerInfo.matchData.last.timeInMs / 1000.0 // الوقت هنا بالـ ms، بنحوله لثواني
        : 1.0;

    // تحديد الـ interval ليكون كل ثانيتين لعرض الأرقام
    const double interval = 2;

    // تحويل البيانات الخام لـ FlSpot مع الوقت بالثواني
    List<FlSpot> rawSpots = [];
    for (var data in playerInfo.matchData) {
      double timeInSeconds = data.timeInMs / 1000.0; // تحويل من ms لـ s
      rawSpots.add(FlSpot(timeInSeconds, data.speed));
    }

    // إنشاء قائمة بالنقاط الكبيرة فقط (اللمسات)
    final List<FlSpot> pointSpots = [];
    for (var point in playerInfo.pointRecords) {
      double timeInSeconds = point.timeInMs / 1000.0; // تحويل من ms لـ s
      final matchingData = playerInfo.matchData.firstWhere(
            (data) => data.timeInMs == point.timeInMs,
        orElse: () => MatchDataEntity(timeInMs: point.timeInMs, speed: 0, direction: 0),
      );
      if (matchingData.speed.isFinite) {
        pointSpots.add(FlSpot(timeInSeconds, matchingData.speed));
      }
    }

    // تمديد العرض بحيث كل ثانية تُمثل بمسافة ثابتة
    const double pixelsPerSecond = 50.0; // كل ثانية تُمثل بـ 50 وحدة عرض
    double chartWidth = maxTime * pixelsPerSecond;

    return SizedBox(
      height: 250.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth.w, // العرض بناءً على الوقت مع 50 وحدة لكل ثانية
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                drawVerticalLine: true,
                verticalInterval: 1.0, // خط رأسي كل ثانية كاملة
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: interval, // كل ثانيتين يظهر رقم
                    getTitlesWidget: (value, meta) {
                      final timeInSeconds = value.toInt();
                      if (timeInSeconds % 2 == 0) { // إظهار الرقم كل ثانيتين
                        return Text(
                          '$timeInSeconds s',
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: maxTime,
              minY: chartMinY,
              maxY: chartMaxY,
              lineBarsData: [
                LineChartBarData(
                  spots: rawSpots, // النقاط الخام بالثواني
                  isCurved: false, // خط منحني عشان يعكس التذبذب
                  color: lineColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: pointSpots,
                  isCurved: false,
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: dotColor,
                        strokeWidth: 2,
                        strokeColor: dotColor,
                      );
                    },
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتنعيم البيانات باستخدام متوسط متحرك
  List<FlSpot> _smoothData(List<FlSpot> rawSpots) {
    if (rawSpots.length < 3) return rawSpots;

    List<FlSpot> smoothedSpots = [];
    for (int i = 0; i < rawSpots.length; i++) {
      double sum = rawSpots[i].y;
      int count = 1;

      if (i > 0) {
        sum += rawSpots[i - 1].y;
        count++;
      }
      if (i < rawSpots.length - 1) {
        sum += rawSpots[i + 1].y;
        count++;
      }

      double smoothedY = sum / count;
      smoothedSpots.add(FlSpot(rawSpots[i].x, smoothedY));
    }
    return smoothedSpots;
  }

  // Direction Breakdown
  Widget _buildDirectionBreakdown() {
    final player1Forward = widget.player1Info.matchData.where((d) => d.direction == 1).length;
    final player1Backward = widget.player1Info.matchData.where((d) => d.direction == -1).length;
    // final player1Stopped = widget.player1Info.matchData.where((d) => d.direction == 0).length;
    final player1Total = widget.player1Info.matchData.length;
    final player2Forward = widget.player2Info.matchData.where((d) => d.direction == 1).length;
    final player2Backward = widget.player2Info.matchData.where((d) => d.direction == -1).length;
    // final player2Stopped = widget.player2Info.matchData.where((d) => d.direction == 0).length;
    final player2Total = widget.player2Info.matchData.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Direction Breakdown'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(Colors.green, "Forward"),
            _buildLegendItem(Colors.red, "Backward"),
            _buildLegendItem(Colors.grey, "Stopped"),
          ],
        ),
        SizedBox(height: AppSize.s10.h),
        Row(
          children: [
            Expanded(
                child: _buildDirectionPieChart(widget.player1Info, player1Forward, player1Backward, player1Total)),
            Expanded(
                child: _buildDirectionPieChart(widget.player2Info, player2Forward, player2Backward, player2Total)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: AppSize.s8.w),
        Text(
          label,
          style: TextStyle(fontSize: FontSize.s14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDirectionPieChart(PlayerInfo playerInfo, int forward, int backward, int total) {
    if (playerInfo.matchData.isEmpty) {
      return const Center(child: Text("No data"));
    }
    double forwardPercent = (forward / total) * 100;
    double backwardPercent = (backward / total) * 100;
    double stoppedPercent = 100 - forwardPercent - backwardPercent;

    return SizedBox(
      height: 150.h,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: forwardPercent,
              color: Colors.green,
              title: total > 0 ? "${(forward / total * 100).toStringAsFixed(1)}%" : "0.0%",
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: backwardPercent,
              color: Colors.red,
              title: total > 0 ? "${(backward / total * 100).toStringAsFixed(1)}%" : "0.0%",
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: stoppedPercent,
              color: Colors.grey,
              title: total > 0 ? "${stoppedPercent.toStringAsFixed(1)}%" : "0.0%",
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  // Quick Stats
  Widget _buildQuickStats() {
    final player1Stats = _calculateStats(widget.player1Info);
    final player2Stats = _calculateStats(widget.player2Info);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Stats'),
        _buildStatRow('Average Speed', "${player1Stats['avgSpeed']} m/s", "${player2Stats['avgSpeed']} m/s"),
        _buildStatRow('Max Forward Speed', "${player1Stats['maxForwardSpeed']} m/s", "${player2Stats['maxForwardSpeed']} m/s"),
        _buildStatRow('Max Backward Speed', "${player1Stats['maxBackwardSpeed']} m/s", "${player2Stats['maxBackwardSpeed']} m/s"),
        _buildStatRow('Direction Changes', "${player1Stats['directionChanges']}", "${player2Stats['directionChanges']}  "),
        _buildStatRow('Total Points', "${player1Stats['totalPoints']}", "${player2Stats['totalPoints']}"),
        _buildStatRow('Avg Time Between Points', "${player1Stats['avgTimeBetweenPoints']} s", "${player2Stats['avgTimeBetweenPoints']} s"),
        // _buildStatRow('Longest Active Period', "${player1Stats['longestActivePeriod']} s", "${player2Stats['longestActivePeriod']} s"),
      ],
    );
  }

  Widget _buildStatRow(String title, String player1Value, String player2Value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontSize: FontSize.s15, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: AppSize.s4.h),
                Text(
                  player1Value,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: AppSize.s4.h),
                Text(
                  player2Value,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // زر Save Analysis
  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppPadding.p10.h, horizontal: AppPadding.p16.w),
      color: Colors.grey[200],
      child: customElevatedButtonWithoutStream(
        onPressed: () {
          widget.onSave();
          // Placeholder لوظيفة الحفظ لاحقًا
        },
        child: const Text('Save Analysis', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // عنوان القسم
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

  // دوال مساعدة لحساب الإحصائيات بدون تحويل
  double _calculateAverageSpeed(List<MatchDataEntity> matchData) {
    if (matchData.isEmpty) return 0.0;
    double totalSpeed = matchData.fold(0.0, (sum, data) => sum + data.speed.abs());
    return double.parse((totalSpeed / matchData.length).toStringAsFixed(1));
  }

  double _calculateMaxForwardSpeed(List<MatchDataEntity> matchData) {
    var forwardSpeeds = matchData.where((data) => data.direction == 1).map((data) => data.speed.abs());
    return forwardSpeeds.isEmpty ? 0.0 : double.parse(forwardSpeeds.reduce(math.max).toStringAsFixed(1));
  }

  double _calculateMaxBackwardSpeed(List<MatchDataEntity> matchData) {
    var backwardSpeeds = matchData.where((data) => data.direction == -1).map((data) => data.speed.abs());
    return backwardSpeeds.isEmpty ? 0.0 : double.parse(backwardSpeeds.reduce(math.max).toStringAsFixed(1));
  }

  int _calculateDirectionChanges(List<MatchDataEntity> matchData) {
    if (matchData.length < 2) return 0;
    return matchData.asMap().entries.skip(1).where((entry) => entry.value.direction != matchData[entry.key - 1].direction).length;
  }

  double _calculateAverageTimeBetweenPoints(List<PointDataEntity> pointRecords) {
    if (pointRecords.length < 2) return 0.0;
    double totalTime = 0.0;
    for (int i = 1; i < pointRecords.length; i++) {
      totalTime += pointRecords[i].timeInMs - pointRecords[i - 1].timeInMs;
    }
    return double.parse(((totalTime/1000) / (pointRecords.length - 1)).toStringAsFixed(1));
  }

  int _calculateLongestActivePeriod(List<MatchDataEntity> matchData) {
    if (matchData.isEmpty) return 0;
    int maxPeriod = 0;
    int currentPeriod = 0;
    int? lastTime;
    for (var data in matchData) {
      if (data.direction != 0) {
        if (lastTime != null) {
          currentPeriod += data.timeInMs - lastTime;
        }
        maxPeriod = math.max(maxPeriod, currentPeriod);
      } else {
        currentPeriod = 0;
      }
      lastTime = data.timeInMs;
    }
    return maxPeriod;
  }

  // دالة لحساب كل الإحصائيات
  Map<String, dynamic> _calculateStats(PlayerInfo playerInfo) {
    return {
      'avgSpeed': _calculateAverageSpeed(playerInfo.matchData),
      'maxForwardSpeed': _calculateMaxForwardSpeed(playerInfo.matchData),
      'maxBackwardSpeed': _calculateMaxBackwardSpeed(playerInfo.matchData),
      'directionChanges': _calculateDirectionChanges(playerInfo.matchData),
      'totalPoints': playerInfo.pointRecords.length,
      'avgTimeBetweenPoints': _calculateAverageTimeBetweenPoints(playerInfo.pointRecords),
      // 'longestActivePeriod': _calculateLongestActivePeriod(playerInfo.matchData),
    };
  }
}