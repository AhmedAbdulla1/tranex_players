import 'package:json_annotation/json_annotation.dart';

part 'coach_model.g.dart';

@JsonSerializable()
class CoachModel {
  @JsonKey(name: 'coach_id')
  final int coachId;

  @JsonKey(name: 'auth_id')
  final int authId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  CoachModel({
    required this.coachId,
    required this.authId,
    required this.createdAt,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) =>
      _$CoachModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoachModelToJson(this);
}
