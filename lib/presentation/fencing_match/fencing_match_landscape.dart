import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/control_panel.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/live_chart.dart';
import 'package:firesport_users/presentation/fencing_match/widgets/nfc_statuse_widget.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

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
                      matchStatus: status)),
              Expanded(child: _buildPlayerSide(1)),
              Expanded(child: _buildPlayerSide(2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSide(int playerId) {
    switch (status) {
      case MatchStatus.waitingNFC1:
        return const NfCWidget(iconPath: JsonAssets.enterCard);

      case MatchStatus.waitingNFC2:
        if (playerId == 1) {
          return PlayerSection(playerId: 1, viewModel: viewModel);
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

class PlayerHeader extends StatelessWidget {
  final String playerName;
  final String? playerImage;
  final int playerId;

  const PlayerHeader({
    super.key,
    required this.playerId,
    required this.playerName,
    this.playerImage,
  });

  @override
  Widget build(BuildContext context) {
    Color color = playerId == 1 ? Colors.blue : Colors.red;
    return Container(
      padding: EdgeInsets.all(6.h),
      decoration: BoxDecoration(
        color: playerId == 1 ? color.withOpacity(0.3) : color.withOpacity(0.3),
        border: Border.all(color: ColorManager.simiBlue),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            playerName.isNotEmpty
                ? playerName.substring(0, 1).toUpperCase() +
                    playerName.substring(1)
                : 'Unknown',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          CircleAvatar(
            radius: 25.r,
            backgroundColor: color,
            child: CircleAvatar(
              radius: 24.r,
              foregroundImage: playerImage != null && playerImage!.isNotEmpty
                  ? NetworkImage(playerImage!)
                  : const AssetImage(ImageAssets.personal) as ImageProvider,
            ),
          ),
        ],
      ),
    );
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
  _PlayerSectionState createState() => _PlayerSectionState();
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
      padding: EdgeInsets.all(10.h),
      color: widget.playerId == 1
          ? Colors.blue.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
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
                        playerName: snapshot.data!.traineeName,
                        playerImage: snapshot.data!.photo,
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
                                  .withOpacity(_shadowOpacity.value),
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
    required FencingMatchViewModel viewModel, // Assuming your view model type
    required int playerId,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Plus Button
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
            Text("Point",style:  TextStyle(
              fontSize: FontSize.s20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),),
            // Minus Button
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
