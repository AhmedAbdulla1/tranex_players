import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/analysis_screen/analysis_match.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/matches_screen/view_model.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({super.key, required this.traineeData});

  static const routeName = '/matches';
  final TraineeData traineeData;

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  final MatchesViewModel _viewModel = MatchesViewModel();

  late Uint8List exerciseImage;
  late String category;

  bind() {
    _viewModel.traineeData = widget.traineeData;
    _viewModel.start();
  }

  @override
  void initState() {
    bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Matches",
        ),
      ),
      body: StreamBuilder<StateFlow>(
        stream: _viewModel.outputState,
        builder: (context, snapshot) =>
            snapshot.data?.getScreenWidget(
              context,
              _getContent(),
            ) ??
            _getContent(),
      ),
    );
  }

  Widget _getContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<MatchesEntity>(
              stream: _viewModel.outFilteredData,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: snapshot.data?.matches.length ?? 0,
                  itemBuilder: (context, index) {
                    if (snapshot.data?.matches.length != null &&
                        snapshot.data!.matches.isNotEmpty) {
                      MatchEntity match = snapshot.data!.matches[index];
                      return MatchCard(
                        match: match,
                        traineeData: widget.traineeData,
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No Matches Available',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// MatchCard Widget
class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final TraineeData traineeData;

  const MatchCard({
    super.key,
    required this.match,
    required this.traineeData,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape ||
            MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, FencingAnalysisView.routeName,
              arguments: [
                match,
                traineeData,
              ]);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p12),
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final opponent = match.opponent;
    final playerPoints = match.opponentNum == 1
        ? match.player2MatchData.pointData.length
        : match.player1MatchData.pointData.length;
    final opponentPoints = match.opponentNum == 1
        ? match.player1MatchData.pointData.length
        : match.player2MatchData.pointData.length;
    final isWinner = playerPoints > opponentPoints;
    final isTie = playerPoints == opponentPoints;
    final resultText = isTie
        ? "Tie"
        : isWinner
            ? "Win"
            : "Loss";
    final resultIcon = isTie
        ? "🤝"
        : isWinner
            ? "🏆"
            : "😔";
    final durationMin = (match.durationMs / 60000).floor();
    final durationSec = ((match.durationMs % 60000) / 1000).round();

    return Row(
      children: [
        CircleAvatar(
          radius: AppSize.s28,
          backgroundColor: Colors.red,
          foregroundImage:
              opponent.photo.isNotEmpty ? NetworkImage(opponent.photo) : null,
          child: opponent.photo.isEmpty
              ? Text(
                  opponent.traineeName.isNotEmpty
                      ? opponent.traineeName[0].toUpperCase()
                      : 'O',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        SizedBox(width: AppSize.s12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opponent.traineeName,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: AppSize.s4.h),
              Text(
                "Duration: $durationMin:${durationSec.toString().padLeft(2, '0')} min",
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.bold,
                    color: isTie
                        ? Colors.grey
                        : isWinner
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                SizedBox(width: AppSize.s4.w),
                Text(
                  resultIcon,
                  style: TextStyle(fontSize: FontSize.s16),
                ),
              ],
            ),
            SizedBox(height: AppSize.s4.h),
            Text(
              "$playerPoints - $opponentPoints",
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final opponent = match.opponent;
    final playerPoints = match.opponentNum == 1
        ? match.player2MatchData.pointData.length
        : match.player1MatchData.pointData.length;
    final opponentPoints = match.opponentNum == 1
        ? match.player1MatchData.pointData.length
        : match.player2MatchData.pointData.length;
    final isWinner = playerPoints > opponentPoints;
    final isTie = playerPoints == opponentPoints;
    final resultText = isTie
        ? "Tie"
        : isWinner
            ? "Win"
            : "Loss";
    final resultIcon = isTie
        ? "🤝"
        : isWinner
            ? "🏆"
            : "😔";
    final durationMin = (match.durationMs / 60000).floor();
    final durationSec = ((match.durationMs % 60000) / 1000).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Player (Left)
        Expanded(
          flex: 2,
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSize.s32,
                backgroundColor: Colors.blue,
                foregroundImage: traineeData.photo.isNotEmpty
                    ? NetworkImage(traineeData.photo)
                    : null,
                child: traineeData.photo.isEmpty
                    ? Text(
                        traineeData.traineeName.isNotEmpty
                            ? traineeData.traineeName[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSize.s18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: Text(
                  traineeData.traineeName,
                  style: TextStyle(
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Match Result and Duration (Center)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppPadding.p8,
              horizontal: AppPadding.p12,
            ),
            decoration: BoxDecoration(
              color: isTie
                  ? Colors.grey[200]
                  : isWinner
                      ? Colors.green[200]
                      : Colors.red[200],
              borderRadius: BorderRadius.circular(AppSize.s8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resultText,
                      style: TextStyle(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.bold,
                        color: isTie
                            ? Colors.grey
                            : isWinner
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    SizedBox(width: AppSize.s8.w),
                    Text(
                      resultIcon,
                      style: TextStyle(fontSize: FontSize.s20),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.s4.h),
                Text(
                  "$playerPoints - $opponentPoints",
                  style: TextStyle(
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: AppSize.s4.h),
                Text(
                  "Duration: $durationMin:${durationSec.toString().padLeft(2, '0')} min",
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Opponent (Right)
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  opponent.traineeName,
                  style: TextStyle(
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSize.s12),
              CircleAvatar(
                radius: AppSize.s32,
                backgroundColor: Colors.red,
                foregroundImage: opponent.photo.isNotEmpty
                    ? NetworkImage(opponent.photo)
                    : null,
                child: opponent.photo.isEmpty
                    ? Text(
                        opponent.traineeName.isNotEmpty
                            ? opponent.traineeName[0].toUpperCase()
                            : 'O',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSize.s18,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
