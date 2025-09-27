import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/models/training_entity.dart';

abstract class TraineesRepository {
  Future<Either<Failure, MatchesEntity>> getMatches(String traineeId);
  Future<Either<Failure, AllTrainingsEntity>> getTrainingData(
      GetTrainingRequest getTrainingRequest);
  Future<Either<Failure, void>> addTrainingData(
      AddTrainingRequest addTrainingRequest);
  Future<Either<Failure, Data?>> getLastTrainingData(
      GetTrainingRequest getTrainingRequest);
  Future<Either<Failure, TraineeData>> checkTraineeExistence(String traineeId);
  Future<Either<Failure, List<TraineeData>>> getTrainees();

  Future<Either<Failure, void>> saveFencingTraining(
      SaveTrainingFencingRequest trainingData);
}
