import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tranex_users/data/models/categories_model/category_model.dart';
import 'package:tranex_users/data/repo/repo_implementation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final RepoImplementation repo;

  CategoriesCubit(this.repo) : super(CategoriesInitial());

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());

    final result = await repo.fetchCategories();

    result.fold(
      (failure) => {
        log(failure.message, name: 'CategoriesCubit Error'),
        emit(CategoriesFailure(failure.message))
      },
      (categories) => {
        log(categories.toString(), name: 'CategoriesCubit Success'),
        emit(CategoriesSuccess(categories))
      },
    );
  }
}
