import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/training_seesion_model/training_seesion_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'training_sessions_state.dart';

class TrainingSessionsCubit extends Cubit<TrainingSessionsState> {
  final RepoImplementation repo;

  TrainingSessionsCubit(this.repo) : super(TrainingSessionsInitial());

  Future<void> fetchTrainingSessions() async {
    emit(TrainingSessionsLoading());

    final result = await repo.fetchTrainingSessions();

    result.fold(
      (failure) => {
        log(failure.message, name: 'TrainingSessions Error'),
        emit(TrainingSessionsFailure(failure.message))
      },
      (trainingSessions) => {
        log(trainingSessions.toString(), name: 'TrainingSessionsCubit Success'),
        emit(TrainingSessionsSuccess(trainingSessions))
      },
    );
  }
}
