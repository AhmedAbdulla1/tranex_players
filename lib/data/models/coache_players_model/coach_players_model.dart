import 'package:json_annotation/json_annotation.dart';

part 'coach_players_model.g.dart';

@JsonSerializable()
class CoachPlayersModel {
  @JsonKey(name: 'coach_id')
  final int coachId;

  @JsonKey(name: 'player_id')
  final int playerId;

  @JsonKey(name: 'assigned_at')
  final DateTime assignedAt;

  CoachPlayersModel({
    required this.coachId,
    required this.playerId,
    required this.assignedAt,
  });

  factory CoachPlayersModel.fromJson(Map<String, dynamic> json) =>
      _$CoachPlayersModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoachPlayersModelToJson(this);
}
