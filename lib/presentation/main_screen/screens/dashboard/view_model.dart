import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/models/fitness_training_enttity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/models/training_entity.dart';
import 'package:tranex_users/domain/usecase/training_data_usecase.dart';
import 'package:tranex_users/domain/usecase/user_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';

class DashboardViewModel extends DashboardViewModelOutput {
  final StreamController<User> _streamController = BehaviorSubject<User>();
  final StreamController<String> _exerciseStreamController =
      BehaviorSubject<String>();
  final StreamController<bool> _trainingButtonController =
      BehaviorSubject<bool>();
  final StreamController<bool> _progressButtonController =
      BehaviorSubject<bool>();
  final StreamController<TraineeData> _trainerController =
      BehaviorSubject<TraineeData>();
  final StreamController<Tuple<List<double>, List<double>>>
      _trainerDataController =
      BehaviorSubject<Tuple<List<double>, List<double>>>();
  final StreamController<AllTrainingsEntity> _repsController =
      BehaviorSubject<AllTrainingsEntity>();
  final StreamController<bool> _getTraineeDataController =
      BehaviorSubject<bool>();
  String? teamId;
  int? exerciseId;
  final UserUsecase _userUsecase;
  bool getTraineeData = false;

  DashboardViewModel(this._userUsecase);

  @override
  void start() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.fullScreenLoadingState,
      ),
    );
    setTrainingButton(true);
    setProgressButton(true);
    _userUsecase.getUser().fold((failure) {
      if (failure.message == AppStrings.noInternetError) {
      } else {
        inputState.add(
          ErrorState(
              stateRenderType: StateRenderType.fullScreenErrorState,
              message: failure.message,
              retryAction: () {
                inputState.add(ContentState());
              }),
        );
      }
    }, (data) async {
      inputDashboard.add(data);
      inputState.add(
        ContentState(),
      );
    });
  }

  @override
  Sink get inputDashboard => _streamController.sink;

  @override
  Stream<User> get outputDashboard => _streamController.stream;

  @override
  Sink get inputTrainingButton => _trainingButtonController.sink;

  @override
  Stream<bool> get outputTrainingButton => _trainingButtonController.stream;

  @override
  setTrainingButton(bool value) {
    inputTrainingButton.add(value);
  }

  @override
  Sink get inputProgressButton => _progressButtonController.sink;

  @override
  Stream<bool> get outputProgressButton => _progressButtonController.stream;

  @override
  setProgressButton(bool value) {
    inputProgressButton.add(value);
  }

  @override
  Sink<TraineeData> get inputTrainee => _trainerController.sink;

  @override
  Stream<TraineeData> get outTrainee => _trainerController.stream;

  setTrainee(TraineeData trainee) {
    _trainerController.add(trainee);
  }

  @override
  setExercise(ExerciseData exercise) {
    exerciseId = exercise.exerciseId;
    inputExercise.add(exercise.exerciseName);
  }

  @override
  Sink get inputExercise => _exerciseStreamController.sink;

  @override
  Stream<String> get outExercise => _exerciseStreamController.stream;

  @override
  Sink get inputTrainerData => _trainerDataController.sink;

  @override
  Stream<Tuple<List<double>, List<double>>> get outTrainerData =>
      _trainerDataController.stream;

  @override
  setTraineeData(TraineeData? trainee, {bool weekly = true}) async {
    TrainingUsecase useCase = TrainingUsecase();
    if (exerciseId != null && trainee != null) {
      inputGetTraineeData.add(true);
      Either<Failure, AllTrainingsEntity> trainingData =
          await useCase.getTrainingData(
        GetTrainingRequest(
          traineeId: trainee.traineeId,
          exerciseId: exerciseId!,
          weakly: weekly,
        ),
      );
      trainingData.fold((failure) {
        inputState.add(
          ErrorState(
              stateRenderType: StateRenderType.fullScreenErrorState,
              message: failure.message,
              retryAction: () {
                inputState.add(ContentState());
              }),
        );
        inputGetTraineeData.add(false);
      }, (data) {
        log('after fetching training data');
        // log("Data: ${data.allTrainings.()}");
        _repsController.add(data);
        Tuple<List<double>, List<double>> tuple = weekly
            ? calculateWeeklyAverage(
                data,
              )
            : calculateMonthlyAverage(
                data,
              );
        inputGetTraineeData.add(false);
        _trainerDataController.add(tuple);
      });
    }
  }

  double _calculateListAverage(List<double> list) {
    if (list.isEmpty) return 0.0;
    return list.reduce((a, b) => a + b) / list.length;
  }

  Tuple<List<double>, List<double>> calculateWeeklyAverage(
      AllTrainingsEntity dataList) {
    List<double> weekAverageDrafting = [0.0, 0.0, 0.0, 0.0, 0.0];
    List<double> weekAverageDistress = [0.0, 0.0, 0.0, 0.0, 0.0];

    // try {
    if (dataList.allTrainings.isEmpty) {
      log("Data list is empty, returning default averages.",
          name: 'WeeklyAverage');
      return Tuple(weekAverageDrafting, weekAverageDistress);
    }

    final today = DateTime.now();
    log("Calculating weeks starting from: $today", name: 'WeeklyAverage');

    List<List<double>> weeklyDraftingSums = [[], [], [], [], []];
    List<List<double>> weeklyDistressSums = [[], [], [], [], []];

    for (TrainingEntity data in dataList.allTrainings) {
      DateTime date = data.createdAt;
      int daysSinceToday = today.difference(date).inDays;

      int weekIndex = daysSinceToday ~/ 7;
      if (weekIndex >= 5) continue;

      if (data.trainingDetails is FitnessTrainingDetails) {
        FitnessTrainingDetails fitneesData =
            data.trainingDetails as FitnessTrainingDetails;
        double draftingAvg = _calculateListAverage(fitneesData.eccForce);
        double distressAvg = _calculateListAverage(fitneesData.conForce);
        weeklyDraftingSums[weekIndex].add(draftingAvg);
        weeklyDistressSums[weekIndex].add(distressAvg);
        log(
          "Date: $date, Week: $weekIndex, Drafting: $draftingAvg, Distress: $distressAvg",
          name: 'WeeklyAverage',
        );
      }
    }

    for (int i = 0; i < 5; i++) {
      if (weeklyDraftingSums[i].isNotEmpty) {
        double draftingAvg = _calculateListAverage(weeklyDraftingSums[i]);
        double distressAvg = _calculateListAverage(weeklyDistressSums[i]);
        weekAverageDrafting[i] = double.parse(draftingAvg.toStringAsFixed(2));
        weekAverageDistress[i] = double.parse(distressAvg.toStringAsFixed(2));
        log(
          "Week $i Average Drafting: ${weekAverageDrafting[i]}, Distress: ${weekAverageDistress[i]}",
          name: 'WeeklyAverage',
        );
      }
    }

    log(
      "Final Weekly Averages - Drafting: $weekAverageDrafting, Distress: $weekAverageDistress",
      name: 'WeeklyAverage',
    );

    return Tuple(weekAverageDrafting, weekAverageDistress);
    // } catch (e, stackTrace) {
    //  log("Error calculating weekly averages: $e", name: 'WeeklyAverage');
    //   return Tuple(weekAverageDrafting, weekAverageDistress);
    // }
  }

  Tuple<List<double>, List<double>> calculateMonthlyAverage(
      AllTrainingsEntity dataList) {
    List<double> monthAverageDrafting = [0.0, 0.0, 0.0, 0.0];
    List<double> monthAverageDistress = [0.0, 0.0, 0.0, 0.0];

    try {
      if (dataList.allTrainings.isEmpty) {
        log("Data list is empty, returning default averages.",
            name: 'MonthlyAverage');
        return Tuple(monthAverageDrafting, monthAverageDistress);
      }

      // Sort data by date (newest to oldest)
      dataList.allTrainings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      int monthIndex = 0;
      Map<String, List<double>> monthlyDraftingSums = {};
      Map<String, List<double>> monthlyDistressSums = {};

      for (TrainingEntity data in dataList.allTrainings) {
        DateTime date = data.createdAt;
        String monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}'; // Ensure month is two digits
        log("Processing data for date: $date, Month: $monthKey",
            name: 'MonthlyAverage');
        if (data.trainingDetails is FitnessTrainingDetails) {
          FitnessTrainingDetails fitneesData =
              data.trainingDetails as FitnessTrainingDetails;
          // Calculate averages for this data point
          double draftingAvg = _calculateListAverage(fitneesData.eccForce);
          double distressAvg = _calculateListAverage(fitneesData.conForce);

          monthlyDraftingSums.putIfAbsent(monthKey, () => []).add(draftingAvg);
          monthlyDistressSums.putIfAbsent(monthKey, () => []).add(distressAvg);
        }
      }

      // Sort months by date (newest to oldest)
      var sortedMonths = monthlyDraftingSums.keys.toList()
        ..sort((a, b) =>
            DateTime.parse('$b-01').compareTo(DateTime.parse('$a-01')));
      for (int i = 0; i < sortedMonths.length && i < 4; i++) {
        String month = sortedMonths[i];
        double draftingAvg = _calculateListAverage(monthlyDraftingSums[month]!);
        double distressAvg = _calculateListAverage(monthlyDistressSums[month]!);
        monthAverageDrafting[i] = double.parse(draftingAvg.toStringAsFixed(2));
        monthAverageDistress[i] = double.parse(distressAvg.toStringAsFixed(2));
        log(
          "Month $i ($month) Average Drafting: ${monthAverageDrafting[i]}, Distress: ${monthAverageDistress[i]}",
          name: 'MonthlyAverage',
        );
      }

      log(
        "Final Monthly Averages - Drafting: $monthAverageDrafting, Distress: $monthAverageDistress",
        name: 'MonthlyAverage',
      );

      return Tuple(monthAverageDrafting, monthAverageDistress);
    } catch (e, stackTrace) {
      log("Error calculating monthly averages: $e\n$stackTrace",
          name: 'MonthlyAverage');
      return Tuple(monthAverageDrafting, monthAverageDistress);
    }
  }

  @override
  Sink get inputRepsData => _repsController.sink;

  @override
  Stream<AllTrainingsEntity> get outputRepsData => _repsController.stream;

  @override
  Sink get inputGetTraineeData => _getTraineeDataController.sink;

  @override
  Stream<bool> get outGetTraineeData => _getTraineeDataController.stream;
}

abstract class DashboardViewModelInput extends BaseViewModel {
  setTrainingButton(bool value);

  setProgressButton(bool value);

  setExercise(ExerciseData exercise);

  setTraineeData(TraineeData trainee);

  Sink get inputDashboard;

  Sink get inputTrainingButton;

  Sink get inputProgressButton;

  Sink<TraineeData> get inputTrainee;

  Sink get inputExercise;

  Sink get inputTrainerData;

  Sink get inputRepsData;

  Sink get inputGetTraineeData;
}

abstract class DashboardViewModelOutput extends DashboardViewModelInput {
  Stream<User> get outputDashboard;

  Stream<bool> get outputTrainingButton;

  Stream<bool> get outputProgressButton;

  Stream<TraineeData> get outTrainee;

  Stream<String> get outExercise;

  Stream<Tuple<List<double>, List<double>>> get outTrainerData;

  Stream<AllTrainingsEntity> get outputRepsData;

  Stream<bool> get outGetTraineeData;
}

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);
}
