import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/training_data_model/training_data_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'training_data_state.dart';

class TrainingDataCubit extends Cubit<TrainingDataState> {
  final RepoImplementation repo;

  TrainingDataCubit(this.repo) : super(TrainingDataInitial());

  Future<void> fetchTrainingData() async {
    emit(TrainingDataLoading());

    final result = await repo.fetchTrainingData();

    result.fold(
      (failure) => {
        log(failure.message, name: 'TrainingData Error'),
        emit(TrainingDataFailure(failure.message))
      },
      (trainingData) => {
        log(trainingData.toString(), name: 'TrainingDataCubit Success'),
        emit(TrainingDataSuccess(trainingData))
      },
    );
  }
}
