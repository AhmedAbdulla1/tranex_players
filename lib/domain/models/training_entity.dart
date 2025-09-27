import 'dart:developer';

import 'package:tranex_users/domain/models/fencing_training_enitity.dart';
import 'package:tranex_users/domain/models/fitness_training_enttity.dart';

abstract class TrainingDetails {
  Map<String, dynamic> toJson();
}

class AllTrainingsEntity {
  final List<TrainingEntity> allTrainings;

  AllTrainingsEntity({required this.allTrainings});
}

class TrainingEntity {
  final int trainingId;
  final DateTime createdAt;
  final TrainingDetails trainingDetails;

  TrainingEntity({
    required this.trainingId,
    required this.createdAt,
    required this.trainingDetails,
  });

  factory TrainingEntity.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['training_details'] as Map<String, dynamic>;

    TrainingDetails details;
    log('detailsJson: $detailsJson');
    if (detailsJson.containsKey('CF')) {
      log('CF_data');
      details = FitnessTrainingDetails.fromJson(detailsJson);
    } else if (detailsJson.containsKey('TM')) {
      details = FencingTrainingDetails.fromJson(detailsJson);
    } else {
      throw Exception("Unknown training_details format: $detailsJson");
    }

    return TrainingEntity(
      trainingId: json['training_id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      trainingDetails: details,
    );
  }

  Map<String, dynamic> toJson() => {
        'training_id': trainingId,
        'created_at': createdAt.toIso8601String(),
        'training_details': trainingDetails.toJson(),
      };
}
