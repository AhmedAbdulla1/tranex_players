import 'package:json_annotation/json_annotation.dart';

part 'player_model.g.dart';

@JsonSerializable()
class PlayerModel {
  @JsonKey(name: 'player_id')
  final int playerId;

  final String name;

  @JsonKey(name: 'trainee_id')
  final String traineeId;

  @JsonKey(name: 'profile_picture')
  final String profilePicture;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'charge_time_ms')
  final int chargeTimeMs;

  @JsonKey(name: 'is_fencer')
  final bool isFencer;

  final String country;

  @JsonKey(name: 'weapon_type')
  final String? weaponType;

  @JsonKey(name: 'activation_date')
  final DateTime activationDate;

  final int? age;

  PlayerModel({
    required this.playerId,
    required this.name,
    required this.traineeId,
    required this.profilePicture,
    required this.createdAt,
    required this.chargeTimeMs,
    required this.isFencer,
    required this.country,
    this.weaponType,
    required this.activationDate,
    this.age,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerModelToJson(this);
}