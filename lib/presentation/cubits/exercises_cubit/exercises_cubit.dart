import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/exercise_model/exercise_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  final RepoImplementation repo;

  ExercisesCubit(this.repo) : super(ExercisesInitial());

  Future<void> fetchExercises() async {
    emit(ExercisesLoading());

    final result = await repo.fetchExercises();

    result.fold(
      (failure) => {
        log(failure.message, name: 'ExercisesCubit Error'),
        emit(ExercisesFailure(failure.message))
      },
      (exercises) => {
        log(exercises.toString(), name: 'ExercisesCubit Success'),
        emit(ExercisesSuccess(exercises))
      },
    );
  }
}
