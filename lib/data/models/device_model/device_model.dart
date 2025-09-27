import 'package:json_annotation/json_annotation.dart';

part 'device_model.g.dart';

@JsonSerializable()
class DeviceModel {
  @JsonKey(name: 'device_id')
  final int id;
  final String name;

  DeviceModel({required this.id, required this.name,});

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);
}
