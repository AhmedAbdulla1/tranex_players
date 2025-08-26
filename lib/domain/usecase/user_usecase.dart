import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/trainees_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserUsecase {
  final TraineesRepository _repository;

  UserUsecase(this._repository);

  Future<Either<Failure, void>> login(LoginRequest input) {
    return _repository.login(input);
  }

  Either<Failure, TraineeData> getUser() {
    return _repository.getUser();
  }

  Future<Either<Failure, void>> updateProfile(UpdateProfileRequest input) {
    return _repository.updateProfile(input);
  }

  Future<Either<Failure, void>> deleteAccount() {
    return _repository.deleteAccount();
  }

  Future<Either<Failure, void>> logout() {
    return _repository.logout();
  }
}
