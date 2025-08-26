
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';

class LoginRequest {
  String userId;

  LoginRequest({
    required this.userId,
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
  int traineeId;
  bool weakly ;

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

  AddTrainingRequest({
    required this.exerciseId,
    required this.traineeId,
    required this.data
  });
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
  TrainingDataRequest({
    required this.timeBySeconds,
    required this.numOfSets,
    required this.avgConSpeed,
    required this.avgEccSpeed,
    required this.maxEccSpeed,
    required this.maxConSpeed,
    required this.eccForce,
    required this.conForce,
    required this.weight
  });
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

// class MatchRequest {
//   final int player1Id;
//   final int player2Id;
//   final int? coachId;
//   final int durationMs;
//   final int? winnerId;
//   final int player1Points;
//   final int player2Points;
//   final List<MatchDataPoint> matchData;
//
//   MatchRequest({
//     required this.player1Id,
//     required this.player2Id,
//     this.coachId,
//     required this.durationMs,
//     this.winnerId,
//     required this.player1Points,
//     required this.player2Points,
//     required this.matchData,
//   });
// }

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
  final int player1Id;
  final int player2Id;
  final int durationMs;
  final List<MatchDataEntity> player1MatchData;
  final List<PointDataEntity> player1PointRecords;
  final List<MatchDataEntity> player2MatchData;
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
    'time_ms': timeInMs,
    'speed': speed,
    'direction': direction,
  };
}

