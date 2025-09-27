import 'package:json_annotation/json_annotation.dart';

part 'training_seesion_model.g.dart';

@JsonSerializable()
class TrainingSeesionModel {
  @JsonKey(name: 'session_id')
  final int sessionId;

  @JsonKey(name: 'player_id')
  final int playerId;

  @JsonKey(name: 'coach_id')
  final int coachId;

  @JsonKey(name: 'exercise_id')
  final int exerciseId;

  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @JsonKey(name: 'duration_ms')
  final int durationMs;

  TrainingSeesionModel(
      {required this.sessionId,
      required this.playerId,
      required this.coachId,
      required this.exerciseId,
      required this.startTime,
      required this.durationMs});

  factory TrainingSeesionModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingSeesionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSeesionModelToJson(this);
}
