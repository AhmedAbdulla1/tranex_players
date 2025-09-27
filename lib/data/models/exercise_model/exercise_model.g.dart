// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      exerciseId: (json['exercise_id'] as num).toInt(),
      coachId: (json['coach_id'] as num).toInt(),
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      deviceId: (json['device_id'] as num).toInt(),
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      categoryId: (json['category_id'] as num).toInt(),
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'coach_id': instance.coachId,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'device_id': instance.deviceId,
      'category': instance.category,
      'created_at': instance.createdAt.toIso8601String(),
      'category_id': instance.categoryId,
    };
