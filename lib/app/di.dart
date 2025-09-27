import 'package:tranex_users/data/data_source/local_data_source.dart';
import 'package:tranex_users/data/network/supabase.dart';
import 'package:tranex_users/data/network/supabase_service.dart';
import 'package:tranex_users/data/repository/exercise_repo_impl.dart';
import 'package:tranex_users/data/repository/trainess_repo_impl.dart';
import 'package:tranex_users/data/repository/user_repo_impl.dart';
import 'package:tranex_users/domain/repository/exercise_repo.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';
import 'package:tranex_users/domain/repository/user_repo.dart';
import 'package:tranex_users/domain/usecase/add_new_exercise_usecase.dart';
import 'package:tranex_users/domain/usecase/exercise_usecase.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/presentation/add_new_exercise/view_model.dart';
import 'package:tranex_users/presentation/exercises/view_model.dart';
import 'package:tranex_users/presentation/login_screen/view_model/login_view_model.dart';
import 'package:tranex_users/presentation/main_screen/main_view_model.dart';
import 'package:tranex_users/presentation/main_screen/screens/dashboard/view_model.dart';
import 'package:tranex_users/presentation/main_screen/screens/profile/view_model.dart';
import 'package:tranex_users/presentation/profile_details_screen/view_model.dart';
import 'package:tranex_users/presentation/reset_password_screen/view_model/recover_password_view_model.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/data/data_source/remote_data_source.dart';
import 'package:tranex_users/data/network/network_info.dart';
import 'package:tranex_users/data/repository/repository_impl.dart';
import 'package:tranex_users/domain/repository/repository.dart';
import 'package:tranex_users/domain/usecase/user_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  final shardPref = await SharedPreferences.getInstance();
  // instance for shared pref
  instance.registerLazySingleton(() => shardPref);
  // instant for AppPreferences
  instance.registerLazySingleton(
    () => AppPreferences(
      instance<SharedPreferences>(),
    ),
  );

  // instant for network info
  instance.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(),
  );


  // instant for supabase;
  instance.registerLazySingleton<SupabaseAppClient>(
    () => SupabaseAppClient(),
  );
  instance.registerLazySingleton<SupabaseService>(
        () => SupabaseService(),
  );


  // instant for remoteDataSource
  instance.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      appServicesClient: instance<SupabaseAppClient>(),
      supabaseService: instance<SupabaseService>(),
    ),
  );
  // instance for local data source
  instance.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(),
  );
//   //instant for repository

  instance.registerLazySingleton<Repository>(
    () => RepositoryImpl(
      instance<LocalDataSource>(),
      instance<RemoteDataSource>(),
      instance<NetworkInfo>(),
    ),
  );

  instance.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: instance<RemoteDataSource>(),
      networkInfo: instance<NetworkInfo>(),
    ),
  );
}

initLoginModule() {
  if (!GetIt.I.isRegistered<UserUsecase>()) {
    instance.registerFactory<UserUsecase>(
      () => UserUsecase(
        instance<UserRepository>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<LoginViewModel>()) {
    instance.registerFactory<LoginViewModel>(
      () => LoginViewModel(
        instance<UserUsecase>(),
      ),
    );
  }
}


initTraineesModule() {
  if (!GetIt.I.isRegistered<TraineesRepository>()) {
    instance.registerFactory<TraineesRepository>(
      () => TraineesRepoImpl(
        instance<RemoteDataSource>(),
        instance<NetworkInfo>(),
      ),
    );
  }

  if (!GetIt.I.isRegistered<TrainingUsecase>()) {
    instance.registerFactory<TrainingUsecase>(
      () => TrainingUsecase(),
    );
  }
}

initRecoverPasswordModule() {
  if (!GetIt.I.isRegistered<UserUsecase>()) {
    instance.registerFactory<UserUsecase>(
      () => UserUsecase(
        instance<UserRepository>(),
      ),
    );
    instance.registerFactory<RecoverPasswordViewModel>(
      () => RecoverPasswordViewModel(
        instance<UserUsecase>(),
      ),
    );
  }
}

initExerciseModule() {
  if (!GetIt.I.isRegistered<ExerciseRepository>()) {
    instance.registerFactory<ExerciseRepository>(
      () => ExerciseRepoImpl(
        instance<NetworkInfo>(),
        instance<RemoteDataSource>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<ExerciseUsecase>()) {
    instance.registerFactory<ExerciseUsecase>(
      () => ExerciseUsecase(
        repository: instance<ExerciseRepository>(),
      ),
    );
  }

  if (!GetIt.I.isRegistered<ExercisesViewModel>()) {
    instance.registerFactory<ExercisesViewModel>(
      () => ExercisesViewModel(),
    );
  }
}

initAddNewExerciseModule() {
  if (!GetIt.I.isRegistered<ExerciseRepository>()) {
    instance.registerFactory<ExerciseRepository>(
      () => ExerciseRepoImpl(
        instance<NetworkInfo>(),
        instance<RemoteDataSource>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<AddNewExerciseUseCase>()) {
    instance.registerFactory<AddNewExerciseUseCase>(
      () => AddNewExerciseUseCase(
        repository: instance<ExerciseRepository>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<AddNewExerciseViewModel>()) {
    instance.registerFactory<AddNewExerciseViewModel>(
      () => AddNewExerciseViewModel(),
    );
  }
}

initMainModule() {
  initAddNewExerciseModule();
  initTraineesModule();
  if (!GetIt.I.isRegistered<MainViewModel>()) {
    instance.registerFactory<MainViewModel>(
        () => MainViewModel(instance<NetworkInfo>()));
  }
  if (!GetIt.I.isRegistered<UserUsecase>()) {
    instance.registerFactory<UserUsecase>(
      () => UserUsecase(
        instance<UserRepository>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<ProfileViewModel>()) {
    instance.registerFactory<ProfileViewModel>(
      () => ProfileViewModel(
        instance<UserUsecase>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<DashboardViewModel>()) {
    instance.registerFactory<DashboardViewModel>(
      () => DashboardViewModel(
        instance<UserUsecase>(),
      ),
    );
  }
}

initProfileDetailsModule() {
  if (!GetIt.I.isRegistered<UserUsecase>()) {
    instance.registerFactory<UserUsecase>(
      () => UserUsecase(
        instance<UserRepository>(),
      ),
    );
  }
  if (!GetIt.I.isRegistered<ProfileDetailsViewModel>()) {
    instance.registerFactory<ProfileDetailsViewModel>(
      () => ProfileDetailsViewModel(
        instance<UserUsecase>(),
      ),
    );
  }
}
