import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/core/storage/hive_boxes.dart';
import 'package:tranex_users/core/storage/hive_keys.dart';
import 'package:tranex_users/core/storage/hive_manager.dart';
import 'package:tranex_users/data/data_source/remote_data_source.dart';
import 'package:tranex_users/data/mapper/mapper.dart';
import 'package:tranex_users/data/network/error_handler.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/network_info.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/repository/user_repo.dart';

class UserRepositoryImpl extends UserRepository {
  late final RemoteDataSource _remoteDataSource;
  late NetworkInfo _networkInfo;

  UserRepositoryImpl({required remoteDataSource, required networkInfo}) {
    _networkInfo = networkInfo;
    _remoteDataSource = remoteDataSource;
  }

  @override
  Future<Either<Failure, TraineeData>> login(LoginRequest loginRequest) async {
    if (_networkInfo.isConnected) {
      try {
        final Map<String, dynamic> response =
            await _remoteDataSource.loginResponse(loginRequest);
        log(response.toString(), name: 'loginResponse in user repo impl');
        final TraineeData traineeData = response.traineeDataToDomain();
        // Save the user data locally using Hive
        await HiveManager.put(
            boxName: HiveBoxes.userDataBox,
            key: HiveKeys.userDataKey,
            value: traineeData);
        return Right(traineeData);
      } catch (error, s) {
        log(error.toString());
        log(s.toString());

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
  Future<Either<Failure, AuthResponse>> register(
      RegisterRequest registerRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final AuthResponse response =
            await _remoteDataSource.registerResponse(registerRequest);
        // if (!response.emailVerified) {
        //   await response.sendEmailVerification();
        // }
        log(response.toString(), name: 'registerResponse in user repo impl');
        return Right(response);
        // } on FirebaseAuthException catch (error) {
        //   return Left(
        //     ErrorHandler.handle(error).failure,
        //   );
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
  Future<Either<Failure, User>> registerWithGoogle() async {
    if (await _networkInfo.isConnected) {
      try {
        final User? response =
            await _remoteDataSource.loginWithGoogleResponse();
        // if (!response.emailVerified) {
        //   response.sendEmailVerification();
        // }
        if (response == null) {
          return Left(Failure(code: 404, message: 'No user logged in.'));
        }
        return Right(response);
        // } on FirebaseAuthException catch (error) {
        //   if (error.code == 'email-already-in-use') {
        //     return Left(Failure(
        //         code: 100,
        //         message: 'The account already exists for that email.'));
        //   } else {
        //     return Left(
        //       ErrorHandler.handle(error).failure,
        //     );
        //   }
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
  Future<Either<Failure, User>> registerAnonymous() async {
    if (await _networkInfo.isConnected) {
      try {
        final User response =
            await _remoteDataSource.registerAnonymousResponse();
        return Right(response);
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
  Future<Either<Failure, void>> sendResetPasswordEmail(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.sendResetPasswordEmail(email);
        return const Right(null);
        // } on Supabase catch (error) {
        //   return Left(
        //     ErrorHandler.handle(error).failure,
        //   );
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
  Either<Failure, User> getUser() {
    try {
      final User? user = _remoteDataSource.getCurrentUserResponse();
      if (user != null) {
        return Right(user);
      } else {
        return Left(Failure(code: 404, message: 'No user logged in.'));
      }
    } catch (error) {
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }

  @override
  Future<Either<Failure, int>> getCoachId() async {
    try {
      final int? id = await _remoteDataSource.getCoachId();
      if (id != null) {
        return Right(id);
      } else {
        return Left(Failure(code: 404, message: 'No user logged in.'));
      }
    } catch (error) {
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }

@override
Future<Either<Failure, User>> updateProfile(
    UpdateProfileRequest updateProfileRequest) async {
  try {
    User user =
        await _remoteDataSource.updateProfileResponse(updateProfileRequest);

    final traineeData = user.userToTraineeData();

    // ✅ Save locally in Hive
    await HiveManager.put(
      boxName: HiveBoxes.userDataBox,
      key: HiveKeys.userDataKey,
      value: traineeData,
    );

    log("✅ User updated and cached locally in Hive: $traineeData");

    return Right(user);
  } catch (error, st) {
    log("❌ Error in updateProfile: $error", stackTrace: st);
    return Left(
      ErrorHandler.handle(error).failure,
    );
  }
}

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccountResponse();

      return const Right(null);
      // } on FirebaseAuthException catch (error) {
      //   print(error);
      //
      //   return Left(
      //     ErrorHandler.handle(error).failure,
      //   );
    } catch (error) {
      print(error);
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logoutResponse();
      return const Right(null);
    } catch (error) {
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }

  @override
  Future<Either<Failure, bool>> connectToHeadCoach(String code) async {
    try {
      final bool response = await _remoteDataSource.connectToHeadCoach(code);
      if (response) {
        return const Right(true);
      }
      return Left(Failure(code: 404, message: 'Code is invalid.'));
    } catch (error) {
      return Left(
        ErrorHandler.handle(error).failure,
      );
    }
  }
}
