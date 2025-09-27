import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  @JsonKey(name: 'exercise_id')
  final int exerciseId;

  @JsonKey(name: 'coach_id')
  final int coachId;

  final String name;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'device_id')
  final int deviceId;

  final String category;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'category_id')
  final int categoryId;

  ExerciseModel({
    required this.exerciseId,
    required this.coachId,
    required this.name,
    required this.imageUrl,
    required this.deviceId,
    required this.category,
    required this.createdAt,
    required this.categoryId,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);
}