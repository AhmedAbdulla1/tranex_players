import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';
@JsonSerializable()
class CategoryModel {
  @JsonKey(name: 'category_id')
  final int categoryId;

  @JsonKey(name: 'coach_id')
  final int coachId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;


  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  CategoryModel({required this.categoryId, required this.coachId, required this.name, required this.createdAt});

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
