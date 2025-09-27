part of 'exercises_cubit.dart';

abstract class ExercisesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExercisesInitial extends ExercisesState {}

class ExercisesLoading extends ExercisesState {}

class ExercisesSuccess extends ExercisesState {
  final List<ExerciseModel> exercises;

  ExercisesSuccess(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

class ExercisesFailure extends ExercisesState {
  final String message;

  ExercisesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
