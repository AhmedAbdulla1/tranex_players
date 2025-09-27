import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/coach_model/coach_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'coaches_state.dart';

class CoachesCubit extends Cubit<CoachesState> {
  final RepoImplementation repo;

  CoachesCubit(this.repo) : super(CoachesInitial());

  Future<void> fetchCoaches() async {
    emit(CoachesLoading());

    final result = await repo.fetchCoaches();

    result.fold(
      (failure) => {
        log(failure.message, name: 'CoachesCubit Error'),
        emit(CoachesFailure(failure.message))
      },
      (coaches) => {
        log(coaches.toString(), name: 'CoachesCubit Success'),
        emit(CoachesSuccess(coaches))
      },
    );
  }
}
