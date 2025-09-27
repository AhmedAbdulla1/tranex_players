import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartTestScreen extends StatefulWidget {
  const ChartTestScreen({super.key});

  @override
  _ChartTestScreenState createState() => _ChartTestScreenState();
}

class _ChartTestScreenState extends State<ChartTestScreen> {
  List<ChartData1> speedData1 = []; // بيانات الرسم البياني الأول
  List<ChartData1> speedData2 = []; // بيانات الرسم البياني الثاني
  double currentTimeInSeconds = 0;
  late ZoomPanBehavior _zoomPanBehavior1;
  late ZoomPanBehavior _zoomPanBehavior2;
  late Timer _timer;
  late NumericAxisController _xAxisController1; // Controller للمحور الأفقي للرسم الأول
  late NumericAxisController _xAxisController2; // Controller للمحور الأفقي للرسم الثاني
  bool isRunning = true;
  double rangeStart = 0.0;
  double rangeEnd = 6.0;

  @override
  void initState() {
    super.initState();

    // إعداد ZoomPanBehavior لكل رسم بياني
    _zoomPanBehavior1 = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
    _zoomPanBehavior2 = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );

    // إعداد Timer لتوليد بيانات عشوائية كل 300 مللي ثانية
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (isRunning) {
        _generateRandomData();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateRandomData() {
    final random = Random();
    setState(() {
      currentTimeInSeconds += 0.3;

      // توليد بيانات للرسم البياني الأول
      double speed1 = random.nextDouble() * 20 - 10;
      speedData1.add(ChartData1(currentTimeInSeconds, speed1));

      // توليد بيانات للرسم البياني الثاني
      double speed2 = random.nextDouble() * 20 - 10;
      speedData2.add(ChartData1(currentTimeInSeconds, speed2));

      // تحديث النطاق المرئي (6 ثواني)
      double newMinX = currentTimeInSeconds - 3;
      double newMaxX = currentTimeInSeconds + 3;

      // تحديث النطاق المرئي للرسمين
      _xAxisController1.visibleMinimum = newMinX;
      _xAxisController1.visibleMaximum = newMaxX;
      _xAxisController2.visibleMinimum = newMinX;
      _xAxisController2.visibleMaximum = newMaxX;

      // تحديث نطاق الـ Range Selector ديناميكيًا
      if (isRunning) {
        rangeStart = newMinX;
        rangeEnd = newMaxX;
      }

      // // إزالة النقاط القديمة لو زادت عن 100 نقطة
      // if (speedData1.length > 100) {
      //   speedData1.removeAt(0);
      // }
      // if (speedData2.length > 100) {
      //   speedData2.removeAt(0);
      // }
    });
  }

  void _toggleData() {
    setState(() {
      isRunning = !isRunning;
    });
  }

  void _resetZoom() {
    _zoomPanBehavior1.reset();
    _zoomPanBehavior2.reset();
  }

  void _onRangeChanged(SfRangeValues values) {
    setState(() {
      rangeStart = values.start;
      rangeEnd = values.end;

      // تحديث النطاق المرئي للرسمين بناءً على الـ Range Selector
      _xAxisController1.visibleMinimum = rangeStart;
      _xAxisController1.visibleMaximum = rangeEnd;
      _xAxisController2.visibleMinimum = rangeStart;
      _xAxisController2.visibleMaximum = rangeEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Test Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // الرسم البياني الأول
                  Expanded(
                    child: Stack(
                      children: [
                        SfCartesianChart(
                          zoomPanBehavior: _zoomPanBehavior1,
                          primaryXAxis: NumericAxis(
                            interval: 1,
                            labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                            majorGridLines: MajorGridLines(
                              width: 0.5,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            onRendererCreated: (NumericAxisController controller) {

                              _xAxisController1 = controller;
                            },
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                            majorGridLines: MajorGridLines(
                              width: 0.5,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          series: <CartesianSeries>[
                            LineSeries<ChartData1, double>(
                              dataSource: speedData1,
                              xValueMapper: (ChartData1 data, _) => data.timeInSeconds,
                              yValueMapper: (ChartData1 data, _) => data.speed,
                              color: Colors.blue,
                              width: 2,
                              markerSettings: const MarkerSettings(isVisible: false),
                            ),
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            color: Colors.blueGrey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // الرسم البياني الثاني
                  Expanded(
                    child: SfCartesianChart(
                      zoomPanBehavior: _zoomPanBehavior2,
                      primaryXAxis: NumericAxis(
                        interval: 1,
                        labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                        majorGridLines: MajorGridLines(
                          width: 0.5,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        onRendererCreated: (NumericAxisController controller) {
                          _xAxisController2 = controller;
                        },
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: TextStyle(fontSize: 5.sp, color: Colors.black),
                        majorGridLines: MajorGridLines(
                          width: 0.5,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      series: <CartesianSeries>[
                        LineSeries<ChartData1, double>(
                          dataSource: speedData2,
                          xValueMapper: (ChartData1 data, _) => data.timeInSeconds,
                          yValueMapper: (ChartData1 data, _) => data.speed,
                          color: Colors.red, // لون مختلف للرسم الثاني
                          width: 2,
                          markerSettings: const MarkerSettings(isVisible: false),
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        color: Colors.blueGrey.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            // Range Selector للتحكم في الرسمين
            SfRangeSelector(
              min: 0.0,
              max: currentTimeInSeconds > 0 ? currentTimeInSeconds : 6.0,
              initialValues: SfRangeValues(rangeStart, rangeEnd),
              onChanged: _onRangeChanged,
              showLabels: true,
              showTicks: true,
              showDividers: true,
              interval: 40,
              child: Container(
                height: 50,
                color: Colors.grey.withOpacity(0.1),
                child: Center(
                  child: Text(
                    'Select Range: ${rangeStart.toStringAsFixed(1)} - ${rangeEnd.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: _toggleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                isRunning ? 'Stop' : 'Start',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData1 {
  final double timeInSeconds;
  final double speed;

  ChartData1(this.timeInSeconds, this.speed);
}