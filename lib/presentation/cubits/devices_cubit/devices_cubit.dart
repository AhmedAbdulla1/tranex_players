import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/device_model/device_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final RepoImplementation repo;

  DevicesCubit(this.repo) : super(DevicesInitial());

  Future<void> fetchDevices() async {
    emit(DevicesLoading());

    final result = await repo.fetchDevices();

    result.fold(
      (failure) => {
        log(failure.message, name: 'DevicesCubit Error'),
        emit(DevicesFailure(failure.message))
      },
      (devices) => {
        log(devices.toString(), name: 'DevicesCubit Success'),
        emit(DevicesSuccess(devices))
      },
    );
  }
}
