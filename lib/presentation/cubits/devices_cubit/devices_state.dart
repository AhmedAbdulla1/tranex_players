
part of 'devices_cubit.dart';



abstract class DevicesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DevicesInitial extends DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesSuccess extends DevicesState {
  final List<DeviceModel> devices;

  DevicesSuccess(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DevicesFailure extends DevicesState {
  final String message;

  DevicesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
