import 'dart:async';
import 'dart:io';

import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';
import 'package:tranex_users/domain/usecase/matches_usecase.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:rxdart/rxdart.dart';

class MatchesViewModel extends MatchesViewModelOutput {
  final StreamController<String> _searchStreamController =
      BehaviorSubject<String>();
  final StreamController<MatchesEntity> _filteredDataStreamController =
      BehaviorSubject<MatchesEntity>();
  final StreamController<File> _addImageStreamController =
      BehaviorSubject<File>();
  final StreamController<String> _categoryStreamController =
      BehaviorSubject<String>();
  final StreamController<String> _exerciseNameStreamController =
      BehaviorSubject<String>();
  final MatchesUseCase _useCase =
      MatchesUseCase(instance<TraineesRepository>());
  late MatchesEntity originalMatches;
  late TraineeData traineeData;

  @override
  void start() {
    getMatches();
  }

  Future getMatches() async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    (await _useCase.execute(traineeData.traineeId.toString())).fold((l) {
      print(l.message);
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.fullScreenErrorState,
          message: l.message,
          retryAction: () {
            getMatches();
          }));
    }, (r) {
      originalMatches = r;
      if (r.matches.isEmpty) {
        inputState.add(EmptyState(message: 'No matches found'));
      } else {
        inputFilteredData.add(r);
        inputState.add(ContentState());
      }
    });
  }

  @override
  Sink get inputSearch => _searchStreamController.sink;

  @override
  Stream<String> get outputSearch => _searchStreamController.stream;

  @override
  Sink get inputFilteredData => _filteredDataStreamController.sink;

  @override
  Stream<MatchesEntity> get outFilteredData =>
      _filteredDataStreamController.stream;

  @override
  Sink get inputTeam => _categoryStreamController.sink;

  @override
  Sink get inputTrainee => _exerciseNameStreamController.sink;

  @override
  Sink get inputImage => _addImageStreamController.sink;

  @override
  Stream<File> get outAddImage => _addImageStreamController.stream;

  @override
  Stream<String> get outTeam => _categoryStreamController.stream;

  @override
  Stream<String> get outTraineeName => _exerciseNameStreamController.stream;

  @override
  setNewCategory(String name) {
    // traineeData.put(name, []);
  }

  @override
  setNewExercise(
    String category,
    String name,
  ) async {
    // List<String> traineeList =
    //     // traineeData.get(category, defaultValue: []) as List<String>;
    // traineeList.add(name);
    // traineeData.put(category, traineeList);
  }

  @override
  delete(String key, String value) {
    // Retrieve the list from the box
    // List<String> itemList = traineeData.get(key, defaultValue: []) ?? [];
    // Remove the specified item from the list
    // itemList.remove(value);
    // // Save the updated list back to the box
    // traineeData.put(key, itemList);
    inputState.add(ContentState());
  }
}

abstract class MatchesViewModelInput extends BaseViewModel {
  setNewCategory(String name);

  setNewExercise(String category, String name);

  delete(String key, String value);

  Sink get inputSearch;

  Sink get inputFilteredData;

  Sink get inputImage;

  Sink get inputTeam;

  Sink get inputTrainee;
}

abstract class MatchesViewModelOutput extends MatchesViewModelInput {
  Stream<String> get outputSearch;

  Stream<MatchesEntity> get outFilteredData;

  Stream<File> get outAddImage;

  Stream<String> get outTeam;

  Stream<String> get outTraineeName;
}
