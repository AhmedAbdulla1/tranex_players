import 'package:tranex_users/domain/models/training_entity.dart'
    show TrainingDetails;

class FencingTrainingDetails extends TrainingDetails {
  final int? targetMinutes;
  final int? targetPoints;
  final int achievedPoints;
  final int durationMs;
  final String endedBy;
  final List<PlayerMovementData> movements;
  final List<PointDataEntity> pointRecords;

  FencingTrainingDetails({
    required this.targetMinutes,
    required this.targetPoints,
    required this.achievedPoints,
    required this.durationMs,
    required this.endedBy,
    required this.movements,
    required this.pointRecords,
  });

  factory FencingTrainingDetails.fromJson(Map<String, dynamic> json) {
    return FencingTrainingDetails(
      targetMinutes: json['TM'] as int?,
      targetPoints: json['TP'] as int?,
      achievedPoints: json['AP'] as int,
      durationMs: json['DM'] as int,
      endedBy: json['EB'] as String,
      movements: (json['M'] as List<dynamic>)
          .map((m) => PlayerMovementData.fromJson(m))
          .toList(),
      pointRecords: (json['PR'] as List<dynamic>)
          .map((p) => PointDataEntity.fromJson(p))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'TM': targetMinutes,
        'TP': targetPoints,
        'AP': achievedPoints,
        'DM': durationMs,
        'EB': endedBy,
        'M': movements.map((m) => m.toJson()).toList(),
        'PR': pointRecords.map((p) => p.toJson()).toList(),
      };
}

class PlayerMovementData {
  final double speed;
  final int direction;
  final int timeInMs;

  PlayerMovementData({
    required this.speed,
    required this.direction,
    required this.timeInMs,
  });

  factory PlayerMovementData.fromJson(Map<String, dynamic> json) {
    return PlayerMovementData(
      speed: (json['S'] as num).toDouble(),
      direction: json['D'] as int,
      timeInMs: json['T'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'S': speed,
        'D': direction,
        'T': timeInMs,
      };
}

class TrainingDataPoint {
  final int timeInMs;
  final double speed;
  final int direction;

  TrainingDataPoint({
    required this.timeInMs,
    required this.speed,
    required this.direction,
  });

  factory TrainingDataPoint.fromJson(Map<String, dynamic> json) {
    return TrainingDataPoint(
      timeInMs: json['T'] as int,
      speed: (json['S'] as num).toDouble(),
      direction: json['D'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'T': timeInMs,
        'S': speed,
        'D': direction,
      };
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

  Map<String, dynamic> toJson() => {
        'S': speed,
        'T': timeInMs,
      };
}
