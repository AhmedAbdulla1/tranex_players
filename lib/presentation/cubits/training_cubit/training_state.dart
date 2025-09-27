part of 'training_cubit.dart';

abstract class TrainingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingSuccess extends TrainingState {
  final List<TrainingModel> training;

  TrainingSuccess(this.training);

  @override
  List<Object?> get props => [training];
}

class TrainingFailure extends TrainingState {
  final String message;

  TrainingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
