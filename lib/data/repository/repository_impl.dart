import 'dart:io';
import 'package:tranex_users/data/data_source/local_data_source.dart';
import 'package:tranex_users/data/data_source/remote_data_source.dart';
import 'package:tranex_users/data/network/error_handler.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/network_info.dart';
import 'package:tranex_users/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';

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



}
