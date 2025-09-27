import 'package:dio/dio.dart';
import 'package:tranex_users/data/api_services/api_services.dart';
import 'package:tranex_users/data/api_services/dio_client.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:tranex_users/presentation/cubits/accessories_cubit/accessories_cubit.dart';
import 'package:tranex_users/presentation/cubits/categories_cubit/categories_cubit.dart';
import 'package:tranex_users/presentation/cubits/coach_players_cubit/coache_players_cubit.dart';
import 'package:tranex_users/presentation/cubits/coaches_cubit/coaches_cubit.dart';
import 'package:tranex_users/presentation/cubits/devices_cubit/devices_cubit.dart';
import 'package:tranex_users/presentation/cubits/exercises_cubit/exercises_cubit.dart';
import 'package:tranex_users/presentation/cubits/player_cubit/player_cubit.dart';
import 'package:tranex_users/presentation/cubits/training_cubit/training_cubit.dart';
import 'package:tranex_users/presentation/cubits/training_data_cubit/training_data_cubit.dart';
import 'package:tranex_users/presentation/cubits/training_sessions_cubit/training_sessions_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Dio
  sl.registerLazySingleton<Dio>(() => createDioClient());

  // ApiServices
  sl.registerLazySingleton<ApiServices>(() => ApiServices(sl<Dio>()));

  // Repo
  sl.registerLazySingleton<RepoImplementation>(
      () => RepoImplementation(sl<ApiServices>()));

  // Devices Cubit
  sl.registerLazySingleton<DevicesCubit>(
      () => DevicesCubit(sl<RepoImplementation>()));

  // Coaches Cubit
  sl.registerLazySingleton<CoachesCubit>(
      () => CoachesCubit(sl<RepoImplementation>()));

  // Coache Players Cubit
  sl.registerLazySingleton<CoachePlayersCubit>(
      () => CoachePlayersCubit(sl<RepoImplementation>()));

  // Categories Cubit
  sl.registerLazySingleton<CategoriesCubit>(
      () => CategoriesCubit(sl<RepoImplementation>()));

  // Accessories Cubit
  sl.registerLazySingleton<AccessoriesCubit>(
      () => AccessoriesCubit(sl<RepoImplementation>()));

  // Exercises Cubit
  sl.registerLazySingleton<ExercisesCubit>(
      () => ExercisesCubit(sl<RepoImplementation>()));

  // Player Cubit
  sl.registerLazySingleton<PlayerCubit>(
      () => PlayerCubit(sl<RepoImplementation>()));

  // Training Cubit
  sl.registerLazySingleton<TrainingCubit>(
      () => TrainingCubit(sl<RepoImplementation>()));

  // TrainingSessions Cubit
  sl.registerLazySingleton<TrainingSessionsCubit>(
      () => TrainingSessionsCubit(sl<RepoImplementation>()));

  // TrainingData Cubit
  sl.registerLazySingleton<TrainingDataCubit>(
      () => TrainingDataCubit(sl<RepoImplementation>()));
}
