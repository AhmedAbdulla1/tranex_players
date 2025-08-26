import 'dart:io';
import 'package:firesport_users/data/data_source/local_data_source.dart';
import 'package:firesport_users/data/data_source/remote_data_source.dart';
import 'package:firesport_users/data/mapper/mapper.dart';
import 'package:firesport_users/data/network/error_handler.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/network_info.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class RepositoryImpl implements Repository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  RepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );


  @override
  Future<Either<Failure, UserData>> dashboard() async {
    // try {
    //   final response =
    //       await _localDataSource.homeResponse(await _networkInfo.isConnected);
    //   return Right(
    //     response.toDomain(),
    //   );
    // } catch (cacheError) {
      if (await _networkInfo.isConnected) {
        final User response =
            await _remoteDataSource.dashboardResponse();
        try {
            // _localDataSource.saveHomeToCache(response);
            return Right(
              response.toDomain(),
            );
        } catch (error) {
          return Left(
            ErrorHandler.handle(error).failure,
          );
        }
      } else {
        return Left(
          DataSource.noInternetConnection.getFailure(),
        );
      // }
    }
  }





  // @override
  // Future<Either<Failure, List<TeamData>>> getTeams() async {
  //   if (await _networkInfo.isConnected) {
  //     try {
  //       List<Map<String, dynamic>> response =
  //           await _remoteDataSource.getTeamsResponse();
  //       return Right(response.toDomain(withTrainees: false));
  //     } catch (error) {
  //       return Left(
  //         ErrorHandler.handle(error).failure,
  //       );
  //     }
  //   } else {
  //     return Left(
  //       DataSource.noInternetConnection.getFailure(),
  //     );
  //   }
  // }

  @override
  Future<Either<Failure, List<TraineeData>>> getTrainees() async {
    if (await _networkInfo.isConnected) {
      try {
        List<Map<String, dynamic>> response =
            await _remoteDataSource.getTeamsDataResponse();

        return Right(response.toDomain());
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image,String folderName) async {
    if (await _networkInfo.isConnected) {
      try {
        String? response = await _remoteDataSource.uploadImage(image,folderName);
        return Right(response ?? "");
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }

  @override
  Future<Either<Failure, String>> addNewExercise(
      AddNewExerciseRequest addNewExerciseRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        String response = await _remoteDataSource
            .addNewExerciseResponse(addNewExerciseRequest);
        return Right(response);
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.noInternetConnection.getFailure());
    }
  }


  @override
  Future<Either<Failure, void>> checkTraineeExistence(String traineeId) async {
    debugPrint('check trainee');
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response =
            await _remoteDataSource.checkTraineeExistence(traineeId);
        if (response['exist'] == true) {
          return const Right(0);
        } else {
          return Left(Failure(code: 101, message: 'Trainee does not exist'));
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
  Future<Either<Failure, Data>> getLastTrainingData(
      GetTrainingRequest getTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response = await _remoteDataSource
            .getLastTrainingDataResponse(getTrainingRequest);

        return Right(response.dataToDomain());
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
  Future<Either<Failure, TrainingData>> getTrainingData(
      GetTrainingRequest getTrainingRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        Map<String, dynamic> response =
            await _remoteDataSource.getTrainingDataResponse(getTrainingRequest);

        return Right(response.trainingDataToDomain());
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


}
