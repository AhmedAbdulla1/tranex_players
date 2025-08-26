import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/data_source/local_data_source.dart';
import 'package:firesport_users/data/data_source/remote_data_source.dart';
import 'package:firesport_users/data/mapper/mapper.dart';
import 'package:firesport_users/data/network/error_handler.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/network_info.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/trainees_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TraineesRepoImpl implements TraineesRepository {
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  TraineesRepoImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<TraineeData>>> getTrainees() async {
    if (await _networkInfo.isConnected) {
      try {
        List<Map<String, dynamic>> response =
            await _remoteDataSource.getTeamsDataResponse();
        print(response);
        return Right(response.toDomain());
      } catch (error) {
        print(error);
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }

  @override
  Future<Either<Failure, TraineeData>> login(LoginRequest loginRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response =
            await _remoteDataSource.checkTraineeExistence(loginRequest.userId);

        print(response);
        if (response['exist'] == true) {
          return Right(response.traineeDataToDomain());
        } else {
          return Left(Failure(code: 10, message: 'Trainee does not exist'));
        }
      } catch (error) {
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addTrainingData(
      AddTrainingRequest addTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.addTrainingDataResponse(addTrainingRequest);
        return const Right(0);
      } catch (error) {
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }

  @override
  Future<Either<Failure, Data?>> getLastTrainingData(
      GetTrainingRequest getTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response = await _remoteDataSource
            .getLastTrainingDataResponse(getTrainingRequest);
        print(response);
        if (response['empty'] ?? false) return const Right(null);
        if (response['error'] ?? false) {
          return Left(
            ErrorHandler.handle(response['message']).failure,
          );
        }
        return Right(response.dataToDomain());
      } catch (error) {
        print(error);
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }

  @override
  Future<Either<Failure, TrainingData>> getTrainingData(
      GetTrainingRequest getTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response =
            await _remoteDataSource.getTrainingDataResponse(getTrainingRequest);

        return Right(response.trainingDataToDomain());
      } catch (error) {
        log(error.toString());
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }

  @override
  Future<Either<Failure, MatchesEntity>> getMatches(String traineeId) async {
    if (_networkInfo.isConnected) {
      try {
        List<dynamic> response = await _remoteDataSource.getMatches(traineeId);

        return Right(MatchesEntity.fromJson(response));
      } catch (error) {
        log(error.toString());
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Either<Failure, TraineeData> getUser() {
    try {
      return Right(_remoteDataSource.getCurrentUserResponse());
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }


  @override
  Future<Either<Failure, void>> logout()async {
    try {
      return Right(0);
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      UpdateProfileRequest updateProfileRequest) async {
    try {
      User user =
      await _remoteDataSource.updateProfileResponse(updateProfileRequest);
      return Right(user);
    } catch (error) {
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }
}
