
import 'package:json_annotation/json_annotation.dart';

part 'accessories_model.g.dart';

@JsonSerializable()
class AccessoriesModel {
  @JsonKey(name: 'accessory_id')
  final int accessoryId;

  @JsonKey(name: 'device_id')
  final int deviceId;

  @JsonKey(name: 'accessory_name')
  final String accessoryName;

  final int min, max, interval, weight;

  final double radius;

  AccessoriesModel(
      {required this.accessoryId,
      required this.deviceId,
      required this.accessoryName,
      required this.min,
      required this.max,
      required this.interval,
      required this.weight,
      required this.radius});

  factory AccessoriesModel.fromJson(Map<String, dynamic> json) =>
      _$AccessoriesModelFromJson(json);
  Map<String, dynamic> toJson() => _$AccessoriesModelToJson(this);
}
