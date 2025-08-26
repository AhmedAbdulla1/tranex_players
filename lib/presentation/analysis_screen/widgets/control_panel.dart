import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class MatchControlPanel extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onStartPressed;
  final VoidCallback onPausePressed;
  final VoidCallback onDoublePressed;
  final VoidCallback onEndPressed;
  final StopWatchTimer stopWatchTimer;
  final StopWatchTimer actualPlayTimer;
  final MatchStatus matchStatus;

  const MatchControlPanel({
    super.key,
    required this.onBackPressed,
    required this.onPausePressed,
    required this.onDoublePressed,
    required this.onStartPressed,
    required this.onEndPressed,
    required this.stopWatchTimer,
    required this.actualPlayTimer,
    required this.matchStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isControlEnabled =
        matchStatus == MatchStatus.paused || matchStatus == MatchStatus.inMatch;

    return Column(
      children: [
        // العنوان وزرار الرجوع
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r)),
            color: ColorManager.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: AppSize.s20,
                ),
                onPressed: onBackPressed,
              ),
              Text(
                'Fencing Match',
                style: TextStyle(
                  fontSize: FontSize.s20, // حجم متجاوب
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // المؤقت ووقت اللعب الفعلي
        SizedBox(height: 10.h), // تباعد رأسي متجاوب
        StreamBuilder<int>(
          stream: stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!,
              milliSecond: false,
              hours: false,
            );
            return Text(
              displayTime,
              style: TextStyle(
                fontSize: FontSize.s20, // حجم متجاوب
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          },
        ),
        SizedBox(height: 10.h), // تباعد رأسي متجاوب
        StreamBuilder<int>(
          stream: actualPlayTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!,
              milliSecond: false,
              hours: false,
            );
            return Text(
              'Actual Play Time: $displayTime',
              style: TextStyle(
                fontSize: FontSize.s16, // حجم متجاوب
                color: Colors.black,
              ),
            );
          },
        ),
        const Spacer(
          flex: 2,
        ),

         Visibility(
          visible: matchStatus == MatchStatus.paused ||
              matchStatus == MatchStatus.waitingNFC2,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onStartPressed : null,
                child: Text(
                  'Start',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,// حجم متجاوب
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: matchStatus == MatchStatus.inMatch,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onPausePressed : null,
                child: Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,// حجم متجاوب
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: matchStatus == MatchStatus.inMatch,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onDoublePressed : null,
                child: Text(
                  'Double',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,// حجم متجاوب
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isControlEnabled ? onEndPressed : null,
              child: Text(
                'End',
                style: TextStyle(
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.bold,// حجم متجاوب
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const Spacer()
      ],
    );
  }
}
