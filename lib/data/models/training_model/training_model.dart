import 'package:json_annotation/json_annotation.dart';

part 'training_model.g.dart';

@JsonSerializable()
class TrainingModel {
  final int id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'coach_id')
  final int coachId;
  @JsonKey(name: 'player_id')
  final int playerId;
  @JsonKey(name: 'exercise_id')
  final int exerciseId;
  @JsonKey(name: 'training_details')
  final TrainingDetails trainingDetails;

  TrainingModel({
    required this.id,
    required this.createdAt,
    required this.coachId,
    required this.playerId,
    required this.exerciseId,
    required this.trainingDetails,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingModelToJson(this);
}

@JsonSerializable()
class TrainingDetails {
  final int w;
  final List<double> cF;
  final List<double> eF;
  final double aCS;
  final double aES;
  final double mCS;
  final double mES;

  TrainingDetails(
      {required this.w,
      required this.cF,
      required this.eF,
      required this.aCS,
      required this.aES,
      required this.mCS,
      required this.mES});

  factory TrainingDetails.fromJson(Map<String, dynamic> json) =>
      _$TrainingDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingDetailsToJson(this);
}
