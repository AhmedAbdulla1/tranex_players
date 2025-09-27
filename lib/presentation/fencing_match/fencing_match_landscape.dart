import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/common/reusable/charts/live_chart.dart';
import 'package:tranex_users/presentation/common/reusable/player_header.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:tranex_users/presentation/fencing_match/widgets/control_panel.dart';
import 'package:tranex_users/presentation/fencing_match/widgets/nfc_status_widget.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';

class LandScapeMatchContentWidget extends StatelessWidget {
  final FencingMatchViewModel viewModel;
  final StopWatchTimer stopWatchTimer;
  final StopWatchTimer actualPlayTimer;
  final VoidCallback resetMatch;
  final MatchStatus status;

  const LandScapeMatchContentWidget({
    super.key,
    required this.viewModel,
    required this.stopWatchTimer,
    required this.actualPlayTimer,
    required this.resetMatch,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    print("LandScapeMatchContentWidget build: status=$status");
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: MatchControlPanel(
                      onBackPressed: () {
                        Navigator.maybePop(context);
                      },
                      onPausePressed: viewModel.sendPause,
                      onStartPressed: viewModel.startMatch,
                      onDoublePressed: () {
                        viewModel.addPointManually(1);
                        viewModel.addPointManually(2);
                      },
                      onEndPressed: viewModel.endMatch,
                      stopWatchTimer: stopWatchTimer,
                      actualPlayTimer: actualPlayTimer,
                      matchStatus: status,
                      viewModel: viewModel)),
              Expanded(child: _buildPlayerSide(1)),
              Expanded(child: _buildPlayerSide(2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSide(int playerId) {
    print("Building PlayerSide for Player $playerId: status=$status");
    switch (status) {
      case MatchStatus.waitingBluetoothPlayer1:
      case MatchStatus.waitingBluetoothPlayer2:
        return Center(
          child: Text(
            'Waiting for Connect to device...',
            style: getRegularStyle(
              fontSize: FontSize.s16,
              color: ColorManager.black,
            ),
          ),
        );
      case MatchStatus.waitingNFC1:
        return const NfCWidget(iconPath: JsonAssets.enterCard);
      case MatchStatus.waitingNFC2:
        if (playerId == 1) {
          return PlayerSection(playerId: 1, viewModel: viewModel);
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
          return PlayerSection(playerId: 1, viewModel: viewModel);
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
          return PlayerSection(playerId: 1, viewModel: viewModel);
        } else {
          return const NfCWidget(iconPath: JsonAssets.errorCard);
        }
      default:
        return PlayerSection(playerId: playerId, viewModel: viewModel);
    }
  }
}

class PlayerSection extends StatefulWidget {
  final int playerId;
  final FencingMatchViewModel viewModel;

  const PlayerSection({
    super.key,
    required this.playerId,
    required this.viewModel,
  });

  @override
  State<PlayerSection> createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: widget.playerId == 1 ? Colors.blue : Colors.red,
    ).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shadowOpacity = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    (widget.playerId == 1
            ? widget.viewModel.outputPlayer1Points
            : widget.viewModel.outputPlayer2Points)
        .listen((_) {
      _animationController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      color: widget.playerId == 1
          ? Colors.blue.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<TraineeData>(
              stream: widget.playerId == 1
                  ? widget.viewModel.outputPlayer1Data
                  : widget.viewModel.outputPlayer2Data,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? PlayerHeader(
                        playerId: widget.playerId,
                        traineeData: snapshot.data!,
                      )
                    : Container();
              }),
          SizedBox(height: 10.h),
          Expanded(
              flex: 8,
              child: CustomLiveChart(
                playerId: widget.playerId,
                matchDataStream: widget.playerId == 1
                    ? widget.viewModel.outputPlayer1MatchData
                    : widget.viewModel.outputPlayer2MatchData,
                pointRecordStream: widget.playerId == 1
                    ? widget.viewModel.outputPlayer1Points
                    : widget.viewModel.outputPlayer2Points,
              )),
          SizedBox(height: 10.h),
          StreamBuilder<PointDataEntity>(
              stream: widget.playerId == 1
                  ? widget.viewModel.outputPlayer1Points
                  : widget.viewModel.outputPlayer2Points,
              builder: (context, snapshot) {
                final pointsCount = widget.playerId == 1
                    ? widget.viewModel.player1Info.pointRecords.length
                    : widget.viewModel.player2Info.pointRecords.length;
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(4.h),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: (widget.playerId == 1
                                      ? Colors.blue
                                      : Colors.red)
                                  .withValues(alpha: _shadowOpacity.value),
                              blurRadius: 8.r,
                              spreadRadius: 2.r,
                            ),
                          ],
                        ),
                        child: Text(
                          'Points: $pointsCount',
                          style: TextStyle(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.bold,
                            color: _colorAnimation.value,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
          SizedBox(height: 10.h),
          buildPointButtons(
            viewModel: widget.viewModel,
            playerId: widget.playerId,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget buildPointButtons({
    required FencingMatchViewModel viewModel,
    required int playerId,
  }) {
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
            Text(
              "Point",
              style: TextStyle(
                fontSize: FontSize.s20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
