import 'dart:convert';
import 'dart:developer';
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppPreferences _appPreferences = instance<AppPreferences>();

  Future<void> saveTrainingData(AddTrainingRequest addTrainingRequest) async {
    try {
      final supabase = Supabase.instance.client;
      final trainingDetails = {
        'W': addTrainingRequest.data.weight,
        'EF': addTrainingRequest.data.eccForce,
        'CF': addTrainingRequest.data.conForce,
        'AES': addTrainingRequest.data.avgEccSpeed,
        'ACS': addTrainingRequest.data.avgConSpeed,
        'MES': addTrainingRequest.data.maxEccSpeed,
        'MCS': addTrainingRequest.data.maxConSpeed,
      };
      int userId = _appPreferences.getUserId();
      // حفظ في Supabase
      await supabase.from('training').insert({
        'coach_id': userId,
        'player_id': userId,
        'exercise_id': addTrainingRequest.exerciseId,
        'training_details': trainingDetails,
      });
    } catch (e) {
      print('Error saving training data: $e');
      rethrow;
    }
  }

  Future<void> addPlayerTraining(PlayerTrainingRequest trainingRequest) async {
    try {
      // ????? ???? ??????? ?? TrainingSessions
      final sessionResponse = await _supabase
          .from('TrainingSessions')
          .insert({
            'player_id': trainingRequest.playerId,
            'coach_id': trainingRequest.coachId,
            'exercise_id': trainingRequest.exerciseId,
            'start_time': DateTime.now().toIso8601String(),
            'duration_ms': trainingRequest.durationMs,
          })
          .select('session_id')
          .single();

      final sessionId = sessionResponse['session_id'];

      // ????? ?????? ?????? ?? TrainingData
      final trainingData = trainingRequest.trainingData
          .map((data) => {
                'session_id': sessionId,
                'time_in_ms': data.timeInMs,
                'speed': data.speed,
                'direction': data.direction,
              })
          .toList();

      await _supabase.from('TrainingData').insert(trainingData);

      debugPrint('Player training added successfully.');
    } catch (e) {
      debugPrint('Failed to add player training: $e');
      throw Exception('Failed to add player training: $e');
    }
  }

  Future<void> addMatch(MatchRequest matchRequest) async {
    try {
      // التحقق من إن player1_id و player2_id مختلفين
      if (matchRequest.player1Id == matchRequest.player2Id) {
        throw Exception('Player 1 and Player 2 cannot be the same.');
      }

      // جمع تفاصيل Player 1 (matchData + pointRecords) كـ JSON
      final player1Details = <Map<String, dynamic>>[];
      for (var data in matchRequest.player1MatchData) {
        player1Details.add({
          'T': data.timeInMs,
          'S': data.speed,
          'D': data.direction,
        });
      }
      final player1Points = <Map<String, dynamic>>[];
      for (var point in matchRequest.player1PointRecords) {
        player1Points.add({
          "S": point.speed,
          'T': point.timeInMs,
        });
      }

      // جمع تفاصيل Player 2 (matchData + pointRecords) كـ JSON
      final player2Details = <Map<String, dynamic>>[];
      for (var data in matchRequest.player2MatchData) {
        player2Details.add({
          'T': data.timeInMs,
          'S': data.speed,
          'D': data.direction,
        });
      }
      final player2Points = <Map<String, dynamic>>[];
      for (var point in matchRequest.player2PointRecords) {
        player2Points.add({
          'S': point.speed,
          'T': point.timeInMs,
        });
      }

      // تحديد winner_id مع التعامل مع التعادل
      int? winnerId;
      if (matchRequest.player1PointRecords.length >
          matchRequest.player2PointRecords.length) {
        winnerId = matchRequest.player1Id;
      } else if (matchRequest.player1PointRecords.length <
          matchRequest.player2PointRecords.length) {
        winnerId = matchRequest.player2Id;
      } else {
        winnerId = null;
      }

      // إضافة الماتش مع التفاصيل في جدول matches
      final matchResponse = await _supabase
          .from('matches')
          .insert({
            'player1_id': matchRequest.player1Id,
            'player2_id': matchRequest.player2Id,
            'coach_id': _appPreferences.getUserId(),
            'start_time': DateTime.now().toIso8601String(),
            'duration_ms': matchRequest.durationMs,
            'winner_id': winnerId, // ممكن NULL في حالة التعادل
            'player1_points': player1Points,
            'player2_points': player2Points,
            'player1_details': player1Details,
            'player2_details': player2Details,
          })
          .select('match_id')
          .single();

      final matchId = matchResponse['match_id'] as int;
      debugPrint('Match added successfully with ID: $matchId');
    } catch (e) {
      debugPrint('Failed to add match: $e');
      throw Exception('Failed to add match: $e');
    }
  }

  Future<List<dynamic>> getMatches(String traineeId) async {
    final response =
        await _supabase.rpc('get_match_details_for_player', params: {
      'player_id': int.parse(traineeId),
      'coach_id': _appPreferences.getUserId(),
    });

    if (response == null) {
      throw Exception('No data returned from Supabase function.');
    }
    log(response.toString());
    // The function returns a JSONB array, so cast it properly
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<String> addExercise(
      AddNewExerciseRequest addNewExerciseRequest) async {
    try {
      int categoryId;
      final coachId = _appPreferences.getUserId(); // coach_id العادي (Integer)

      if (coachId == 0) {
        throw Exception('No coach ID available. Please log in again.');
      }

      // Check if the category is new or existing
      if (addNewExerciseRequest.categoryId == 0) {
        // Create a new category
        final categoryResponse = await _supabase
            .from('categories')
            .insert({
              'coach_id': coachId, // استخدمنا coach_id مباشرة
              'name': addNewExerciseRequest.categoryName,
            })
            .select('category_id')
            .single();
        categoryId = categoryResponse['category_id'];
        debugPrint('Created new category: $categoryId');
      } else {
        // Use the existing category ID
        categoryId = addNewExerciseRequest.categoryId;
        final categorySnapshot = await _supabase
            .from('categories')
            .select()
            .eq('category_id', categoryId)
            .single();

        if (categorySnapshot.isEmpty) {
          throw Exception('Category does not exist.');
        }
      }

      // Add the exercise to the Exercises table with the category_id
      await _supabase
          .from('exercises')
          .insert({
            'coach_id': coachId, // استخدمنا coach_id مباشرة
            'name': addNewExerciseRequest.exerciseName,
            'image_url': addNewExerciseRequest.image,
            'device_id': addNewExerciseRequest.deviceId,
            'category': addNewExerciseRequest.categoryName,
            'category_id': categoryId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('exercise_id')
          .single();

      return categoryId
          .toString(); // أو exerciseResponse['exercise_id'].toString() لو عايز
    } catch (e) {
      debugPrint('Failed to add exercise: $e');
      throw Exception('Failed to add exercise: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      final coachId = _appPreferences.getUserId(); // جلب coach_id
      if (coachId == null) {
        throw Exception('No coach ID available.');
      }

      // جلب الـ Categories مع الـ Exercises المرتبطة بيها
      final response = await _supabase
          .from('categories')
          .select(
              'category_id, name, exercises(exercise_id, name, image_url, device_id)')
          .eq('coach_id', coachId); // فلترة بناءً على coach_id

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      rethrow; // إعادة رمي الخطأ للتعامل معه في الـ Repository
    }
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final response = await _supabase.from('devices').select(
          'device_id, name, accessories(accessory_id, accessory_name, min, max, interval, weight)');
      return response;
    } catch (e) {
      debugPrint('Error fetching devices: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrainees() async {
    try {
      final response = await _supabase
          .from('coachplayers')
          .select('players(*)')
          .eq('coach_id', _appPreferences.getUserId());
      return response
          .map((item) => item['players'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error fetching trainees: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId) async {
    try {
      final response = await _supabase
          .from('players')
          .select()
          .eq('trainee_id', traineeId)
          .single();

      if (response.isNotEmpty) {
        final data = response;
        data['exist'] = true;
        _appPreferences.setUserId(data['player_id']);
        _appPreferences.setUser(jsonEncode(data));
        return data;
      }
      return {'exist': false};
    } catch (e) {
      debugPrint('Error checking trainee: $e');
      return {'exist': false, 'error': e.toString()};
    }
  }
}
