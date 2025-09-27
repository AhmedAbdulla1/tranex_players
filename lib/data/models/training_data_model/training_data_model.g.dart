// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingDataModel _$TrainingDataModelFromJson(Map<String, dynamic> json) =>
    TrainingDataModel(
      dataId: (json['data_id'] as num).toInt(),
      sessionId: (json['session_id'] as num).toInt(),
      timeInMs: (json['time_in_ms'] as num).toInt(),
      speed: (json['speed'] as num).toDouble(),
      direction: (json['direction'] as num).toInt(),
    );

Map<String, dynamic> _$TrainingDataModelToJson(TrainingDataModel instance) =>
    <String, dynamic>{
      'data_id': instance.dataId,
      'session_id': instance.sessionId,
      'time_in_ms': instance.timeInMs,
      'speed': instance.speed,
      'direction': instance.direction,
    };
