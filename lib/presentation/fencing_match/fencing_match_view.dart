import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/common/reusable/charts/live_chart.dart';
import 'package:tranex_users/presentation/common/reusable/player_header.dart';
import 'package:tranex_users/presentation/fencing_match/analysis_match_landscape.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_landscape.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:tranex_users/presentation/fencing_match/widgets/nfc_status_widget.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';

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
          ? Colors.blue.withValues(alpha: 0.1)
          : Colors.red.withValues(
              alpha: 0.1,
            ),
      child: Column(
        children: [
          StreamBuilder<TraineeData>(
              stream: playerId == 1
                  ? viewModel.outputPlayer1Data
                  : viewModel.outputPlayer2Data,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: PlayerHeader(
                          playerId: playerId,
                          traineeData: snapshot.data!,
                        ),
                      )
                    : Container();
              }),
          SizedBox(height: AppSize.s20.h),
          Expanded(
            child: StreamBuilder<PlayerMovementData>(
                stream: playerId == 1
                    ? viewModel.outputPlayer1MatchData
                    : viewModel.outputPlayer2MatchData,
                builder: (context, snapshot) {
                  return CustomLiveChart(
                    playerId: playerId,
                    matchDataStream: playerId == 1
                        ? viewModel.outputPlayer1MatchData
                        : viewModel.outputPlayer2MatchData,
                    pointRecordStream: playerId == 1
                        ? viewModel.outputPlayer1Points
                        : viewModel.outputPlayer2Points,
                  );
                }),
          ),
          StreamBuilder<PointDataEntity>(
              stream: playerId == 1
                  ? viewModel.outputPlayer1Points
                  : viewModel.outputPlayer2Points,
              builder: (context, snapshot) {
                return Text(
                  'Points: ${playerId == 1 ? viewModel.player1Info.pointRecords.length : viewModel.player2Info.pointRecords.length}',
                  style: getRegularStyle(
                    fontSize: FontSize.s20,
                    color: ColorManager.black,
                  ),
                );
              }),
          SizedBox(height: AppSize.s20.h),
          buildPointButtons(),
          SizedBox(height: AppSize.s20.h),
        ],
      ),
    );
  }

  Widget buildPointButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: viewModel.currentStatus == MatchStatus.inMatch
                  ? () {
                      viewModel.addPointManually(playerId);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            12.verticalSpace,
            ElevatedButton(
              onPressed: viewModel.currentStatus == MatchStatus.inMatch
                  ? () {
                      viewModel.subtractPointManually(playerId);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: FontSize.s20,
                  fontWeight: FontWeight.bold,
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
    final bool isControlEnabled =
        status == MatchStatus.paused || status == MatchStatus.inMatch;
    print("MatchContentWidget build: status=$status");
    return Column(
      children: [
        Column(
          children: [
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
          ],
        ),
        20.verticalSpace,
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPlayerSide(1)),
              Expanded(child: _buildPlayerSide(2)),
            ],
          ),
        ),
        SizedBox(
          height: 150.h,
          child: Column(
            children: [
              if (status == MatchStatus.waitingBluetoothPlayer1 ||
                  status == MatchStatus.waitingBluetoothPlayer2)
                Column(
                  children: [
                    Text(
                      status == MatchStatus.waitingBluetoothPlayer1
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
                visible: status == MatchStatus.paused ||
                    status == MatchStatus.waitingNFC2,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isControlEnabled ? viewModel.startMatch : null,
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
                visible: status == MatchStatus.inMatch,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isControlEnabled ? viewModel.sendPause : null,
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
                visible: status == MatchStatus.inMatch,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isControlEnabled
                          ? () {
                              viewModel.addPointManually(1);
                              viewModel.addPointManually(2);
                            }
                          : null,
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
                    onPressed: isControlEnabled ? viewModel.endMatch : null,
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
            ],
          ),
        ),
        20.verticalSpace
      ],
    );
  }

  Widget _buildPlayerSide(int playerId) {
    print("Building PlayerSide for Player $playerId: status=$status");
    switch (status) {
      case MatchStatus.waitingBluetoothPlayer1:
      case MatchStatus.waitingBluetoothPlayer2:
        return const Center(
          child: Text('Waiting for WebSocket device...'),
        );
      case MatchStatus.waitingNFC1:
        return const NfCWidget(iconPath: JsonAssets.enterCard);
      case MatchStatus.waitingNFC2:
        if (playerId == 1) {
          return PlayerDashboard(playerId: 1, viewModel: viewModel);
        } else {
          return const NfCWidget(iconPath: JsonAssets.enterCard);
        }
      case MatchStatus.checkingNFC1:
        if (playerId == 1) {
          return const NfCWidget(iconPath: JsonAssets.loadingCard);
        } else {
          return const NfCWidget(iconPath: JsonAssets.enterCard);
        }
      case MatchStatus.checkingNFC2:
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

// Widget _buildControlButtons() {
//   return Padding(
//     padding: EdgeInsets.symmetric(
//       horizontal: AppPadding.p40.w,
//       vertical: AppPadding.p20.h,
//     ),
//     child: Column(
//       children: [
//         if (status == MatchStatus.paused) ...[
//           customElevatedButtonWithoutStream(
//             onPressed: () {
//               print("Resume button pressed");
//               viewModel.resumeMatch();
//             },
//             child: const Text(
//               'Resume',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//         if (status == MatchStatus.waitingNFC2) ...[
//           customElevatedButtonWithoutStream(
//             onPressed: () {
//               print("Start button pressed");
//               viewModel.startMatch();
//             },
//             child: const Text(
//               'Start',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//         customElevatedButtonWithoutStream(
//           onPressed: () {
//             print("End button pressed");
//             viewModel.endMatch();
//           },
//           child: const Text(
//             'End',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}

class FencingMatchView extends StatefulWidget {
  static const routeName = '/fencing_match';

  const FencingMatchView({super.key});

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
    _viewModel.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Initiating scanForDevices on init");
      _viewModel.chooseDevice(context);
    });
    _actualPlayTimer.rawTime.listen((time) {
      _viewModel.updateMatchTime(time);
    });
  }

  void _resetMatch() {
    _stopWatchTimer.onResetTimer();
    _actualPlayTimer.onResetTimer();
    _stopWatchTimer.onStartTimer();
    _viewModel.start();
  }

  @override
  void dispose() async {
    print("Disposing FencingMatchView");
    _viewModel.dispose();
    await _stopWatchTimer.dispose();
    await _actualPlayTimer.dispose();
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
    return OrientationBuilder(
      builder: (context, orientation) => SafeArea(
        right: false,
        left: false,
        // child:
        // PopScope(
        //   canPop: false,
        //   onPopInvokedWithResult: (bool didPop, result) async {
        //     if (didPop) {
        //       return;
        //     }
        //     final bool shouldPop = await _showBackDialog(context) ?? false;
        //     if (context.mounted && shouldPop) {
        //       dispose();
        //       Navigator.pop(context);
        //     }
        //   },
        child: Scaffold(
          backgroundColor: ColorManager.white,
          appBar: orientation == Orientation.portrait
              ? AppBar(
                  title: const Text('Fencing Match'),
                  centerTitle: true,
                )
              : null,
          body: _buildMatchContent(orientation),
        ),
      ),
      // ),
    );
  }

  Widget _buildMatchContent(Orientation orientation) {
    return StreamBuilder<MatchStatus>(
      stream: _viewModel.outputMatchStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? MatchStatus.waitingBluetoothPlayer1;
        print("MatchStatus StreamBuilder: status=$status");

        if (status == MatchStatus.inMatch && !_isMainTimerStarted) {
          print("Starting timers");
          _stopWatchTimer.onStartTimer();
          _actualPlayTimer.onStartTimer();
          _isMainTimerStarted = true;
        }
        if (status == MatchStatus.paused) {
          print("Pausing actualPlayTimer");
          _actualPlayTimer.onStopTimer();
        }
        if (status == MatchStatus.inMatch && _isMainTimerStarted) {
          print("Resuming actualPlayTimer");
          _actualPlayTimer.onStartTimer();
        }
        if (status == MatchStatus.ended) {
          print("Stopping timers and showing analysis");
          _stopWatchTimer.onStopTimer();
          _actualPlayTimer.onStopTimer();
          _isMainTimerStarted = false;
          return FencingAnalysisLandscapeView(
            player1Info: _viewModel.getPlayer1Info(),
            player2Info: _viewModel.getPlayer2Info(),
            onSave: () async {
              bool? saved = await _viewModel.saveMatch.call();
              if (saved != null && saved) {
                _resetMatch();
              }
            },
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
