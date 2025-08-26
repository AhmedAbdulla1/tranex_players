import 'dart:io';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/data/network/supabase_service.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firesport_users/data/network/supabase.dart';

abstract class RemoteDataSource {
  Future<Map<String,dynamic>> loginResponse(LoginRequest loginRequest);

  TraineeData getCurrentUserResponse();

  Future<int?> getCoachId();

  Future<User> updateProfileResponse(UpdateProfileRequest updateProfileRequest);

  Future<void> deleteAccountResponse();

  Future<void> logoutResponse();

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

  Future getTeamsDataResponse();

  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId);

  Future<String?> uploadImage(File image, String folderName);

  Future addTrainingDataResponse(AddTrainingRequest addTrainingDataRequest);

  Future<Map<String, dynamic>> getTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest);

  Future<Map<String, dynamic>> getLastTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest);
}

class RemoteDataSourceImpl extends RemoteDataSource {
  final SupabaseAppClient _appServicesClient;
  final SupabaseService _firestoreService;

  RemoteDataSourceImpl(
      {required SupabaseAppClient appServicesClient,
      required SupabaseService firestoreService})
      : _appServicesClient = appServicesClient,
        _firestoreService = firestoreService;

  @override
  Future<Map<String, dynamic>> loginResponse(LoginRequest loginRequest) async {
    return await _firestoreService.checkTraineeExistence(loginRequest.userId);
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
  TraineeData getCurrentUserResponse() {
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
    return await _firestoreService.getExercises();
  }

  @override
  Future<String> addNewExerciseResponse(
      AddNewExerciseRequest addNewExerciseRequest) async {
    // return'';
    return await _firestoreService.addExercise(addNewExerciseRequest);
  }

  @override
  Future<void> addMatch(MatchRequest addNewExerciseRequest) async {
    // return'';
    return await _firestoreService.addMatch(addNewExerciseRequest);
  }

  @override
  Future<void> deleteExercise(String categoryId, String exerciseId) async {
    // return await _firestoreService.deleteExercise( categoryId, exerciseId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDevices() async {
    return await _firestoreService.getDevices();
  }

//////////////////////////////////////////////////////////////////////////////

  @override
  Future getTeamsDataResponse() async {
    return await _firestoreService.getTrainees();
  }

  @override
  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId) async {
    return await _firestoreService.checkTraineeExistence(traineeId);
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
    return _firestoreService.saveTrainingData(addTrainingDataRequest);
  }

  @override
  Future<Map<String, dynamic>> getLastTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest) async {
    return {"": ""};
    // return _firestoreService.getLastTrainingData(getTrainingDataRequest);
  }

  @override
  Future<Map<String, dynamic>> getTrainingDataResponse(
      GetTrainingRequest getTrainingDataRequest) async {
    return {"": ""};
    // return _firestoreService.getTrainingData(getTrainingDataRequest);
  }

  @override
  Future<List> getMatches(String traineeId) {
    return _firestoreService.getMatches(traineeId);
  }
}
