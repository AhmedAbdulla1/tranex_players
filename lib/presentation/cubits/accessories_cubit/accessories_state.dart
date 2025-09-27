part of 'accessories_cubit.dart';

class AccessoriesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccessoriesInitial extends AccessoriesState {}

class AccessoriesLoading extends AccessoriesState {}

class AccessoriesSuccess extends AccessoriesState {
  final List<AccessoriesModel> accessories;

  AccessoriesSuccess(this.accessories);

  @override
  List<Object?> get props => [accessories];
}

class AccessoriesFailure extends AccessoriesState {
  final String message;

  AccessoriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
