import 'package:tranex_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
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
  final FencingMatchViewModel viewModel;

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
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isControlEnabled =
        matchStatus == MatchStatus.paused || matchStatus == MatchStatus.inMatch;

    print("MatchControlPanel build: status=$matchStatus");
    return Column(
      children: [
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
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSize.s20.w),
            ],
          ),
        ),
        SizedBox(height: 10.h),
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
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
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
                fontSize: FontSize.s16,
                color: Colors.black,
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
        if (matchStatus == MatchStatus.waitingBluetoothPlayer1 ||
            matchStatus == MatchStatus.waitingBluetoothPlayer2)
          Column(
            children: [
              Text(
                matchStatus == MatchStatus.waitingBluetoothPlayer1
                    ? 'Please select device for Player 1'
                    : 'Please select device for Player 2',
                style: TextStyle(
                  fontSize: FontSize.s16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Scan for Devices button pressed");
                      viewModel.chooseDevice(context);
                    },
                    child: Text(
                      'Scan for Devices',
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        const Spacer(flex: 2),
        Visibility(
          visible: matchStatus == MatchStatus.paused ||
              matchStatus == MatchStatus.waitingNFC2,
          child: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onStartPressed : null,
                child: Text(
                  'Start',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onPausePressed : null,
                child: Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isControlEnabled ? onDoublePressed : null,
                child: Text(
                  'Double',
                  style: TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isControlEnabled ? onEndPressed : null,
              child: Text(
                'End',
                style: TextStyle(
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
