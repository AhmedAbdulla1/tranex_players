import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tranex_users/domain/models/fencing_training_enitity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/training_entity.dart';
import 'package:tranex_users/presentation/all_trainings_screen/training_analysis.dart';

class TrainingListWidget extends StatefulWidget {
  final List<TrainingEntity> trainings;

  const TrainingListWidget({super.key, required this.trainings});

  @override
  State<TrainingListWidget> createState() => _TrainingListWidgetState();
}

class _TrainingListWidgetState extends State<TrainingListWidget> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.trainings.length,
      separatorBuilder: (_, __) => 10.verticalSpace,
      itemBuilder: (context, index) {
        final training = widget.trainings[index];
        final previousTraining = index + 1 < widget.trainings.length
            ? widget.trainings[index + 1]
            : null;
        final isExpanded = expandedIndex == index;

        return Card(
          color: Colors.grey,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  training.trainingDetails is FencingTrainingDetails
                      ? Icons.sports_gymnastics
                      : Icons.fitness_center,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  "Training #${training.trainingId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  "${training.createdAt.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : index;
                  });
                },
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TrainingAnalysisView(
                    training: training,
                    previousTraining: previousTraining,
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        );
      },
    );
  }
}
