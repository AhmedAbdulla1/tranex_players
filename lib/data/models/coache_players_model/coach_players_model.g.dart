// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_players_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachPlayersModel _$CoachPlayersModelFromJson(Map<String, dynamic> json) =>
    CoachPlayersModel(
      coachId: (json['coach_id'] as num).toInt(),
      playerId: (json['player_id'] as num).toInt(),
      assignedAt: DateTime.parse(json['assigned_at'] as String),
    );

Map<String, dynamic> _$CoachPlayersModelToJson(CoachPlayersModel instance) =>
    <String, dynamic>{
      'coach_id': instance.coachId,
      'player_id': instance.playerId,
      'assigned_at': instance.assignedAt.toIso8601String(),
    };
