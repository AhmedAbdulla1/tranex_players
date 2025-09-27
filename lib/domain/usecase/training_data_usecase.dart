import 'package:dartz/dartz.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/models/training_entity.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';

class TrainingUsecase {
  final TraineesRepository _repository = instance<TraineesRepository>();

  Future<Either<Failure, TraineeData>> checkTraineeExistence(
      String traineeId) async {
    return _repository.checkTraineeExistence(traineeId);
  }

  Future<Either<Failure, AllTrainingsEntity>> getTrainingData(
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

  Future<Either<Failure, void>> saveFencingTraining(
      SaveTrainingFencingRequest trainingData) async {
    return await _repository.saveFencingTraining(trainingData);
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

  AddTrainingDataInput(
      {required this.traineeId,
      required this.exerciseId,
      required this.numberOfSets,
      required this.eccForce,
      required this.conForce,
      required this.maxEccSpeed,
      required this.maxConSpeed,
      required this.avgConSpeed,
      required this.avgEccSpeed,
      required this.timeBySeconds,
      required this.weight});
}

class GetTrainingDataInput {
  String traineeId;
  int exerciseId;

  GetTrainingDataInput({required this.traineeId, required this.exerciseId});
}
