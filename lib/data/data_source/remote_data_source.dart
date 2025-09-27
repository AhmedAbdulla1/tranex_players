import 'dart:developer';
import 'dart:io';

import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/data/network/supabase.dart';
import 'package:tranex_users/data/network/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteDataSource {
  Future<Map<String, dynamic>> loginResponse(LoginRequest loginRequest);

  Future<AuthResponse> registerResponse(RegisterRequest registerRequest);

  Future<User?> loginWithGoogleResponse();

  Future<User> registerAnonymousResponse();

  User? getCurrentUserResponse();

  Future<int?> getCoachId();

  Future<User> updateProfileResponse(UpdateProfileRequest updateProfileRequest);

  Future<void> sendResetPasswordEmail(String email);

  Future<void> deleteAccountResponse();

  Future<void> logoutResponse();

  Future<bool> connectToHeadCoach(String code);

/////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getExercises();

  Future<String> addNewExerciseResponse(
      AddNewExerciseRequest addNewExerciseRequest);

  Future<void> addMatch(MatchRequest addNewExerciseRequest);

  Future<List<dynamic>> getMatches(String traineeId);

  Future<void> deleteExercise(String categoryId, String exerciseId);

  Future<List<Map<String, dynamic>>> getDevices();

  ////////////////////////////

  Future<User> dashboardResponse();

  Future getTraineesDataResponse();

  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId);

  Future<String?> uploadImage(File image, String folderName);

  Future addTrainingDataResponse(AddTrainingRequest addTrainingDataRequest);

  Future<List<Map<String, dynamic>>> getTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest);

  Future<Map<String, dynamic>> getLastTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest);

  Future saveFencingTrainingResponse(SaveTrainingFencingRequest saveTrainingFencingRequest);

}



class RemoteDataSourceImpl extends RemoteDataSource {
  final SupabaseAppClient _appServicesClient;
  final SupabaseService _supabaseService;

  RemoteDataSourceImpl(
      {required SupabaseAppClient appServicesClient,
      required SupabaseService supabaseService})
      : _appServicesClient = appServicesClient,
        _supabaseService = supabaseService;

  @override
  Future<Map<String, dynamic>> loginResponse(LoginRequest loginRequest) async {
    log("In Remote Data Source");
    return await _appServicesClient.loginWithEmail(loginRequest);
  }

  @override
  Future<AuthResponse> registerResponse(RegisterRequest registerRequest) async {
    return await _appServicesClient.register(registerRequest);
  }

// forgot password
  @override
  Future<void> sendResetPasswordEmail(String email) async {
    // return await _appServicesClient.sendPasswordResetEmail(email: email);
  }

  @override
  Future<User?> loginWithGoogleResponse() async {
    return await _appServicesClient.loginWithGoogle();
  }

  @override
  Future<User> registerAnonymousResponse() async {
    return await _appServicesClient.registerAnonymous();
  }

  @override
  Future<User> updateProfileResponse(
      UpdateProfileRequest updateProfileRequest) {
    return _appServicesClient.updateProfile(updateProfileRequest);
  }

  @override
  Future deleteAccountResponse() {
    return _appServicesClient.deleteAccount();
  }

  @override
  User? getCurrentUserResponse() {
    return _appServicesClient.getUser();
  }

  @override
  Future<int?> getCoachId() {
    return _appServicesClient.getCoachId();
  }

  @override
  Future<void> logoutResponse() {
    return _appServicesClient.logout();
  }

  /////////////////////////////////////////////////////////////////

  @override
  Future<List<Map<String, dynamic>>> getExercises() async {
    return await _supabaseService.getExercises();
  }

  @override
  Future<String> addNewExerciseResponse(
      AddNewExerciseRequest addNewExerciseRequest) async {
    // return'';
    return await _supabaseService.addExercise(addNewExerciseRequest);
  }

  @override
  Future<void> addMatch(MatchRequest addNewExerciseRequest) async {
    return await _supabaseService.addMatch(addNewExerciseRequest);
  }

  @override
  Future<void> deleteExercise(String categoryId, String exerciseId) async {
    // return await _supabaseService.deleteExercise( categoryId, exerciseId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDevices() async {
    return await _supabaseService.getDevices();
  }

//////////////////////////////////////////////////////////////////////////////

  @override
  Future getTraineesDataResponse() async {
    return await _supabaseService.getTrainees();
  }

  @override
  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId) async {
    return await _supabaseService.checkTraineeExistence(traineeId);
  }

  @override
  Future<String?> uploadImage(File image, String folderName) async {
    return await _appServicesClient.uploadImageToSupabase(image, folderName);
  }

  @override
  Future<User> dashboardResponse() async {
    return await _appServicesClient.dashboard();
  }

  @override
  Future<void> addTrainingDataResponse(
      AddTrainingRequest addTrainingDataRequest) {
    return _supabaseService.saveTrainingData(addTrainingDataRequest);
  }

  @override
  Future<Map<String, dynamic>> getLastTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest) async {
    return _supabaseService.getLastTrainingData(getTrainingDataRequest);
  }

  @override
  Future<List< Map<String, dynamic>>> getTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest) async {
    return _supabaseService.getTrainingData(getTrainingDataRequest);
  }

  @override
  Future<List> getMatches(String traineeId) {
    return _supabaseService.getMatches(traineeId);
  }

  @override
  Future<bool> connectToHeadCoach(String code) {
    return _appServicesClient.connectToHeadCoach(code: code);
  }

  @override
  Future saveFencingTrainingResponse(SaveTrainingFencingRequest saveTrainingFencingRequest) {
   return _supabaseService.saveFencingTraining(saveTrainingFencingRequest);
  }
}
