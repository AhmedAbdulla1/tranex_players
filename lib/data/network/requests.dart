import 'package:tranex_users/domain/models/trainee_model.dart';

class LoginRequest {
  String email;
  String password;

  LoginRequest({
    required this.email,
    required this.password,
  });
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;

  // final String bodyWeight;
  // final String height;
  // final String age;
  // final String gender;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    // required this.bodyWeight,
    // required this.height,
    // required this.age,
    // required this.gender,
  });
}

class RestPasswordRequest {
  String otp;
  String password;

  RestPasswordRequest({
    required this.otp,
    required this.password,
  });
}

class UpdateProfileRequest {
  String? name;
  String? profilePicture;

  UpdateProfileRequest({this.name, this.profilePicture});
}

class AddNewTraineeRequest {
  String teamName;
  String teamId;
  String traineeName;

  AddNewTraineeRequest({
    required this.teamName,
    required this.traineeName,
    required this.teamId,
  });
}

class AddNewExerciseRequest {
  String categoryName;
  int categoryId;
  String exerciseName;
  String image;

  int deviceId;

  AddNewExerciseRequest({
    required this.exerciseName,
    required this.categoryName,
    required this.image,
    required this.categoryId,
    required this.deviceId,
  });
}

class GetTrainingRequest {
  int exerciseId;
  String traineeId;
  bool weakly;

  GetTrainingRequest({
    required this.exerciseId,
    required this.traineeId,
    this.weakly = true,
  });
}

class AddTrainingRequest {
  int exerciseId;
  String traineeId;
  TrainingDataRequest data;

  AddTrainingRequest(
      {required this.exerciseId, required this.traineeId, required this.data});
}

class TrainingDataRequest {
  int numOfSets;
  List<double> eccForce;
  List<double> conForce;
  double avgConSpeed;
  double avgEccSpeed;
  double maxEccSpeed;
  double maxConSpeed;
  int timeBySeconds;
  double weight;

  TrainingDataRequest(
      {required this.timeBySeconds,
      required this.numOfSets,
      required this.avgConSpeed,
      required this.avgEccSpeed,
      required this.maxEccSpeed,
      required this.maxConSpeed,
      required this.eccForce,
      required this.conForce,
      required this.weight});
}

class PlayerTrainingRequest {
  final int playerId;
  final int coachId;
  final int exerciseId;
  final int durationMs;
  final List<TrainingDataPoint> trainingData;

  PlayerTrainingRequest({
    required this.playerId,
    required this.coachId,
    required this.exerciseId,
    required this.durationMs,
    required this.trainingData,
  });
}

class SaveTrainingFencingRequest {
  final int exerciseId;
  final String traineeId;
  final TrainingFencingSession trainingData;

  SaveTrainingFencingRequest(
      {required this.exerciseId,
      required this.traineeId,
      required this.trainingData});
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
}

class MatchDataPoint {
  final int playerId;
  final int timeInMs;
  final double speed;
  final int direction;

  MatchDataPoint({
    required this.playerId,
    required this.timeInMs,
    required this.speed,
    required this.direction,
  });
}

class MatchRequest {
  final String player1Id;
  final String player2Id;
  final int durationMs;
  final List<PlayerMovementData> player1MatchData;
  final List<PointDataEntity> player1PointRecords;
  final List<PlayerMovementData> player2MatchData;
  final List<PointDataEntity> player2PointRecords;

  MatchRequest({
    required this.player1Id,
    required this.player2Id,
    required this.durationMs,
    required this.player1MatchData,
    required this.player1PointRecords,
    required this.player2MatchData,
    required this.player2PointRecords,
  });
}

class MatchDataRequest {
  final int timeInMs;
  final double speed;
  final double direction;

  MatchDataRequest({
    required this.timeInMs,
    required this.speed,
    required this.direction,
  });

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

  factory PlayerMovementData.fromBluetooth(
      Map<String, dynamic> json, int timeInMs) {
    int direction = json['direction'] as int;
    return PlayerMovementData(
      speed: (json['speed'] as num).toDouble(),
      direction: direction,
      timeInMs: timeInMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'S': speed,
        'D': direction,
        'T': timeInMs,
      };
}

class TrainingFencingSession {
  final String playerId;
  final int? targetMinutes;
  final int? targetPoints;
  final int achievedPoints;
  final int durationMs;
  final String endedBy;
  final TraineeData? traineeData;
  final List<PlayerMovementData> movements;
  final List<PointDataEntity> pointRecords;

  TrainingFencingSession({
    required this.playerId,
    required this.targetMinutes,
    required this.targetPoints,
    required this.achievedPoints,
    required this.durationMs,
    required this.endedBy,
    required this.traineeData,
    required this.movements,
    required this.pointRecords,
  });

  Map<String, dynamic> toJson() => {
        'PID': playerId,
        'TM': targetMinutes,
        'TP': targetPoints,
        'AP': achievedPoints,
        'DM': durationMs,
        'EB': endedBy,
        'TD': traineeData?.toJson(),
        'M': movements.map((m) => m.toJson()).toList(),
        'PR': pointRecords.map((p) => p.toJson()).toList(),
      };
}
