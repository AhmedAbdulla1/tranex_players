import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tranex_users/data/data_source/remote_data_source.dart';
import 'package:tranex_users/data/mapper/mapper.dart';
import 'package:tranex_users/data/network/error_handler.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/network_info.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/models/training_entity.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';

class TraineesRepoImpl implements TraineesRepository {
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  TraineesRepoImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<TraineeData>>> getTrainees() async {
    if (_networkInfo.isConnected) {
      try {
        List<Map<String, dynamic>> response =
            await _remoteDataSource.getTraineesDataResponse();
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
  Future<Either<Failure, TraineeData>> checkTraineeExistence(
      String traineeId) async {
    if (_networkInfo.isConnected) {
      try {
        Map<String, dynamic> response =
            await _remoteDataSource.checkTraineeExistence(traineeId);
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
    if (_networkInfo.isConnected) {
      try {
        await _remoteDataSource.addTrainingDataResponse(addTrainingRequest);
        return const Right(0);
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
  Future<Either<Failure, AllTrainingsEntity>> getTrainingData(
      GetTrainingRequest getTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      // try {
      List<Map<String, dynamic>> response =
          await _remoteDataSource.getTrainingDataResponse(getTrainingRequest);
      return Right(response.trainingsToDomain());
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
      } catch (error, stackTrace) {
        log(error.toString());
        log(stackTrace.toString());
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
  Future<Either<Failure, void>> saveFencingTraining(
      SaveTrainingFencingRequest addTrainingRequest) async {
    if (_networkInfo.isConnected) {
      try {
        await _remoteDataSource.saveFencingTrainingResponse(addTrainingRequest);
        return const Right(0);
      } catch (error, stackTrace) {
        debugPrint(error.toString());
        debugPrintStack(stackTrace: stackTrace, label: "saveFencingTraining");
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
}
