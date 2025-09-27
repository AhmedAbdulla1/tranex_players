
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/repository/exercise_repo.dart';


class AddNewExerciseUseCase {
  final ExerciseRepository repository;

  const AddNewExerciseUseCase({required this.repository});

  Future<Either<Failure, int>> addNewExercise(
      AddNewExerciseRequest addNewExerciseRequest) {
    return repository.addNewExercise(addNewExerciseRequest);
  }

  Future<Either<Failure ,List<DeviceData>>> getDevices() {
    return repository.getDevices();
  }
}
