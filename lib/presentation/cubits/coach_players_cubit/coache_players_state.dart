part of 'coache_players_cubit.dart';

abstract class CoachePlayersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoachePlayersInitial extends CoachePlayersState {}

class CoachePlayersLoading extends CoachePlayersState {}

class CoachePlayersSuccess extends CoachePlayersState {
  final List<CoachPlayersModel> coachePlayers;

  CoachePlayersSuccess(this.coachePlayers);

  @override
  List<Object?> get props => [coachePlayers];
}

class CoachePlayersFailure extends CoachePlayersState {
  final String message;

  CoachePlayersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
