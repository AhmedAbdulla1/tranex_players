import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/training_model/training_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final RepoImplementation repo;

  TrainingCubit(this.repo) : super(TrainingInitial());

  Future<void> fetchTraining() async {
    emit(TrainingLoading());

    final result = await repo.fetchTraining();

    result.fold(
      (failure) => {
        log(failure.message, name: 'Training Error'),
        emit(TrainingFailure(failure.message))
      },
      (training) => {
        log(training.toString(), name: 'TrainingCubit Success'),
        emit(TrainingSuccess(training))
      },
    );
  }
}
