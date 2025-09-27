import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/common/reusable/charts/live_chart.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/player_header.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/fencing_training/fencing_training_view_model.dart';
import 'package:tranex_users/presentation/fencing_training/nfc_status_widget.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FencingTrainingView extends StatefulWidget {
  final int device;

  const FencingTrainingView({super.key, required this.device});

  static const routeName = '/fencing_training';

  @override
  State<FencingTrainingView> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<FencingTrainingView>
    with TickerProviderStateMixin {
  late final FencingTrainingViewModel vm;

  final _minutesCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  late final AnimationController _pointsAnim;

  @override
  void initState() {
    super.initState();

    vm = context.read<FencingTrainingViewModel>();
    vm.setContext(context);
    vm.connectToDevice(widget.device);

    _pointsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    vm.dispose();
    _pointsAnim.dispose();
    super.dispose();
  }

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure?',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Are you sure you want to leave this page?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text(
                'Never mind',
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text(
                'Leave',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Fencing Training'),
            elevation: 4,
          ),
          body: StreamBuilder<StateFlow>(
            stream: vm.outputState,
            builder: (context, snapshot) =>
            snapshot.data?.getScreenWidget(
              context,
              getBody(),
            ) ??
                getBody(),
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return StreamBuilder(
        stream: vm.statusStream,
        builder: (context, snap) {
          final status = snap.data ?? TrainingStatus.waitingBluetooth;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                StreamBuilder<TraineeData?>(
                  stream: vm.playerDataStream,
                  builder: (context, playerSnap) {
                    final player = playerSnap.data;
                    if (status == TrainingStatus.waitingBluetooth ||
                        status == TrainingStatus.waitingNFC ||
                        status == TrainingStatus.checkingNFC ||
                        status == TrainingStatus.errorNFC ||
                        player == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 8.h, left: 16.w, right: 16.w, bottom: 8.h),
                      child: PlayerHeader(
                        traineeData: player,
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBody(status),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildBody(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.waitingBluetooth:
        return const Center(
            child: SizedBox(
                width: 100,
                height: 100,
                child: NfCWidget(iconPath: JsonAssets.loading)));
      case TrainingStatus.waitingNFC:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NfCWidget(iconPath: JsonAssets.enterCard),
            SizedBox(height: 16.h),
            customElevatedButtonWithoutStream(
              onPressed: () {
                vm.scanQRCode(context);
              },
              child: Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      case TrainingStatus.checkingNFC:
        return const NfCWidget(iconPath: JsonAssets.loadingCard);
      case TrainingStatus.errorNFC:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NfCWidget(iconPath: JsonAssets.errorCard),
            SizedBox(height: 16.h),
            customElevatedButtonWithoutStream(
              onPressed: () {
                vm.scanQRCode(context);
              },
              child: Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      case TrainingStatus.testMode:
        return _buildTestMode();
      case TrainingStatus.ready:
      case TrainingStatus.inTraining:
      case TrainingStatus.ended:
      case TrainingStatus.disconnected:
        return Center(child: _buildTrainingArea());
    }
  }

  Widget _buildTestMode() {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: isTablet ? 48.w : 16.w,
          right: isTablet ? 48.w : 16.w,
          top: isTablet ? 24.h : 12.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: isTablet ? 32.h : 24.h),
            Text(
              "Weapon Test Mode",
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isTablet ? 16.h : 12.h),
            Text(
              "Strike with the weapon to ensure everything works.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isTablet ? 32.h : 24.h),
            _buildPointIndicator(),
            SizedBox(height: isTablet ? 32.h : 24.h),
            _buildTargetsForm(context),
            SizedBox(height: isTablet ? 32.h : 24.h),
            SizedBox(
              width: isTablet ? 400 : double.infinity,
              child: customElevatedButtonWithoutStream(
                onPressed: _onStartTrainingPressed,
                child: Text(
                  'Start Training',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 32.h : 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetsForm(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _minutesCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: isTablet ? 20 : 16),
            decoration: InputDecoration(
              labelText: 'Time (in minutes)',
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 12),
          TextField(
            controller: _pointsCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: isTablet ? 20 : 16),
            decoration: InputDecoration(
              labelText: 'Number of Points',
              labelStyle: TextStyle(fontSize: isTablet ? 18 : 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  void _onStartTrainingPressed() {
    final minutes = _minutesCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_minutesCtrl.text.trim());
    final pts = _pointsCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_pointsCtrl.text.trim());
    if (minutes == null && pts == null) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide time or points target'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (pts != null && pts <= 1) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set more than 1 point to start training'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (minutes != null && minutes < 1) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Please set a time other than 0 minutes to start training'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    vm.finishTestAndArmTraining(minutes: minutes, targetPts: pts);
  }

  Widget _buildTrainingArea() {
    return StreamBuilder<int>(
      stream: vm.pointsStream,
      builder: (context, pointsSnap) {
        final points = pointsSnap.data ?? 0;

        _pointsAnim.forward(from: 0);

        return ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PointsCounter(
                  points: points,
                  controller: _pointsAnim,
                  targetPoints: vm.targetPoints,
                ),
                _buildTimerRing(),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<PlayerMovementData>(
              stream: vm.movementDataStream,
              builder: (context, snapshot) {
                return CustomLiveChart(
                  playerId: 1,
                  matchDataStream: vm.movementDataStream,
                  pointRecordStream: vm.pointRecordStream,
                );
              },
            ),
            16.verticalSpace,
            Align(alignment: Alignment.center, child: _buildAverageTouchTime()),
            16.verticalSpace,
            _buildSummaryFooter(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPointIndicator() {
    return StreamBuilder<bool>(
      stream: vm.pointIndicatorStream,
      builder: (context, indicatorSnap) {
        final hasPoints = indicatorSnap.data ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasPoints ? Colors.green.shade400 : Colors.red.shade400,
            boxShadow: [
              BoxShadow(
                color: (hasPoints ? Colors.green : Colors.red).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              hasPoints ? Icons.check : Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerRing() {
    return StreamBuilder<int?>(
      stream: vm.timeLeftMsStream,
      builder: (context, timeLeftSnap) {
        final timeLeftMs = timeLeftSnap.data;
        if (timeLeftMs == null) {
          return StreamBuilder<int>(
            stream: vm.elapsedMsStream,
            builder: (context, elapsedSnap) {
              final elapsed = elapsedSnap.data ?? 0;
              return Column(
                children: [
                  Text(
                    _formatMs(elapsed),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Elapsed Time",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            },
          );
        }

        final targetMs = (vm.targetMinutes! * 60 * 1000);
        final left = timeLeftMs.clamp(0, targetMs);
        final progress = 1 - (left / targetMs);
        final color = progress < 0.5
            ? Colors.green.shade400
            : progress < 0.8
            ? Colors.orange.shade400
            : Colors.red.shade400;

        return Column(
          children: [
            SizedBox(
              width: 150.w,
              height: 150.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    padding: const EdgeInsets.all(10),
                    value: progress,
                    constraints: const BoxConstraints.expand(),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      _formatMs(left),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Time Remaining",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAverageTouchTime() {
    return StreamBuilder<List<PointDataEntity>>(
      stream: vm.pointRecordStream.map((points) => vm.recordedPoints),
      builder: (context, snapshot) {
        final points = snapshot.data ?? [];
        if (points.isEmpty) {
          return Text(
            "No touches yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          );
        }

        if (points.length < 2) {
          return Text(
            "Average time between touches: 0 seconds",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          );
        }

        final intervals = <int>[];
        for (int i = 1; i < points.length; i++) {
          intervals.add(points[i].timeInMs - points[i - 1].timeInMs);
        }
        final averageMs = intervals.reduce((a, b) => a + b) / intervals.length;
        final averageSec = (averageMs / 1000).toStringAsFixed(2);

        return Text(
          "Average time between touches: $averageSec seconds",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        );
      },
    );
  }

  Widget _buildSummaryFooter() {
    return StreamBuilder<TrainingStatus>(
      stream: vm.statusStream,
      builder: (context, snap) {
        final st = snap.data ?? TrainingStatus.inTraining;
        final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

        return StreamBuilder<bool>(
          stream: vm.isPausedStream,
          builder: (context, pauseSnap) {
            final isPaused = pauseSnap.data ?? false;

            return Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: isTablet ? 400 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPaused) {
                      vm.resumeTraining();
                    } else {
                      vm.pauseTraining();
                    }
                  },
                  child: Text(
                    isPaused ? 'Resume' : 'Stop',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              16.verticalSpace,
              SizedBox(
                width: isTablet ? 400 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    vm.stopTraining();
                  },
                  child: const Text(
                    'End and Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ]);
          },
        );
      },
    );
  }

  String _formatMs(int ms) {
    final totalSec = (ms / 1000).floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

class _PointsCounter extends StatelessWidget {
  final int points;
  final AnimationController controller;
  final int? targetPoints;

  const _PointsCounter(
      {required this.points, required this.controller, this.targetPoints});

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));

    return Column(
      children: [
        ScaleTransition(
          scale: scale,
          child: Text(
            '$points',
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ).animate().fadeIn(duration: 200.ms),
        _buildPointsProgress(points),
      ],
    );
  }

  Widget _buildPointsProgress(int points) {
    if (targetPoints == null) {
      return const SizedBox.shrink();
    }

    final progress = points / targetPoints!;
    final color = progress > 0.7
        ? Colors.green.shade400
        : progress > 0.5
        ? Colors.yellow.shade400
        : progress > 0.2
        ? Colors.orange.shade400
        : Colors.red.shade400;

    return Column(
      children: [
        Container(
          width: 150.w,
          height: 10,
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Points Progress: $points/$targetPoints",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}