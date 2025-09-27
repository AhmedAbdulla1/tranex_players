// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessories_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessoriesModel _$AccessoriesModelFromJson(Map<String, dynamic> json) =>
    AccessoriesModel(
      accessoryId: (json['accessory_id'] as num).toInt(),
      deviceId: (json['device_id'] as num).toInt(),
      accessoryName: json['accessory_name'] as String,
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      interval: (json['interval'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      radius: (json['radius'] as num).toDouble(),
    );

Map<String, dynamic> _$AccessoriesModelToJson(AccessoriesModel instance) =>
    <String, dynamic>{
      'accessory_id': instance.accessoryId,
      'device_id': instance.deviceId,
      'accessory_name': instance.accessoryName,
      'min': instance.min,
      'max': instance.max,
      'interval': instance.interval,
      'weight': instance.weight,
      'radius': instance.radius,
    };
