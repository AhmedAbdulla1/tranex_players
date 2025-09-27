import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/accessories_model/accessories_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'accessories_state.dart';

class AccessoriesCubit extends Cubit<AccessoriesState> {
  final RepoImplementation repo;

  AccessoriesCubit(this.repo) : super(AccessoriesInitial());

  Future<void> fetchAccessories() async {
    emit(AccessoriesLoading());

    final result = await repo.fetchAccessories();

    result.fold(
      (failure) => {
        log(failure.message, name: 'AccessoriesCubit Error'),
        emit(AccessoriesFailure(failure.message))
      },
      (accessories) => {
        log(accessories.toString(), name: 'AccessoriesCubit Success'),
        emit(AccessoriesSuccess(accessories))
      },
    );
  }
}
