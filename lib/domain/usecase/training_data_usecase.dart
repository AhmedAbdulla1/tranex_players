import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/domain/repository/trainees_repo.dart';

class TrainingUsecase {
  final TraineesRepository _repository = instance<TraineesRepository>();


  Future<Either<Failure, TrainingData>> getTrainingData(
      GetTrainingRequest getTrainingRequest) {
    return _repository.getTrainingData(getTrainingRequest);
  }

  Future<Either<Failure, Data?>> getLastTrainingData(
      GetTrainingDataInput getTrainingDataInput) {
    return _repository.getLastTrainingData(GetTrainingRequest(
        traineeId: getTrainingDataInput.traineeId,
        exerciseId: getTrainingDataInput.exerciseId));
  }

  Future<Either<Failure, void>> addTrainingData(
      AddTrainingDataInput addTrainingDataInput) {
    return _repository.addTrainingData(
      AddTrainingRequest(
        exerciseId: addTrainingDataInput.exerciseId,
        traineeId: addTrainingDataInput.traineeId,
        data: TrainingDataRequest(
          timeBySeconds: addTrainingDataInput.timeBySeconds,
          numOfSets: addTrainingDataInput.numberOfSets,
          eccForce: addTrainingDataInput.eccForce,
          conForce: addTrainingDataInput.conForce,
          weight: addTrainingDataInput.weight,
          maxConSpeed: addTrainingDataInput.maxConSpeed,
          maxEccSpeed: addTrainingDataInput.maxEccSpeed,
          avgConSpeed: addTrainingDataInput.avgConSpeed,
          avgEccSpeed: addTrainingDataInput.avgEccSpeed,
        ),
      ),
    );
  }
}

class AddTrainingDataInput {
  String traineeId;
  int exerciseId;
  int numberOfSets;
  List<double> eccForce;
  List<double> conForce;
  int timeBySeconds;
  double weight;
  double maxConSpeed;
  double maxEccSpeed;
  double avgConSpeed;
  double avgEccSpeed;

  AddTrainingDataInput({required this.traineeId,
    required this.exerciseId,
    required this.numberOfSets,
    required this.eccForce,
    required this.conForce,
    required this.maxEccSpeed
    , required this.maxConSpeed,
    required this.avgConSpeed,
    required this.avgEccSpeed,
    required this.timeBySeconds,
    required this.weight});
}

class GetTrainingDataInput {
  int traineeId;
  int exerciseId;

  GetTrainingDataInput({required this.traineeId, required this.exerciseId});
}
