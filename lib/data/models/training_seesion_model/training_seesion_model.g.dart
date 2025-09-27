// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_seesion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSeesionModel _$TrainingSeesionModelFromJson(
        Map<String, dynamic> json) =>
    TrainingSeesionModel(
      sessionId: (json['session_id'] as num).toInt(),
      playerId: (json['player_id'] as num).toInt(),
      coachId: (json['coach_id'] as num).toInt(),
      exerciseId: (json['exercise_id'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      durationMs: (json['duration_ms'] as num).toInt(),
    );

Map<String, dynamic> _$TrainingSeesionModelToJson(
        TrainingSeesionModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'player_id': instance.playerId,
      'coach_id': instance.coachId,
      'exercise_id': instance.exerciseId,
      'start_time': instance.startTime.toIso8601String(),
      'duration_ms': instance.durationMs,
    };
