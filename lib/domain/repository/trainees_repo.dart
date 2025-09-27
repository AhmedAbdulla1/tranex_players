import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view_model.dart';

abstract class TraineesRepository {
  Future<Either<Failure,MatchesEntity>> getMatches( String traineeId);
  Future<Either<Failure, TrainingData>> getTrainingData(GetTrainingRequest getTrainingRequest);
  Future<Either<Failure, void>> addTrainingData(AddTrainingRequest addTrainingRequest);
  Future<Either<Failure,Data?>> getLastTrainingData(GetTrainingRequest getTrainingRequest);
  Future<Either<Failure, TraineeData>> checkTraineeExistence(String traineeId);
  Future<Either<Failure, List<TraineeData>>> getTrainees();

  Future<Either<Failure, void>> saveFencingTraining(SaveTrainingFencingRequest trainingData);


}