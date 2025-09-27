// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachModel _$CoachModelFromJson(Map<String, dynamic> json) => CoachModel(
      coachId: (json['coach_id'] as num).toInt(),
      authId: (json['auth_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CoachModelToJson(CoachModel instance) =>
    <String, dynamic>{
      'coach_id': instance.coachId,
      'auth_id': instance.authId,
      'created_at': instance.createdAt.toIso8601String(),
    };
