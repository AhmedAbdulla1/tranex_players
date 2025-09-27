
import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/models.dart';

/// Abstract class for managing exercises and related data.
///
/// This repository provides methods for fetching, adding, and deleting exercises,
/// as well as fetching device data.
abstract class ExerciseRepository {
  /// Fetches all categories and exercises from the database.
  ///
  /// Throws a [Failure] if the operation fails.
  ///
  /// Returns a [Future] that resolves to a [List] of [CategoryData]
  /// when the operation is complete.
  Future<Either<Failure, List<CategoryData>>> getExercises();
  /// Deletes an exercise from a category.
  ///
  /// [categoryId] is the ID of the category that the exercise belongs to.
  /// [exerciseId] is the ID of the exercise to delete.
  ///
  /// Throws a [Failure] if the operation fails.
  ///
  /// Returns a [Future] that resolves when the operation is complete.
  Future<void> deleteExercise(String categoryId, String exerciseId);

  /// Adds a new exercise to a category.
  ///
  /// [addNewExerciseRequest] is the request object containing the data
  /// for the new exercise.
  ///
  /// Throws a [Failure] if the operation fails.
  ///
  /// Returns a [Future] that resolves to an [int] representing the ID of
  /// the added exercise when the operation is complete.
  Future<Either<Failure, int >> addNewExercise(AddNewExerciseRequest addNewExerciseRequest);
  /// Fetches a list of all devices that the user has access to.
  ///
  /// Throws a [Failure] if the operation fails.
  ///
  /// Returns a [Future] that resolves to a [List] of [DeviceData] when the
  /// operation is complete.
  Future<Either<Failure, List<DeviceData>>> getDevices();
}
