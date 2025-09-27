// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingModel _$TrainingModelFromJson(Map<String, dynamic> json) =>
    TrainingModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      coachId: (json['coach_id'] as num).toInt(),
      playerId: (json['player_id'] as num).toInt(),
      exerciseId: (json['exercise_id'] as num).toInt(),
      trainingDetails: TrainingDetails.fromJson(
          json['training_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrainingModelToJson(TrainingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'coach_id': instance.coachId,
      'player_id': instance.playerId,
      'exercise_id': instance.exerciseId,
      'training_details': instance.trainingDetails,
    };

TrainingDetails _$TrainingDetailsFromJson(Map<String, dynamic> json) =>
    TrainingDetails(
      w: (json['w'] as num).toInt(),
      cF: (json['cF'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      eF: (json['eF'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      aCS: (json['aCS'] as num).toDouble(),
      aES: (json['aES'] as num).toDouble(),
      mCS: (json['mCS'] as num).toDouble(),
      mES: (json['mES'] as num).toDouble(),
    );

Map<String, dynamic> _$TrainingDetailsToJson(TrainingDetails instance) =>
    <String, dynamic>{
      'w': instance.w,
      'cF': instance.cF,
      'eF': instance.eF,
      'aCS': instance.aCS,
      'aES': instance.aES,
      'mCS': instance.mCS,
      'mES': instance.mES,
    };
