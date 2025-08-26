import 'package:firesport_users/app/di.dart';
import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/exercise_repo.dart';

class ExerciseUsecase {
  final ExerciseRepository repository;

  const ExerciseUsecase({required this.repository});

  Future<Either<Failure, List<CategoryData>>> getExercises() {
    return repository.getExercises();
  }
  Future<void> deleteExercise(String categoryId, String exerciseId) {
    return repository.deleteExercise(categoryId, exerciseId);
  }
}
