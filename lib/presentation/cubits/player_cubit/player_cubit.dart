import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/player_model/player_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final RepoImplementation repo;

  PlayerCubit(this.repo) : super(PlayerInitial());

  Future<void> fetchPlayer() async {
    emit(PlayerLoading());

    final result = await repo.fetchPlayers();

    result.fold(
      (failure) => {
        log(failure.message, name: 'PlayerCubit Error'),
        emit(PlayerFailure(failure.message))
      },
      (player) => {
        log(player.toString(), name: 'PlayerCubit Success'),
        emit(PlayerSuccess(player))
      },
    );
  }
}
