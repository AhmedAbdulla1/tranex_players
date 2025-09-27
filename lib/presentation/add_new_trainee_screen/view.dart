import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/presentation/add_new_trainee_screen/view_model.dart';
import 'package:tranex_users/presentation/common/reusable/custom_button.dart';
import 'package:tranex_users/presentation/common/reusable/custom_text_form_field.dart';
import 'package:tranex_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNewTraineeView extends StatefulWidget {
  const AddNewTraineeView({Key? key}) : super(key: key);

  @override
  State<AddNewTraineeView> createState() => _AddNewTraineeViewState();
}

class _AddNewTraineeViewState extends State<AddNewTraineeView> {

  final TextEditingController _traineeController = TextEditingController();
  final AddNewTraineeViewModel _viewModel = AddNewTraineeViewModel();
  TeamData? teamData;
  bind() {
    _traineeController.addListener(() {
      _viewModel.setNewTrainee(_traineeController.text);
    });
    _viewModel.start();
  }


  @override
  void initState() {
    bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Trainee',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: StreamBuilder<StateFlow>(
        builder: (context, snapshot) =>
            snapshot.data?.getScreenWidget(
              context,
              _getContent(),
            ) ??
            _getContent(),
        stream: _viewModel.outputState,
      ),
    );
  }

  Widget _getContent() {
    return Padding(
      padding: EdgeInsets.all(AppPadding.p16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Scan QR Code",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              // if (_viewModel.team.isNotEmpty)
              //   StreamBuilder<TeamData>(
              //       stream: _viewModel.outputTeams,
              //       builder: (context, snapshot) {
              //         teamData = snapshot.data ?? _viewModel.team[0];
              //         // _viewModel.teamsData.keys.cast<String>().toList()[0];
              //         return SizedBox(
              //           width: 160.w,
              //           child: DropdownButton<TeamData>(
              //             value: snapshot.data ?? _viewModel.team[0],
              //             onChanged: (TeamData? newValue) {
              //               teamData = newValue;
              //               _viewModel.inputTeams.add(newValue);
              //             },
              //             style: const TextStyle(
              //               fontSize: 22,
              //               color: Colors.black,
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //             iconSize: 30.h,
              //             borderRadius: BorderRadius.circular(AppSize.s12),
              //             items: _viewModel
              //                 .team
              //                 .map<DropdownMenuItem<TeamData>>((TeamData value) {
              //               return DropdownMenuItem<TeamData>(
              //                 value: value,
              //                 child: SizedBox(width: 125.w, child: Text(value.teamName)),
              //               );
              //             }).toList(),
              //           ),
              //         );
              //       }),
              SizedBox(
                height: 45.h,
                width: 80.w,
                child: ElevatedButton(
                  onPressed: () {
                    // _viewModel.scanQR();
                    // _showAddNewTeamSheet();
                  },
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: ColorManager.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p16.h),
          customTextFormField(
            stream: _viewModel.outputTrainee,
            textEditingController: _traineeController,
            hintText: 'Trainee Name',
          ),
          SizedBox(height: AppSize.s18.h),
          customElevatedButton(
            stream: _viewModel.outputTeamNameRight,
            onPressed: () {
              _viewModel.addNewTrainee( _traineeController.text);
              _traineeController.clear();
            },
            text: 'ADD',
          ),
        ],
      ),
    );
  }

  // void _showAddNewTeamSheet() {
  //   showModalBottomSheet(
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(
  //           top: Radius.circular(
  //             AppSize.s20,
  //           ),
  //         ),
  //       ),
  //       context: context,
  //       builder: (context) {
  //         return Container(
  //           padding: EdgeInsets.all(AppPadding.p20.h),
  //           child: Column(
  //             children: [
  //               SizedBox(height: AppPadding.p16.h),
  //               customTextFormField(
  //                 stream: _viewModel.outputTeamName,
  //                 textEditingController: _teamController,
  //                 hintText: 'Team Name',
  //               ),
  //               SizedBox(height: AppSize.s18.h),
  //               customElevatedButton(
  //                 stream: _viewModel.outputTeamNameRight,
  //                 onPressed: () {
  //                   _viewModel.addNewTeam(_teamController.text);
  //                   Navigator.pop(context);
  //                 },
  //                 text: 'ADD',
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }
}