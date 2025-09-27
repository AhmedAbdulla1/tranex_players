import 'dart:developer';

import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:tranex_users/presentation/session_screen/session_view_model.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class FencingAnalysisScreen extends StatefulWidget {
  final List<FencingDataModel> fencingData;

  const FencingAnalysisScreen({super.key, required this.fencingData});

  @override
  _FencingAnalysisScreenState createState() => _FencingAnalysisScreenState();
}

class _FencingAnalysisScreenState extends State<FencingAnalysisScreen> {
  // عرض افتراضي لـ 30 ثانية (300 ريكورد × 0.1 ث)
  static const double visibleSeconds = 30.0;
  static const double recordInterval = 0.1; // 100 مللي ثانية لكل ريكورد

  double _scrollOffset = 0.0;
  late ScrollController _speedChartController;
  late ScrollController _accelerationChartController;

  @override
  void initState() {
    super.initState();
    _speedChartController = ScrollController();
    _accelerationChartController = ScrollController();
  }

  @override
  void dispose() {
    _speedChartController.dispose();
    _accelerationChartController.dispose();
    super.dispose();
  }

  double _calculateAverageSpeed() {
    if (widget.fencingData.isEmpty) return 0.0;
    double totalSpeed = widget.fencingData.fold(0.0, (sum, data) => sum + data.speed.abs());
    return totalSpeed / widget.fencingData.length;
  }

  double _calculateMaxForwardSpeed() {
    var forwardSpeeds = widget.fencingData.where((data) => data.direction == 1).map((data) => data.speed.abs());
    return forwardSpeeds.isEmpty ? 0.0 : forwardSpeeds.reduce(math.max);
  }

  double _calculateMaxBackwardSpeed() {
    var backwardSpeeds = widget.fencingData.where((data) => data.direction == -1).map((data) => data.speed.abs());
    return backwardSpeeds.isEmpty ? 0.0 : backwardSpeeds.reduce(math.max);
  }

  @override
  Widget build(BuildContext context) {
    List<double> speedData = widget.fencingData.map((data) => data.speed).toList();
    List<int> directionData = widget.fencingData.map((data) => data.direction).toList();
    // List<double> accelerationData = widget.fencingData.map((data) => data.acceleration).toList();
    log("Speed Data: $speedData");
    log('speed length ${speedData.length}');
    double avgSpeed = _calculateAverageSpeed();
    double maxForwardSpeed = _calculateMaxForwardSpeed();
    double maxBackwardSpeed = _calculateMaxBackwardSpeed();
    int directionChanges = directionData.length < 2
        ? 0
        : directionData.asMap().entries.skip(1).where((entry) => entry.value != directionData[entry.key - 1]).length;
    int forwardCount = directionData.where((d) => d == 1).length;
    int backwardCount = directionData.where((d) => d == -1).length;
    int stoppedCount = directionData.where((d) => d == 0).length;

    // حساب الوقت الكلي بالثواني
    double totalTime = widget.fencingData.length * recordInterval;
    // double visibleRecords = visibleSeconds / recordInterval; // عدد الريكوردات في النطاق المرئي

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (speedData.isEmpty)
            const Center(child: Text("No data available yet",style: TextStyle(color: Colors.black),))
          else ...[
            _buildSectionTitle('Speed Over Time'),
            SizedBox(
              height: 200.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _speedChartController,
                child: SizedBox(
                  width: totalTime * 50.w, // عرض الـ Chart بناءً على الوقت الكلي
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final timeInSeconds = value * recordInterval;
                              return Text(
                                '${timeInSeconds.toInt()}s',
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()} cm/s',
                              style: TextStyle(color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: speedData.length.toDouble() - 1,
                      minY: -1* math.max(5.0, maxBackwardSpeed ),
                      maxY: math.max(5.0, maxForwardSpeed),
                      lineBarsData: [
                        LineChartBarData(
                          spots: speedData
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            _buildSectionTitle('Direction Breakdown'),
            SizedBox(
              height: 150.h,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: forwardCount.toDouble(),
                      color: Colors.green,
                      title: 'Forward\n${(forwardCount / directionData.length * 100).toStringAsFixed(1)}%',
                    ),
                    PieChartSectionData(
                      value: backwardCount.toDouble(),
                      color: Colors.red,
                      title: 'Backward\n${(backwardCount / directionData.length * 100).toStringAsFixed(1)}%',
                    ),
                    PieChartSectionData(
                      value: stoppedCount.toDouble(),
                      color: Colors.grey,
                      title: 'Stopped\n${(stoppedCount / directionData.length * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // _buildSectionTitle('Acceleration Profile'),
            // SizedBox(
            //   height: 200.h,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     controller: _accelerationChartController,
            //     child: SizedBox(
            //       width: totalTime * 50.w,
            //       child: LineChart(
            //         LineChartData(
            //           gridData: const FlGridData(drawVerticalLine: false),
            //           titlesData: FlTitlesData(
            //             bottomTitles: AxisTitles(
            //               sideTitles: SideTitles(
            //                 showTitles: true,
            //                 reservedSize: 30,
            //                 getTitlesWidget: (value, meta) {
            //                   final timeInSeconds = value * recordInterval;
            //                   return Text(
            //                     '${timeInSeconds.toInt()}s',
            //                     style: TextStyle(color: Colors.white, fontSize: 12.sp),
            //                   );
            //                 },
            //               ),
            //             ),
            //             leftTitles: AxisTitles(
            //               sideTitles: SideTitles(
            //                 showTitles: true,
            //                 reservedSize: 40,
            //                 getTitlesWidget: (value, meta) => Text(
            //                   '${value.toInt()} cm/s²',
            //                   style: TextStyle(color: Colors.white, fontSize: 12.sp),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           borderData: FlBorderData(show: false),
            //           minX: 0,
            //           maxX: accelerationData.length.toDouble() - 1,
            //           minY: -20,
            //           maxY: 20,
            //           lineBarsData: [
            //             LineChartBarData(
            //               spots: accelerationData
            //                   .asMap()
            //                   .entries
            //                   .map((e) => FlSpot(e.key.toDouble(), e.value))
            //                   .toList(),
            //               isCurved: true,
            //               color: Colors.orange,
            //               barWidth: 3,
            //               dotData: const FlDotData(show: false),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 20.h),

            _buildSectionTitle('Quick Stats'),
            _buildStatCard('Average Speed', '${avgSpeed.toStringAsFixed(1)} cm/s', Colors.blueAccent),
            _buildStatCard('Max Forward Speed', '${maxForwardSpeed.toStringAsFixed(1)} cm/s', Colors.green),
            _buildStatCard('Max Backward Speed', '${maxBackwardSpeed.toStringAsFixed(1)} cm/s', Colors.red),
            _buildStatCard('Direction Changes', '$directionChanges', Colors.green),
            SizedBox(height: 20.h),
            _buildSaveButton('Save Analysis', () {
              // viewModel.onSaveAnalysisClicked();
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return customElevatedButtonWithoutStream(
      onPressed: onPressed,
      child: Text(
        text,
        style: getRegularStyle(fontSize: FontSize.s16, color: ColorManager.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            Text(value,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String insight, IconData icon) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30.sp),
        title: Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
        subtitle: Text(insight, style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
      ),
    );
  }
}