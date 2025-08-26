
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchComponent extends StatefulWidget {
  final StopWatchTimer
      stopWatchTimer; // Pass an external StopWatchTimer instance
  // Callback when the timer is stopped, returns elapsed time

  const StopwatchComponent({
    Key? key,
    required this.stopWatchTimer,
  }) : super(key: key);

  @override
  _StopwatchComponentState createState() => _StopwatchComponentState();
}

class _StopwatchComponentState extends State<StopwatchComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer Display
        StreamBuilder<int>(
          stream: widget.stopWatchTimer.secondTime, // Listen to raw time
          initialData: 0,
          builder: (context, snapshot) {
            log('second time ${snapshot.data}');
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!*1000,
              milliSecond: false,
              hours: false,
            );
            return Text(
              displayTime,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.stopWatchTimer
        .dispose(); // Dispose the timer when the widget is destroyed
    super.dispose();
  }
}
