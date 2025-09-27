part of 'training_data_cubit.dart';

abstract class TrainingDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrainingDataInitial extends TrainingDataState {}

class TrainingDataLoading extends TrainingDataState {}

class TrainingDataSuccess extends TrainingDataState {
  final List<TrainingDataModel> trainingData;

  TrainingDataSuccess(this.trainingData);

  @override
  List<Object?> get props => [trainingData];
}

class TrainingDataFailure extends TrainingDataState {
  final String message;

  TrainingDataFailure(this.message);

  @override
  List<Object?> get props => [message];
}
