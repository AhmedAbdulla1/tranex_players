import 'package:firesport_users/domain/models/models.dart';

class MatchesEntity {
  final List<MatchEntity> matches;

  MatchesEntity({
    required this.matches,
  });

  factory MatchesEntity.fromJson(List<dynamic> json) {
    return MatchesEntity(
      matches: (json)
          .map((match) => MatchEntity.fromJson(match as Map<String, dynamic>))
          .toList().reversed.toList(),
    );
  }
}

class MatchEntity {
  final int id;
  final TraineeData opponent;
  final int opponentNum;
  final int durationMs;
  final MatchDetailsEntity player1MatchData;
  final MatchDetailsEntity player2MatchData;

  MatchEntity({
    required this.id,
    required this.opponent,
    required this.opponentNum,
    required this.durationMs,
    required this.player1MatchData,
    required this.player2MatchData,
  });

  factory MatchEntity.fromJson(Map<String, dynamic> json) {
    return MatchEntity(
      id: json['match_id'] as int,
      opponent: TraineeData.fromJson(json['opponent']),
      opponentNum: json['opponent']['playerNum'] as int,
      durationMs: json['duration_ms'] as int,
      player1MatchData: MatchDetailsEntity.fromJson(json['player1_match_data']),
      player2MatchData: MatchDetailsEntity.fromJson(json['player2_match_data']),
    );
  }
}

class MatchDetailsEntity {
  List<MatchDataEntity> matchData;
  List<PointDataEntity> pointData;

  MatchDetailsEntity({
    required this.matchData,
    required this.pointData,
  });

  factory MatchDetailsEntity.fromJson(Map<String, dynamic> json) {
    return MatchDetailsEntity(
      matchData: (json['match_data'] as List<dynamic>)
          .map((data) => MatchDataEntity.fromJson(data))
          .toList(),
      pointData: (json['point_data'] as List<dynamic>)
          .map((data) => PointDataEntity.fromJson(data))
          .toList(),
    );
  }
}

class MatchDataEntity {
  final double speed;
  final int direction;
  final int timeInMs;

  MatchDataEntity({
    required this.speed,
    required this.direction,
    required this.timeInMs,
  });

  factory MatchDataEntity.fromJson(Map<String, dynamic> json) {
    return MatchDataEntity(
      speed: (json['S'] as num).toDouble(),
      direction: json['D'] as int,
      timeInMs: json['T'] as int,
    );
  }
    factory MatchDataEntity.fromBluetooth(Map<String, dynamic> json, int timeInMs) {
    int direction = json['direction'] as int;
    return MatchDataEntity(
      speed: (json['speed'] as num).toDouble(),
      direction: direction,
      timeInMs: timeInMs,
    );
  }
}

class PointDataEntity {
  final int timeInMs;
  final double speed;

  PointDataEntity({
    required this.speed,
    required this.timeInMs,
  });

  factory PointDataEntity.fromJson(Map<String, dynamic> json) {
    return PointDataEntity(
      speed: (json['S'] as num).toDouble(),
      timeInMs: json['T'] as int,
    );
  }
}
