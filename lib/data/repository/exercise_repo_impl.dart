import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/data_source/remote_data_source.dart';
import 'package:firesport_users/data/mapper/mapper.dart';
import 'package:firesport_users/data/network/error_handler.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/network_info.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/exercise_repo.dart';

class ExerciseRepoImpl implements ExerciseRepository {
  final NetworkInfo _networkInfo;
  final RemoteDataSource _remoteDataSource;

  ExerciseRepoImpl(this._networkInfo, this._remoteDataSource);

  @override
  Future<Either<Failure, int>> addNewExercise(AddNewExerciseRequest addNewExerciseRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final String response = await _remoteDataSource.addNewExerciseResponse(addNewExerciseRequest);
        return Right(int.parse(response));
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }

  @override
  Future<void> deleteExercise(String categoryId, String exerciseId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteExercise(categoryId, exerciseId);
      } catch (error) {
        throw ErrorHandler.handle(error).failure;
      }
    } else {
      throw DataSource.noInternetConnection.getFailure();
    }
  }


  @override
  Future<Either<Failure, List<CategoryData>>> getExercises() async {
    if (await _networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> response = await _remoteDataSource.getExercises();

        print(response);
        return Right(response.categoriesToDomain());
      } catch (error) {
        print(error);
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }

  @override
  Future<Either<Failure, List<DeviceData>>> getDevices() async{
    // if (await _networkInfo.isConnected) {
      try {
        final List<Map<String, dynamic>> response = await _remoteDataSource.getDevices();
        print(response);
        return Right(response.devicesToDomain());
      } catch (error) {
        print(error);
        return Left(ErrorHandler.handle(error).failure);
      }
    // } else {
    //   return Left(DataSource.noInternetConnection.getFailure());
    // }
  }
}
