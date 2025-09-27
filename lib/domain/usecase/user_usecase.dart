import 'package:dartz/dartz.dart';
import 'package:tranex_users/core/models/models.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/repository/user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserUsecase {
  final UserRepository _repository;

  UserUsecase(this._repository);

  Future<Either<Failure, TraineeData>> loginWithEmail(LoginRequest input) {
    return _repository.login(input);
  }

  Future<Either<Failure, User>> loginWithGoogle() {
    return _repository.registerWithGoogle();
  }

  Future<Either<Failure, User>> loginAnonymous() {
    return _repository.registerAnonymous();
  }

  Future<Either<Failure, AuthResponse>> register(RegisterRequest input) {
    return _repository.register(input);
  }

  Future<Either<Failure, void>> sendResetPasswordEmail(String email) {
    return _repository.sendResetPasswordEmail(email);
  }

  Either<Failure, User> getUser() {
    return _repository.getUser();
  }

  Future<Either<Failure, int>> getCoachId() {
    return _repository.getCoachId();
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

  Future<Either<Failure, bool>> connectToHeadCoach({required String code}) {
    return _repository.connectToHeadCoach(code);
  }
}
