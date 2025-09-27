import 'dart:async';

import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/base/base_view_model.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';

import 'package:rxdart/rxdart.dart';

class AddNewTraineeViewModel extends AddNewTraineeInput {
  final StreamController<TeamData> _teamsStreamController =
      BehaviorSubject<TeamData>();
  final StreamController<String> _traineeNameStreamController =
      BehaviorSubject<String>();
  final StreamController<String> _teamNameStreamController =
      BehaviorSubject<String>();
  final StreamController<bool> _inputAreRight = BehaviorSubject<bool>();
  final StreamController<bool> _inputTraineeAreRight = BehaviorSubject<bool>();
  // final AddNewTraineeUseCase _useCase =
  //     AddNewTraineeUseCase(instance<Repository>());
  // Box<List<String>> teamsData = Hive.box<List<String>>(Constant.teams);
  String qrCode = '';

  @override
  Sink get inputTeams => _teamsStreamController.sink;

  @override
  Sink get inputTrainee => _teamsStreamController.sink;

  @override
  Stream<TeamData> get outputTeams => _teamsStreamController.stream;

  @override
  Stream<String?> get outputTrainee => _traineeNameStreamController.stream
      .map((event) => traineeNameIsValid(event));

  @override
  void start() {
    // inputState.add(
    //     LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    // getTeam();
  }

  // Future getTeam() async {
  //   debugPrint('object');
  //   (await _useCase.getTeams()).fold((l) {
  //     inputState.add(ErrorState(
  //         stateRenderType: StateRenderType.fullScreenErrorState,
  //         message: l.message));
  //   }, (r) {
  //     debugPrint(r);
  //     team= r;
  //     inputState.add(ContentState());
  //   });
  // }

  List<String> teamName() {
    List<String> teams = [];
    return teams;
  }

  String? teamNameIsValid(String teamname) {
    if (teamname.isEmpty) {
      return 'Team Name is Empty';
    } else if (teamName().contains(teamname)) {
      return 'Team is already Exits';
    }
    return null;
  }



  void setNewTrainee(String team) {
    _traineeNameStreamController.add(team);
    if (team.isNotEmpty) {
      _inputAreRight.add(true);
    } else {
      _inputAreRight.add(false);
    }
  }
  // void scanQR() async {
  //  qrCode= await FlutterBarcodeScanner.scanBarcode(
  //     '#ff6666',
  //     'Cancel',
  //     true,
  //     ScanMode.QR,
  //   );
  //   debugPrint({"barcodeScanRes: $qrCode"});
  // }

  Future addNewTrainee(String name) async {
    inputState.add(
        LoadingState(stateRenderType: StateRenderType.fullScreenLoadingState));
    // (await _useCase.execute(AddNewTraineeUseccaseInput(
    //         teamId: 'teamId', traineeName: name, teamName: 'team')))
    //     .fold(
    //   (l) {
    //     inputState.add(
    //       ErrorState(
    //           stateRenderType: StateRenderType.popupErrorState,
    //           message: l.message,retryAction: (){
    //             inputState.add(ContentState());
    //       } ),
    //     );
    //   },
    //   (r) {
    //     inputState.add(ContentState());
    //   },
    // );

  }

  String? traineeNameIsValid(String traineeName) {
    if (traineeName.isEmpty) {
      return 'Trainee Name Is Empty';
    } else {
      return null;
    }
  }

  @override
  Sink get inputTeamNameRight => _teamNameStreamController.sink;

  @override
  Stream<bool> get outputTeamNameRight => _inputAreRight.stream;

  @override
  Sink get inputTeamName => _teamNameStreamController.sink;

  @override
  Stream<String?> get outputTeamName =>
      _teamNameStreamController.stream.map((event) => teamNameIsValid(event));

  @override
  Sink get inputTraineeNameRight => _inputTraineeAreRight.sink;

  @override
  Stream<bool> get outputTraineeNameRight => _inputTraineeAreRight.stream;
}

abstract class AddNewTraineeInput extends AddNewTraineeOutput {
  Sink get inputTeams;

  Sink get inputTeamName;

  Sink get inputTrainee;

  Sink get inputTeamNameRight;

  Sink get inputTraineeNameRight;
}

abstract class AddNewTraineeOutput extends BaseViewModel {
  Stream<TeamData> get outputTeams;

  Stream<String?> get outputTeamName;

  Stream<String?> get outputTrainee;

  Stream<bool> get outputTeamNameRight;

  Stream<bool> get outputTraineeNameRight;
}
