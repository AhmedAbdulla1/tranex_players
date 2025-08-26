import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/usecase/training_data_usecase.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view_model.dart';

abstract class TraineesRepository {
  Future<Either<Failure, TraineeData>> login(LoginRequest loginRequest);

  Either<Failure, TraineeData> getUser();

  Future<Either<Failure, void>> updateProfile(
      UpdateProfileRequest updateProfileRequest);

  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> logout();


  Future<Either<Failure, MatchesEntity>> getMatches(String traineeId);

  Future<Either<Failure, TrainingData>> getTrainingData(
      GetTrainingRequest getTrainingRequest);

  Future<Either<Failure, void>> addTrainingData(
      AddTrainingRequest addTrainingRequest);

  Future<Either<Failure, Data?>> getLastTrainingData(
      GetTrainingRequest getTrainingRequest);

  Future<Either<Failure, List<TraineeData>>> getTrainees();
}
