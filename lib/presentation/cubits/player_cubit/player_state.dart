part of 'player_cubit.dart';

abstract class PlayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerSuccess extends PlayerState {
  final List<PlayerModel> player;

  PlayerSuccess(this.player);

  @override
  List<Object?> get props => [player];
}

class PlayerFailure extends PlayerState {
  final String message;

  PlayerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
