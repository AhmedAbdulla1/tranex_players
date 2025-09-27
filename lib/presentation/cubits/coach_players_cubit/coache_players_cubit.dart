import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/coache_players_model/coach_players_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'coache_players_state.dart';

class CoachePlayersCubit extends Cubit<CoachePlayersState> {
  final RepoImplementation repo;

  CoachePlayersCubit(this.repo) : super(CoachePlayersInitial());

  Future<void> fetchCoachePlayers() async {
    emit(CoachePlayersLoading());

    final result = await repo.fetchCoachPlayers();

    result.fold(
      (failure) => {
        log(failure.message, name: 'CoachePlayers Error'),
        emit(CoachePlayersFailure(failure.message))
      },
      (coachePlayers) => {
        log(coachePlayers.toString(), name: 'CoachePlayers Success'),
        emit(CoachePlayersSuccess(coachePlayers)),
      },
    );
  }
}
