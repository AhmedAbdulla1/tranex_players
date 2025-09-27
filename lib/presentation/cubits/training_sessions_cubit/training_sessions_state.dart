part of 'training_sessions_cubit.dart';

abstract class TrainingSessionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrainingSessionsInitial extends TrainingSessionsState {}

class TrainingSessionsLoading extends TrainingSessionsState {}

class TrainingSessionsSuccess extends TrainingSessionsState {
  final List<TrainingSeesionModel> trainingSessions;

  TrainingSessionsSuccess(this.trainingSessions);

  @override
  List<Object?> get props => [trainingSessions];
}

class TrainingSessionsFailure extends TrainingSessionsState {
  final String message;

  TrainingSessionsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
