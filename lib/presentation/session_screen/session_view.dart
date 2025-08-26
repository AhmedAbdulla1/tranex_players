import 'dart:async';
import 'dart:developer';

import 'package:firesport_users/presentation/analysis_screen/widgets/nfc_statuse_widget.dart';
import 'package:firesport_users/presentation/common/reusable/custom_button.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/session_screen/analysis_screen.dart';
import 'package:firesport_users/presentation/session_screen/end_session_view.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:firesport_users/presentation/session_screen/fencing_screen.dart';
import 'package:firesport_users/presentation/session_screen/session_view_model.dart';
import 'package:firesport_users/presentation/session_screen/widgets/custom_bar_chart.dart';
import 'package:firesport_users/presentation/session_screen/widgets/speed_chart.dart';
import 'package:firesport_users/presentation/session_screen/widgets/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TrainingViewBar extends StatefulWidget {
  const TrainingViewBar({
    super.key,
    required this.device,
    this.fencing = false,
  });

  final DiscoveredDevice device;
  final bool fencing;

  @override
  State<TrainingViewBar> createState() => _TrainingViewBarState();
}

class _TrainingViewBarState extends State<TrainingViewBar> {
  final InTrainingViewModel _viewModel = InTrainingViewModel();
  List<ChartData> _chartData = [];
  List<FencingDataModel> _fencingChartData = [];
  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onStopped: () => print('onStopped'),
  );
  int _repsCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.isFencing = widget.fencing;
    _viewModel.start();
    stopWatchTimer.secondTime.listen((time) {
     _viewModel.timeBySeconds=time;
    });
    // _viewModel.checkTraineeExist('560E8400E29B41D4A716446655440000');
    _viewModel.connectToDevice(widget.device);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    stopWatchTimer.dispose();
    super.dispose();
  }
  Timer? _countdownTimer; // Store the timer instance
  bool _isCountingDown = false;
  void _startCountdown(int idleTime) {

    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
    }
    _isCountingDown = true;
    // Start new timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (idleTime > 0) {
        idleTime--;
        _viewModel.inputIdleTime.add(idleTime);
      } else {
        log('Countdown finished');
        stopWatchTimer.onStartTimer();
        log('Countdown Start');
        _viewModel.setStartListening(true);
        timer.cancel();
        _isCountingDown = false; // Reset flag
        _countdownTimer = null; // Clear timer reference
      }
    });
  }
  void cancelCountdown() {
    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
      _countdownTimer = null;
      _isCountingDown = false;
      log('Countdown cancelled manually');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: _buildAppBar(),
      body: StreamBuilder<StateFlow>(
        stream: _viewModel.outputState,
        builder: (context, snapshot) {
          return snapshot.data?.getScreenWidget(
            context,
            _buildContent(),
          ) ??
              _buildContent();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: StreamBuilder<String>(
        stream: _viewModel.outExercise,
        builder: (context, snapshot) => Text(
          snapshot.data ?? AppStrings.exercises,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<SessionStatus>(
      stream: _viewModel.statusStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data!) {
            case SessionStatus.idle:
            case SessionStatus.fencing:
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StopwatchComponent(
                          stopWatchTimer: stopWatchTimer,
                        ),
                        _viewModel.isFencing
                            ? _buildFencingChart()
                            : _buildDashboard(),
                        _buildSaveButtons(),
                      ],
                    ),
                  ),
                  _buildIdleTimeOverlay(),
                ],
              );
            case SessionStatus.finished:
              return EndSessionView(
                previousData: _viewModel.previousData,
                currentData: _viewModel.getData(),
                onSave: () {
                  _viewModel.save().then((value) {
                    if (value) {

                      _viewModel.delete();
                      _viewModel.sendReconfirm();
                      _viewModel.inputStatus.add(SessionStatus.waitingRFID);
                    }
                  });
                },
                onExit: () {
                  _viewModel.save().then(
                          (value) {
                            log('value $value', name: 'onExit');
                            value ? Navigator.pop(context) : null;
                          });
                },
              );
            case SessionStatus.analyzing:
              return FencingAnalysisScreen(
                fencingData: _fencingChartData,
              );
            case SessionStatus.waitingForCheck:
              return const NfCWidget(
                iconPath: JsonAssets.loadingCard,
              );
            case SessionStatus.waitingRFID:
              return const NfCWidget(
                iconPath: JsonAssets.enterCard,
              );
            case SessionStatus.errorRFID:
              return const NfCWidget(
                iconPath: JsonAssets.error,
              );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildFencingChart() {
    return SizedBox(
      width: double.infinity,
      child: StreamBuilder<FencingDataModel>(
        stream: _viewModel.outFencingData,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            _fencingChartData.add(snapshot.data!);
            if (_fencingChartData.length <= 1) {
              stopWatchTimer.onStartTimer();
            }
          }
          return FencingDashboard(
            dataModel: snapshot.data,
          );
        },
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        SizedBox(height: AppPadding.p20.h),
        SpeedChart(
          speedStream: _viewModel.outSpeed,
          maxSpeed: 15,
        ),
        SizedBox(height: AppPadding.p20.h),
        StreamBuilder<ChartData?>(
          stream: _viewModel.outData,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              _chartData.add(snapshot.data!);
            } else {
              _chartData.clear();
              stopWatchTimer.onResetTimer();
            }
            return CustomBarChart(
              chartData: _chartData,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p40.w,
        vertical: AppPadding.p20.h,
      ),
      child: Column(
        children: [
          _buildSaveButton(AppStrings.delete, () {
            stopWatchTimer.onResetTimer();
            _fencingChartData.clear();
            _chartData.clear();
            _repsCount = 0;
            _viewModel.delete();
          }),
          SizedBox(height: AppPadding.p20.h),
          _buildSaveButton('End', () {
            if (!_viewModel.isFencing) {
              stopWatchTimer.onStopTimer();
              _viewModel.getPreviousAverage().then(
                    (_) => _viewModel.inputStatus.add(SessionStatus.finished),
              );
            } else {
              _viewModel.inputStatus.add(SessionStatus.analyzing);
              _viewModel.sendOnSave();
            }
            _viewModel.sendEnd();
          }),
          SizedBox(height: AppPadding.p20.h),
        ],
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return customElevatedButton(
      stream: _viewModel.data,
      onPressed: onPressed,
      text: text,
    );
  }

  Widget _buildIdleTimeOverlay() {
    return StreamBuilder<int>(
      stream: _viewModel.outIdleTime,
      builder: (context, snapshot) {
        int idleTime = snapshot.data ?? 3;
        if (idleTime > 0) {
          _startCountdown(idleTime);
          return _buildIdleOverlay(idleTime);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildIdleOverlay(int idleTime) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black38,
      child: Center(
        child: StreamBuilder<bool>(
          stream: _viewModel.outAutoStart,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Text(
                idleTime.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSize.s130,
                  fontWeight: FontWeight.w600,
                ),
              );
            } else {
              return customElevatedButtonWithoutStream(
                onPressed: () {
                  _viewModel.inputAutoStart.add(true);
                  _viewModel.sendStart();
                },
                child: const Text("Start"),
              );
            }
          },
        ),
      ),
    );
  }
}

