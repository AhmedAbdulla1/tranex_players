import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/fencing_match/analysis_match_landscape.dart';
import 'package:firesport_users/presentation/fencing_match/analysis_match_view.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_landscape.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/nfc_statuse_widget.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:firesport_users/presentation/common/reusable/custom_button.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_screen.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'fencing_match_view_model.dart';

// ويدجت لعرض بيانات اللاعب أثناء المباراة
class PlayerDashboard extends StatelessWidget {
  final int playerId;
  final FencingMatchViewModel viewModel;

  const PlayerDashboard({
    super.key,
    required this.playerId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p16.w),
      color: playerId == 1
          ? Colors.blue.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Column(
        children: [
          StreamBuilder<TraineeData>(
              stream: null,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.traineeName ?? "Player ${playerId}',",
                  style: getBoldStyle(
                      fontSize: FontSize.s20, color: ColorManager.black),
                );
              }),
          SizedBox(height: AppSize.s20.h),
          StreamBuilder<PointDataEntity>(
              stream: playerId == 1
                  ? viewModel.outputPlayer1Points
                  : viewModel.outputPlayer2Points,
              builder: (context, snapshot) {
                return Text(
                  'Points: ${playerId == 1 ? viewModel.player1Info
                      .pointRecords.length : viewModel.player2Info
                      .pointRecords.length}',
                  style: getRegularStyle(
                      fontSize: FontSize.s16, color: ColorManager.black),
                );
              }
          ),
          SizedBox(height: AppSize.s20.h),
          Expanded(
            child: StreamBuilder<MatchDataEntity>(
                stream: playerId == 1
                    ? viewModel.outputPlayer1MatchData :
                viewModel.outputPlayer2MatchData,
                builder: (context, snapshot) {
                  return Center(
                    child: snapshot.data != null
                        ? FencingDashboard(
                      dataModel: snapshot.data,
                    )
                        : const Text(
                      'No Data Yet',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  );
                }
            ),
          ),
          SizedBox(height: AppSize.s20.h),
          ElevatedButton(
            onPressed: viewModel.currentStatus == MatchStatus.inMatch
                ? () {
              viewModel
                  .addPointManually(playerId); // إضافة نقطة يدويًا
            }
                : null,
            child: const Text(
              'Point',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: AppSize.s20.h),
        ],
      ),
    );
  }
}

// Custom Widget لمحتوى الماتش
class MatchContentWidget extends StatelessWidget {
  final FencingMatchViewModel viewModel;
  final StopWatchTimer stopWatchTimer;
  final StopWatchTimer actualPlayTimer;
  final VoidCallback resetMatch;
  final MatchStatus status;

  const MatchContentWidget({
    super.key,
    required this.viewModel,
    required this.stopWatchTimer,
    required this.actualPlayTimer,
    required this.resetMatch,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<int>(
          stream: stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!,
              milliSecond: false,
              hours: false,
            );
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p20.h),
              child: Text(
                displayTime,
                style: getBoldStyle(
                  fontSize: FontSize.s25,
                  color: ColorManager.black,
                ),
              ),
            );
          },
        ),
        StreamBuilder<int>(
          stream: actualPlayTimer.rawTime,
          initialData: 0,
          builder: (context, snapshot) {
            final displayTime = StopWatchTimer.getDisplayTime(
              snapshot.data!,
              milliSecond: false,
              hours: false,
            );
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p10.h),
              child: Text(
                'Actual Play Time: $displayTime',
                style: getRegularStyle(
                  fontSize: FontSize.s16,
                  color: ColorManager.black,
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPlayerSide(1)),
              Expanded(child: _buildPlayerSide(2)),
            ],
          ),
        ),
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildPlayerSide(int playerId) {
    switch (status) {
      case MatchStatus.waitingNFC1:
        return const NfCWidget(iconPath: JsonAssets.enterCard);

      case MatchStatus.waitingNFC2:
        if (playerId == 1) {
          return PlayerDashboard(playerId: 1, viewModel: viewModel);
        } else {
          return const NfCWidget(iconPath: JsonAssets.enterCard);
        }

      case MatchStatus.waitingForCheck1:
        if (playerId == 1) {
          return const NfCWidget(iconPath: JsonAssets.loadingCard);
        } else {
          return const NfCWidget(iconPath: JsonAssets.enterCard);
        }

      case MatchStatus.waitingForCheck2:
        if (playerId == 1) {
          return PlayerDashboard(playerId: 1, viewModel: viewModel);
        } else {
          return const NfCWidget(iconPath: JsonAssets.loadingCard);
        }

      case MatchStatus.errorNFC1:
        if (playerId == 1) {
          return const NfCWidget(iconPath: JsonAssets.errorCard);
        } else {
          return const NfCWidget(iconPath: JsonAssets.enterCard);
        }
      case MatchStatus.errorNFC2:
        if (playerId == 1) {
          return PlayerDashboard(playerId: 1, viewModel: viewModel);
        } else {
          return const NfCWidget(iconPath: JsonAssets.errorCard);
        }

      default:
        return PlayerDashboard(playerId: playerId, viewModel: viewModel);
    }
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p40.w,
        vertical: AppPadding.p20.h,
      ),
      child: Column(
        children: [
          if (status == MatchStatus.paused) ...[
            customElevatedButtonWithoutStream(
              onPressed: () {
                viewModel.startMatch(); // تعديل لـ Resume بدل Start
              },
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (status == MatchStatus.waitingNFC2) ...[
            customElevatedButtonWithoutStream(
              onPressed: () {
                viewModel.startMatch();
              },
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
          customElevatedButtonWithoutStream(
            onPressed: () {
              viewModel.endMatch();
            },
            child: const Text(
              'End',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// الشاشة الرئيسية
class FencingMatchView extends StatefulWidget {
  final DiscoveredDevice device;

  const FencingMatchView({super.key, required this.device});

  @override
  _FencingMatchViewState createState() => _FencingMatchViewState();
}

class _FencingMatchViewState extends State<FencingMatchView> {
  final FencingMatchViewModel _viewModel = FencingMatchViewModel();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final StopWatchTimer _actualPlayTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  bool _isMainTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _viewModel.device = widget.device;
    _viewModel.context = context;
    _viewModel.start();

    _actualPlayTimer.rawTime.listen((time) {
      final timeInSeconds = time;
      _viewModel.updateMatchTime(timeInSeconds);
    });
  }

  void _resetMatch() {
    _stopWatchTimer.onResetTimer();
    _actualPlayTimer.onResetTimer();
    _stopWatchTimer.onStartTimer();
    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _stopWatchTimer.dispose();
    _actualPlayTimer.dispose();
    super.dispose();
  }
  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?',style: TextStyle(color: Colors.black),),
          content: const Text('Are you sure you want to leave this page?',style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Never mind',),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Leave',style: TextStyle(color: Colors.red),),
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
    return OrientationBuilder(
      builder: (context, orientation) =>
          SafeArea(
            right: false,
            left: false,
            child: PopScope(
              canPop: false,
              // The result argument contains the pop result that is defined in `_PageTwo`.
              onPopInvokedWithResult: (bool didPop, result) async {
                if (didPop) {
                  return;
                }
                final bool shouldPop = await _showBackDialog(context) ?? false;
                if (context.mounted && shouldPop) {
                  Navigator.pop(context, );
                }
              },

              child: Scaffold(
                backgroundColor: ColorManager.white,
                appBar: orientation == Orientation.portrait
                    ? AppBar(
                  title: const Text('Fencing Match'),
                  centerTitle: true,
                )
                    : null,
                body: StreamBuilder<StateFlow>(
                  stream: _viewModel.outputState,
                  builder: (context, snapshot) {
                    return snapshot.data?.getScreenWidget(
                      context,
                      _buildMatchContent(orientation),
                    ) ??
                        _buildMatchContent(orientation);
                  },
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildMatchContent(Orientation orientation) {
    return StreamBuilder<MatchStatus>(
      stream: _viewModel.outputMatchStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? MatchStatus.waitingNFC1;

        // التحكم في الـ Timers
        if (status == MatchStatus.inMatch && !_isMainTimerStarted) {
          _stopWatchTimer.onStartTimer();
          _actualPlayTimer.onStartTimer();
          _isMainTimerStarted = true;
        }
        if (status == MatchStatus.paused) {
          _actualPlayTimer.onStopTimer(); // وقف الوقت الفعلي فقط
        }
        if (status == MatchStatus.inMatch && _isMainTimerStarted) {
          _actualPlayTimer.onStartTimer(); // استئناف الوقت الفعلي
        }
        if (status == MatchStatus.ended) {
          _stopWatchTimer.onStopTimer();
          _actualPlayTimer.onStopTimer();
          _isMainTimerStarted = false;
          return FencingAnalysisLandscapeView(
            player1Info: _viewModel.getPlayer1Info(),
            player2Info: _viewModel.getPlayer2Info(),
            onSave: _viewModel.saveMatchData,
          );
        }

        return orientation == Orientation.portrait
            ? MatchContentWidget(
          viewModel: _viewModel,
          stopWatchTimer: _stopWatchTimer,
          actualPlayTimer: _actualPlayTimer,
          resetMatch: _resetMatch,
          status: status,
        )
            : LandScapeMatchContentWidget(
            viewModel: _viewModel,
            stopWatchTimer: _stopWatchTimer,
            actualPlayTimer: _actualPlayTimer,
            resetMatch: _resetMatch,
            status: status);
      },
    );
  }
}
