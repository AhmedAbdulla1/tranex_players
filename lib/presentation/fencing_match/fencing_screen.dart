import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FencingDashboard extends StatefulWidget {
  const FencingDashboard({super.key,  this.dataModel});

  final MatchDataEntity? dataModel;

  @override
  _FencingDashboardState createState() => _FencingDashboardState();
}

class _FencingDashboardState extends State<FencingDashboard>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<double> speedNotifier;
  late ValueNotifier<int> directionNotifier;
  double acceleration = 0.0;

  late AnimationController _controller;
  late Animation<double> _speedAnimation;


  @override
  void initState() {
    super.initState();

    speedNotifier = ValueNotifier(0.0);
    directionNotifier = ValueNotifier(0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _speedAnimation = Tween<double>(begin: 0, end: speedNotifier.value)
        .animate(_controller)
      ..addListener(() {
        speedNotifier.value = _speedAnimation.value;
      });

    // تحديث أولي بناءً على الـ dataModel
    _updateData(widget.dataModel?? MatchDataEntity(direction: 0, speed: 0,timeInMs: 0));
  }

  @override
  void didUpdateWidget(FencingDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataModel != widget.dataModel) {
      _updateData(widget.dataModel?? MatchDataEntity(direction: 0, speed: 0,timeInMs: 0)); // تحديث البيانات لما الـ dataModel يتغير
    }
  }

  void _updateData(MatchDataEntity data) {
    int direction = data.direction;
    double speed = (data.speed);

    // تحديث الـ Animation للسرعة
    _speedAnimation = Tween<double>(begin: speedNotifier.value, end: speed)
        .animate(_controller);
    _controller.forward(from: 0);

    // تحديث الـ direction لو اتغير
    if (directionNotifier.value != direction) {
      directionNotifier.value = direction;
    }

  }

  @override
  void dispose() {
    speedNotifier.dispose();
    directionNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: speedNotifier,
              builder: (context, speed, child) {
                return SpeedGauge(
                  speed: speed, // السرعة بالسم/ث
                  direction: directionNotifier.value,
                  maxSpeed: 10.0, // تحديث الـ maxSpeed حسب المحيط
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Speed Gauge Widget
class SpeedGauge extends StatelessWidget {
  final double speed;
  final int direction;
  final double maxSpeed;

  const SpeedGauge({
    super.key,
    required this.speed,
    required this.direction,
    required this.maxSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      height: 200.w,
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
        painter: SpeedGaugePainter(speed: speed, maxSpeed: maxSpeed),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${speed.toStringAsFixed(1)} m/s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              DirectionIndicator(direction: direction),
            ],
          ),
        ),
      ),
    );
  }
}

// Speed Gauge Painter (دائرة مفتوحة مع مؤشر متغير اللون)
class SpeedGaugePainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  SpeedGaugePainter({required this.speed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..color = Colors.grey[700]!;

    const startAngle = math.pi * 0.75; // 45 درجة
    const sweepAngleBackground = math.pi * 1.5; // 270 درجة

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngleBackground,
      false,
      paint,
    );

    // Draw speed arc with dynamic color
    double speedRatio = speed / maxSpeed; // نسبة السرعة للسرعة القصوى
    paint.color = Color.lerp(
        Colors.blueAccent, Colors.red, speedRatio)!; // تدرج من أزرق لأحمر
    double sweepAngleSpeed =
        (speed / maxSpeed) * math.pi * 1.5; // مقسم على 270 درجة
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

// Direction Indicator Widget
class DirectionIndicator extends StatelessWidget {
  final int direction;

  const DirectionIndicator({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (direction) {
      case 1:
        color = Colors.green;
        icon = Icons.arrow_forward;
        label = 'Forward';
        break;
      case -1:
        color = Colors.red;
        icon = Icons.arrow_back;
        label = 'Backward';
        break;
      default:
        color = Colors.grey;
        icon = Icons.pause;
        label = 'Stopped';
    }

    return Container(
      width: 90.w,
      height: 30.w,
      // padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            // رجعنا لـ ValueKey(direction) عشان يتتبع التغيير بناءً على الـ direction بس
            child: Icon(icon, size: 15, color: color,),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
