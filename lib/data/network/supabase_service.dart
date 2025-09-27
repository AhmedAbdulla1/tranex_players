import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/requests.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppPreferences _appPreferences = instance<AppPreferences>();
  String? getPlayerId() {
    final playerId = _supabase.auth.currentUser?.id;
    if (playerId != null) {
      return playerId;
    } else {
      Exception("No player id in supabase service");
    }
  }

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

      // حفظ في Supabase
      await supabase.from('training').insert({
        'coach_id': getPlayerId(),
        'player_id': addTrainingRequest.traineeId,
        'exercise_id': addTrainingRequest.exerciseId,
        'training_details': trainingDetails,
      });
    } catch (e, stackTrace) {
      // تسجيل الخطأ في وحدة التحكم للتطوير
      print('Error saving training data: $e');

      // تسجيل الخطأ في Sentry
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'context': 'Failed to save training data to Supabase',
          'training_request': {
            'traineeId': addTrainingRequest.traineeId,
            'exerciseId': addTrainingRequest.exerciseId,
            'trainingDetails': {
              'weight': addTrainingRequest.data.weight,
              'eccForce': addTrainingRequest.data.eccForce,
              'conForce': addTrainingRequest.data.conForce,
              'avgEccSpeed': addTrainingRequest.data.avgEccSpeed,
              'avgConSpeed': addTrainingRequest.data.avgConSpeed,
              'maxEccSpeed': addTrainingRequest.data.maxEccSpeed,
              'maxConSpeed': addTrainingRequest.data.maxConSpeed,
            },
          },
          'error_time': DateTime.now().toIso8601String(),
        }),
      );

      // رمي الخطأ مرة أخرى للسماح للطبقات العليا بمعالجته (اختياري)
      rethrow;
    }
  }

  Future<void> saveFencingTraining(
      SaveTrainingFencingRequest trainingData) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('training').insert({
        'player_id': trainingData.traineeId,
        'coach_id': getPlayerId(),
        // Set to actual coach_id if available
        'exercise_id': trainingData.exerciseId,
        // Set to actual exercise_id if available
        'training_details': trainingData.trainingData.toJson(),
      });

      debugPrint(
          'Training session saved successfully: ${trainingData.trainingData.toJson()}');
    } catch (e, stackTrace) {
      debugPrint('Error saving training session: $e');
      debugPrintStack(stackTrace: stackTrace, label: 'Save training error');
      throw Exception('Failed to save training session: $e');
    }
  }

  // Future<void> addTrainingData(AddTrainingRequest addTrainingRequest) async {
  //   try {
  //     if (addTrainingRequest.traineeId.isEmpty) {
  //       throw Exception('Trainee ID is invalid.');
  //     }
  //     if (addTrainingRequest.exerciseId == 0) {
  //       throw Exception('Exercise ID is invalid.');
  //     }
  //
  //     final trainingRef = _supabase
  //         .from('TrainingRecords')
  //         .select()
  //         .eq('trainee_id', addTrainingRequest.traineeId)
  //         .eq('exercise_id', addTrainingRequest.exerciseId);
  //     final trainingSnapshot = await trainingRef.single();
  //
  //     if (trainingSnapshot.isEmpty) {
  //       await _supabase.from('TrainingRecords').insert({
  //         'trainee_id': addTrainingRequest.traineeId,
  //         'exercise_id': addTrainingRequest.exerciseId,
  //         // 'name': addTrainingRequest.exerciseName,
  //         // 'image': addTrainingRequest.exerciseImage,
  //       });
  //     }
  //
  //     await _supabase.from('TrainingRecordsData').insert({
  //       'trainee_id': addTrainingRequest.traineeId,
  //       'exercise_id': addTrainingRequest.exerciseId,
  //       'num_of_sets': addTrainingRequest.data.numOfSets,
  //       // 'eccentric_speed': addTrainingRequest.data.eccentricSpeed,
  //       // 'concentric_speed': addTrainingRequest.data.concentricSpeed,
  //       // 'eccentric_acc': addTrainingRequest.data.eccentricAcc,
  //       // 'concentric_acc': addTrainingRequest.data.concentricAcc,
  //       // 'avg_ecc_speed': addTrainingRequest.data.avgEccSpeed,
  //       // 'avg_con_speed': addTrainingRequest.data.avgConSpeed,
  //       // 'avg_ecc_acc': addTrainingRequest.data.avgEccAcc,
  //       // 'avg_con_acc': addTrainingRequest.data.avgConAcc,
  //       // 'max_ecc_speed': addTrainingRequest.data.maxEccSpeed,
  //       // 'max_con_speed': addTrainingRequest.data.maxConSpeed,
  //       // 'max_ecc_acc': addTrainingRequest.data.maxEccAcc,
  //       // 'max_con_acc': addTrainingRequest.data.maxConAcc,
  //       'weight': addTrainingRequest.data.weight,
  //       'time_by_seconds': addTrainingRequest.data.timeBySeconds,
  //       'date': DateTime.now().toIso8601String(),
  //     });
  //
  //     debugPrint('Training added successfully.');
  //   } catch (e) {
  //     debugPrint('Failed to add training: $e');
  //     throw Exception('Failed to add training: $e');
  //   }
  // }

  // Future<void> addPlayerTraining(PlayerTrainingRequest trainingRequest) async {
  //   try {
  //     final sessionResponse = await _supabase
  //         .from('TrainingSessions')
  //         .insert({
  //           'player_id': trainingRequest.playerId,
  //           'coach_id': trainingRequest.coachId,
  //           'exercise_id': trainingRequest.exerciseId,
  //           'start_time': DateTime.now().toIso8601String(),
  //           'duration_ms': trainingRequest.durationMs,
  //         })
  //         .select('session_id')
  //         .single();
  //
  //     final sessionId = sessionResponse['session_id'];
  //
  //     final trainingData = trainingRequest.trainingData
  //         .map((data) => {
  //               'session_id': sessionId,
  //               'time_in_ms': data.timeInMs,
  //               'speed': data.speed,
  //               'direction': data.direction,
  //             })
  //         .toList();
  //
  //     await _supabase.from('TrainingData').insert(trainingData);
  //
  //     debugPrint('Player training added successfully.');
  //   } catch (e) {
  //     debugPrint('Failed to add player training: $e');
  //     throw Exception('Failed to add player training: $e');
  //   }
  // }

  Future<void> addMatch(MatchRequest matchRequest) async {
    try {
      if (matchRequest.player1Id == matchRequest.player2Id) {
        throw Exception('Player 1 and Player 2 cannot be the same.');
      }

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

      String? winnerId;
      if (matchRequest.player1PointRecords.length >
          matchRequest.player2PointRecords.length) {
        winnerId = matchRequest.player1Id;
      } else if (matchRequest.player1PointRecords.length <
          matchRequest.player2PointRecords.length) {
        winnerId = matchRequest.player2Id;
      } else {
        winnerId = null;
      }

      final matchResponse = await _supabase
          .from('matches')
          .insert({
            'player1_id': matchRequest.player1Id,
            'player2_id': matchRequest.player2Id,
            'coach_id': getPlayerId(),
            'start_time': DateTime.now().toIso8601String(),
            'duration_ms': matchRequest.durationMs,
            'winner_id': winnerId,
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
        await _supabase.rpc('get_matches_by_coach_and_player', params: {
      'player_uid': traineeId,
      'coach_uid': getPlayerId(),
    });

    if (response == null) {
      log('No matches found for trainee ID: $traineeId');
      return [];
    }
    log(response.toString());
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<String> addExercise(
      AddNewExerciseRequest addNewExerciseRequest) async {
    try {
      int categoryId;
      final playerId = _supabase.auth.currentUser!.id;

      if (coachId == 0) {
        throw Exception('No coach ID available. Please log in again.');
      }

      // Check if the category is new or existing
      if (addNewExerciseRequest.categoryId == 0) {
        // Create a new category
        final categoryResponse = await _supabase
            .from('categories')
            .insert({
              'coach_uid': playerId,
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
            'coach_uid': getPlayerId(),
            'name': addNewExerciseRequest.exerciseName,
            'image_url': addNewExerciseRequest.image,
            'device_id': addNewExerciseRequest.deviceId,
            'category': addNewExerciseRequest.categoryName,
            'category_id': categoryId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('exercise_id')
          .single();

      return categoryId.toString();
    } catch (e) {
      debugPrint('Failed to add exercise: $e');
      throw Exception('Failed to add exercise: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      final playerId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('categories')
          .select(
              'category_id, name, exercises(exercise_id, name, image_url, device_id)')
          .eq('coach_uid', playerId);

      return response;
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      rethrow;
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
      final response = await _supabase.rpc<List<Map<String, dynamic>>>(
          'get_athletes_for_coach',
          params: {"p_coach_id": _appPreferences.getUid()});
      log('uid ${_appPreferences.getUid()}', name: 'uid in get trainees ');
      log('run type type ${response.runtimeType}',
          name: 'run time type in get trainees ');
      log('player $response ', name: 'get_trainees in supabase');
      return response;
    } catch (e, stack) {
      debugPrint('Error fetching trainees: $e , $stack');
      return [];
    }
  }

  Future<Map<String, dynamic>> checkTraineeExistence(String traineeId) async {
    try {
      final response = await _supabase
          .from('players')
          .select()
          .eq('trainee_id', traineeId)
          .maybeSingle(); // بيرجع null لو مفيش صف

      if (response != null) {
        final data = response;
        data['exist'] = true;

        // نحسب is_active ديناميكيًا
        final activationDateStr = data['activation_date'] as String?;
        bool isActive = false;

        if (activationDateStr != null) {
          final activationDate = DateTime.parse(activationDateStr);
          final now = DateTime.now();
          final difference = now.difference(activationDate);

          // التفعيل لمدة سنة = 365 يوم (أو 1 سنة)
          if (difference.inDays < 365) {
            isActive = true;
          }
        }

        data['is_active'] = isActive;

        // تسجيل اللاعب في جدول المدربين
        await _supabase.from('coachplayers').upsert({
          'coach_id': getPlayerId,
          'player_id': data['player_id'],
        });

        return data;
      }

      return {'exist': false, 'is_active': false};
    } catch (e) {
      debugPrint('Error checking trainee: $e');
      return {'exist': false, 'is_active': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getLastTrainingData(
      GetTrainingRequest getTrainingDataRequest) async {
    try {
      final response = await _supabase
          .from('training')
          .select('training_details,created_at')
          .eq('player_id', getTrainingDataRequest.traineeId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final data = response.first;
        return data;
      }
      return {'empty': true};
    } catch (e) {
      print('Error checking trainee: $e');
      return {'exist': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTrainingData(
      GetTrainingRequest request) async {
    try {
      final supabase = Supabase.instance.client;

      // تحديد تاريخ البداية بناءً على الفترة المطلوبة
      final now = DateTime.now();
      final startDate = request.weakly
          ? now.subtract(const Duration(days: 28)) // آخر 4 أسابيع (28 يومًا)
          : now.subtract(const Duration(days: 120)); // آخر 4 شهور (~120 يومًا)

      // بناء الاستعلام مع شرط لاسترجاع الداتا من startDate وما بعد فقط
      var query = supabase
          .from('training')
          .select('training_details, created_at, exercise_id')
          .eq('player_uid', request.traineeId)
          .eq('exercise_id', request.exerciseId)
          .gte('created_at',
              startDate.toIso8601String()) // يضمن عدم استرجاع داتا أقدم
          .order('created_at', ascending: false);

      // تنفيذ الاستعلام
      final response = await query;

      // معالجة الاستجابة
      if (response.isNotEmpty) {
        // تحويل الداتا إلى قائمة من الخرائط
        final data = response.map((item) {
          // تحقق إضافي للتأكد من أن created_at ضمن الفترة
          final createdAt = DateTime.parse(item['created_at']);
          if (createdAt.isBefore(startDate)) {
            // هذا لن يحدث بسبب gte، لكن كإجراء احترازي
            throw Exception('Retrieved data older than specified period');
          }
          return {
            'training_details': item['training_details'],
            'created_at': item['created_at'],
            'exercise_id': item['exercise_id'],
          };
        }).toList();

        return {'data': data};
      }
      log('No data returned from Supabase.');
      return {'empty': true};
    } catch (e) {
      log('Error fetching training data: $e');
      return {'exist': false, 'error': e.toString()};
    }
  }
}
