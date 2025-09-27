part of 'coaches_cubit.dart';

abstract class CoachesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoachesInitial extends CoachesState {}

class CoachesLoading extends CoachesState {}

class CoachesSuccess extends CoachesState {
  final List<CoachModel> coaches;

  CoachesSuccess(this.coaches);

  @override
  List<Object?> get props => [coaches];
}

class CoachesFailure extends CoachesState {
  final String message;

  CoachesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
