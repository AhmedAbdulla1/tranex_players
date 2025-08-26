import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class SpeedChart extends StatefulWidget {
  final Stream<double> speedStream;
  final double maxSpeed;

  const SpeedChart({
    super.key,
    required this.speedStream,
    required this.maxSpeed,
  });

  @override
  _SpeedChartState createState() => _SpeedChartState();
}

class _SpeedChartState extends State<SpeedChart>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<double> speedNotifier;
  late AnimationController _controller;
  late Animation<double> _speedAnimation;

  @override
  void initState() {
    super.initState();

    speedNotifier = ValueNotifier(0.0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _speedAnimation = Tween<double>(begin: 0, end: speedNotifier.value)
        .animate(_controller)
      ..addListener(() {
        speedNotifier.value = _speedAnimation.value;
      });

    widget.speedStream.listen((speed) {
      _updateSpeed(speed);
    });
  }

  void _updateSpeed(double speed) {
    _speedAnimation = Tween<double>(begin: speedNotifier.value, end: speed)
        .animate(_controller);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    speedNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: speedNotifier,
          builder: (context, speed, child) {
            return Container(
              width: 200.w, // Adjusted width to 200
              height: 200.w, // Adjusted height to 200
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue[800]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: SpeedChartPainter(speed: speed, maxSpeed: widget.maxSpeed),
                child: Center(
                  child: Text(
                    '${speed.toStringAsFixed(1)} rps',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SpeedChartPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  SpeedChartPainter({required this.speed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..color = Colors.grey[700]!;

    const startAngle = math.pi * 0.75;
    const sweepAngleBackground = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngleBackground,
      false,
      paint,
    );

    double speedRatio = speed / maxSpeed;
    paint.color = Color.lerp(Colors.blueAccent, Colors.red, speedRatio)!;
    double sweepAngleSpeed = (speed / maxSpeed) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngleSpeed,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}