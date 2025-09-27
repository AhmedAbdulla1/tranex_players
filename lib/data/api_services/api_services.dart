import 'package:dio/dio.dart';
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
import 'package:tranex_users/data/network/api.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

@RestApi(baseUrl: ApiUrl.baseApi)
abstract class ApiServices {
  factory ApiServices(Dio dio, {String baseUrl}) = _ApiServices;
  @GET(ApiUrl.devices)
  Future<List<DeviceModel>> fetchDevices();

  @GET(ApiUrl.coaches)
  Future<List<CoachModel>> fetchCoches();

  @GET(ApiUrl.coachPlayers)
  Future<List<CoachPlayersModel>> fetchCoachPlayers();

  @GET(ApiUrl.categories)
  Future<List<CategoryModel>> fetchCategories();

  @GET(ApiUrl.accessories)
  Future<List<AccessoriesModel>> fetchAccessories();

  @GET(ApiUrl.exercises)
  Future<List<ExerciseModel>> fetchExercises();

  @GET(ApiUrl.players)
  Future<List<PlayerModel>> fetchPlayers();

  @GET(ApiUrl.training)
  Future<List<TrainingModel>> fetchTraining();

  @GET(ApiUrl.trainingSessions)
  Future<List<TrainingSeesionModel>> fetchTrainingSessions();

  @GET(ApiUrl.trainingData)
  Future<List<TrainingDataModel>> fetchTrainingData();
}
