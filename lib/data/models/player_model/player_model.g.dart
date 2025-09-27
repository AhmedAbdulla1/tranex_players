// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => PlayerModel(
      playerId: (json['player_id'] as num).toInt(),
      name: json['name'] as String,
      traineeId: json['trainee_id'] as String,
      profilePicture: json['profile_picture'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      chargeTimeMs: (json['charge_time_ms'] as num).toInt(),
      isFencer: json['is_fencer'] as bool,
      country: json['country'] as String,
      weaponType: json['weapon_type'] as String?,
      activationDate: DateTime.parse(json['activation_date'] as String),
      age: (json['age'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PlayerModelToJson(PlayerModel instance) =>
    <String, dynamic>{
      'player_id': instance.playerId,
      'name': instance.name,
      'trainee_id': instance.traineeId,
      'profile_picture': instance.profilePicture,
      'created_at': instance.createdAt.toIso8601String(),
      'charge_time_ms': instance.chargeTimeMs,
      'is_fencer': instance.isFencer,
      'country': instance.country,
      'weapon_type': instance.weaponType,
      'activation_date': instance.activationDate.toIso8601String(),
      'age': instance.age,
    };
