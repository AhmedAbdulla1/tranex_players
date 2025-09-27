import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';

abstract class UserRepository {
  Future<Either<Failure, TraineeData>> login(LoginRequest loginRequest);
  Future<Either<Failure, AuthResponse>> register(
      RegisterRequest registerRequest);
  Future<Either<Failure, User>> registerWithGoogle();
  Future<Either<Failure, User>> registerAnonymous();
  Future<Either<Failure, void>> sendResetPasswordEmail(String email);
  Either<Failure, User> getUser();
  Future<Either<Failure, int>> getCoachId();
  Future<Either<Failure, User>> updateProfile(
      UpdateProfileRequest updateProfileRequest);
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> connectToHeadCoach(String code);
}
