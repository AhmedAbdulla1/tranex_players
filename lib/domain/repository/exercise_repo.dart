import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, List<CategoryData>>> getExercises();
  Future<void> deleteExercise(String categoryId, String exerciseId);

  Future<Either<Failure, int >> addNewExercise(AddNewExerciseRequest addNewExerciseRequest);
  Future<Either<Failure, List<DeviceData>>> getDevices();
}