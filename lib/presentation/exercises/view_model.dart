import 'dart:async';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/usecase/exercise_usecase.dart';
import 'package:firesport_users/presentation/base/base_view_model.dart';
import 'package:firesport_users/presentation/common/state_render/state_render.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:rxdart/rxdart.dart';

class ExercisesViewModel extends ExercisesViewModelOutput {
  final StreamController<String> _searchStreamController =
      BehaviorSubject<String>();
  final StreamController<List<CategoryData>> _filteredMapStreamController =
      BehaviorSubject<List<CategoryData>>();

  final ExerciseUsecase _useCase = instance<ExerciseUsecase>();
  List<CategoryData> filteredMap = [];
  List<CategoryData> exercisesData = [];

  @override
  void start() {
    // debugPrint(Constant.exercisesData);
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    getExercises();
  }

  Future getExercises() async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    (await _useCase.getExercises()).fold((l) {
      inputState.add(ErrorState(
          stateRenderType: StateRenderType.fullScreenErrorState,
          message: l.message,
          retryAction: () {
            inputState.add(ContentState());
          }));
    }, (r) {
      exercisesData = r;
      filteredMap = exercisesData;
      if (r.isEmpty) {
        inputState.add(EmptyState(message: 'لا يوجد تمارين حتي الأن'));
      } else {
        inputFilteredMap.add(filteredMap);
        inputState.add(ContentState());
      }
    });
  }

  @override
  Sink get inputSearch => _searchStreamController.sink;

  @override
  Stream<String> get outputSearch => _searchStreamController.stream;

  @override
  void setSearch(String search) {
    if (search.isNotEmpty) {
      // Create a temporary list to store the filtered results
      List<CategoryData> tempFilteredMap = [];

      for (var categoryData in exercisesData) {
        // Filter exercises based on the search query
        final List<ExerciseData> filteredValues = categoryData.exercises
            .where((item) =>
                item.exerciseName.toLowerCase().contains(search.toLowerCase()))
            .toList();

        if (filteredValues.isNotEmpty) {
          // If there are matching exercises, add a new category with the filtered exercises
          tempFilteredMap.add(
            CategoryData(
              categoryId: categoryData.categoryId,
              categoryName: categoryData.categoryName,
              exercises: filteredValues,
            ),
          );
        }
      }

      // Assign the filtered list to the main filtered map after completing the loop
      filteredMap = tempFilteredMap;
    } else {
      // If the search is empty, reset filteredMap to show all data
      filteredMap = exercisesData;
    }

    // Notify any listeners or update states
    inputFilteredMap.add(filteredMap);
  }

  @override
  Sink get inputFilteredMap => _filteredMapStreamController.sink;

  @override
  Stream<List<CategoryData>> get outFilteredMap =>
      _filteredMapStreamController.stream;

  @override
  delete(String key, ExerciseData value) {
    // Retrieve the list from the box
    // List<ExerciseObject> itemList = exercisesData.get(key, defaultValue: [])??[];
    // Remove the specified item from the list
    // itemList.remove(value);
    // Save the updated list back to the box
    // exercisesData.put(key, itemList);
    inputState.add(ContentState());
  }
}

abstract class ExercisesViewModelInput extends BaseViewModel {
  setSearch(String search);

  delete(String key, ExerciseData value);

  Sink get inputSearch;

  Sink get inputFilteredMap;
}

abstract class ExercisesViewModelOutput extends ExercisesViewModelInput {
  Stream<String> get outputSearch;

  Stream<List<CategoryData>> get outFilteredMap;
}
