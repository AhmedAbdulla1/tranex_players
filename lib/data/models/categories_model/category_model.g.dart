// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      categoryId: (json['category_id'] as num).toInt(),
      coachId: (json['coach_id'] as num).toInt(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'coach_id': instance.coachId,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };
