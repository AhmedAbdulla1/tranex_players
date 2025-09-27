import 'package:json_annotation/json_annotation.dart';

part 'training_data_model.g.dart';

@JsonSerializable()
class TrainingDataModel {
  @JsonKey(name: 'data_id')
  final int dataId;

  @JsonKey(name: 'session_id')
  final int sessionId;

  @JsonKey(name: 'time_in_ms')
  final int timeInMs;

  final double speed;

  final int direction;

  TrainingDataModel(
      {required this.dataId,
      required this.sessionId,
      required this.timeInMs,
      required this.speed,
      required this.direction});

  factory TrainingDataModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingDataModelToJson(this);
}
