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
import 'package:tranex_users/data/network/failure.dart';

abstract class Repo {
  Future<Either<Failure, List<DeviceModel>>> fetchDevices();

  Future<Either<Failure, List<CoachModel>>> fetchCoaches();

  Future<Either<Failure, List<CoachPlayersModel>>> fetchCoachPlayers();

  Future<Either<Failure, List<CategoryModel>>> fetchCategories();

  Future<Either<Failure, List<AccessoriesModel>>> fetchAccessories();

  Future<Either<Failure, List<ExerciseModel>>> fetchExercises();

  Future<Either<Failure, List<PlayerModel>>> fetchPlayers();

  Future<Either<Failure, List<TrainingModel>>> fetchTraining();

  Future<Either<Failure, List<TrainingSeesionModel>>> fetchTrainingSessions();

  Future<Either<Failure, List<TrainingDataModel>>> fetchTrainingData();
}
