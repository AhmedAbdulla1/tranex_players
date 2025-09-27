import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/models/accessories_model/accessories_model.dart';
import 'package:tranex_users/data/models/categories_model/category_model.dart';
import 'package:tranex_users/data/models/coach_model/coach_model.dart';
import 'package:tranex_users/data/models/coache_players_model/coach_players_model.dart';
import 'package:tranex_users/data/models/device_model/device_model.dart';
import 'package:tranex_users/data/models/exercise_model/exercise_model.dart';
import 'package:tranex_users/data/models/player_model/player_model.dart';
import 'package:tranex_users/data/models/training_data_model/training_data_model.dart';
import 'package:tranex_users/data/models/training_model/training_model.dart';
import 'package:tranex_users/data/models/training_seesion_model/training_seesion_model.dart';
import 'package:tranex_users/data/network/error_handler.dart';
import 'package:tranex_users/data/network/failure.dart';

import '../api_services/api_services.dart';
import 'repo.dart';

class RepoImplementation implements Repo {
  ApiServices apiServices;
  RepoImplementation(this.apiServices);

  @override
  Future<Either<Failure, List<DeviceModel>>> fetchDevices() async {
    try {
      var response = await apiServices.fetchDevices();
      if (response.isEmpty) {
        return left(Failure(message: 'No devices found', code: 404));
      }
      log("Devices Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log("Error: ${failure.message}");
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CoachModel>>> fetchCoaches() async {
    try {
      var response = await apiServices.fetchCoches();
      if (response.isEmpty) {
        return left(Failure(message: 'No devices found'));
      }
      log("Devices Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'fetchCoaches Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CoachPlayersModel>>> fetchCoachPlayers() async {
    try {
      var response = await apiServices.fetchCoachPlayers();
      if (response.isEmpty) {
        return left(Failure(message: 'No Coache Players found'));
      }
      log("Coache Players Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'fetchCoachePlayers Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> fetchCategories() async {
    try {
      var response = await apiServices.fetchCategories();
      if (response.isEmpty) {
        return left(Failure(message: 'No Categories found'));
      }
      log("Categories Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Categories Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<AccessoriesModel>>> fetchAccessories() async {
    try {
      var response = await apiServices.fetchAccessories();
      if (response.isEmpty) {
        return left(Failure(message: 'No Accessories found'));
      }
      log("Accessories Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Accessories Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<ExerciseModel>>> fetchExercises() async {
    try {
      var response = await apiServices.fetchExercises();
      if (response.isEmpty) {
        return left(Failure(message: 'No Exercises found'));
      }
      log("Exercises Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Exercises Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<PlayerModel>>> fetchPlayers() async {
    try {
      var response = await apiServices.fetchPlayers();
      if (response.isEmpty) {
        return left(Failure(message: 'No Players found'));
      }
      log("Players Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Players Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<TrainingModel>>> fetchTraining() async {
    try {
      var response = await apiServices.fetchTraining();
      if (response.isEmpty) {
        return left(Failure(message: 'No Training found'));
      }
      log("Training Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Training Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<TrainingDataModel>>> fetchTrainingData() async {
    try {
      var response = await apiServices.fetchTrainingData();
      if (response.isEmpty) {
        return left(Failure(message: 'No Training Data found'));
      }
      log("Training Data Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Training Data Error');
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<TrainingSeesionModel>>>
      fetchTrainingSessions() async {
    try {
      var response = await apiServices.fetchTrainingSessions();
      if (response.isEmpty) {
        return left(Failure(message: 'No Training Sessions found'));
      }
      log("Training Sessions Response: ${response.toString()}");
      return right(response);
    } catch (e) {
      final failure = ErrorHandler.handle(e).failure;
      log(failure.message, name: 'Training Sessions Error');
      return left(failure);
    }
  }
}
