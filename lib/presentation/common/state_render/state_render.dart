// ignore_for_file: must_be_immutable

import 'package:firesport_users/presentation/resources/assets_manager.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

enum StateRenderType {
  //popup state
  popupErrorState,
  popupLoadingState,
  popupSuccessState,
  deleteState,
  //full screen state
  fullScreenErrorState,
  fullScreenLoadingState,
  fullScreenEmptyState,
  //general
  contentState,
}

class StateRenderer extends StatelessWidget {
  String title;
  String message;
  final StateRenderType stateRenderType;
  final Function retryAction;
  final Function? cancelAction;
  late BuildContext newContext;

  StateRenderer(
      {Key? key,
      this.title = '',
      this.message = AppStrings.loading,
      required this.stateRenderType,
      required this.retryAction,
      this.cancelAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    newContext = context;
    return _getStateWidget();
  }

  Widget _getStateWidget() {
    switch (stateRenderType) {
      case StateRenderType.popupErrorState:
        return _getPopUpDialog(
          [
            _getAnimatedImage(JsonAssets.error),
            _getMessage(),
            _getRetryButton(AppStrings.retry),
          ],
        );
      case StateRenderType.deleteState:
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getAnimatedImage(JsonAssets.delete),
              _getMessage(),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  retryAction.call();
                  Navigator.of(newContext).pop();
                },
                child: const Text("Yes")),
            TextButton(
                onPressed: () {
                  cancelAction!.call();
                  Navigator.of(newContext).pop();
                },
                child: const Text("No")),
          ],
        );

        _getPopUpDialog(
          [
            _getAnimatedImage(JsonAssets.delete),
            _getMessage(),
            _getRetryButton("Yes"),
          ],
        );
      case StateRenderType.popupLoadingState:
        return _getPopUpDialog(
          [
            _getAnimatedImage(JsonAssets.loading),
            _getMessage(),
          ],
        );
      case StateRenderType.popupSuccessState:
        return _getPopUpDialog([
          _getAnimatedImage(JsonAssets.success),
          _getMessage(),
          _getRetryButton(AppStrings.ok)
        ]);
      case StateRenderType.fullScreenErrorState:
        return _getItemColumn([
          _getAnimatedImage(JsonAssets.error),
          _getMessage(),
          _getRetryButton(AppStrings.retry),
        ]);
      case StateRenderType.fullScreenLoadingState:
        return _getItemColumn(
          [
            _getAnimatedImage(JsonAssets.loading),
            _getMessage(),
          ],
        );

      case StateRenderType.fullScreenEmptyState:
        return _getItemColumn(
          [
            _getAnimatedImage(JsonAssets.empty),
            _getMessage(),
          ],
        );
      case StateRenderType.contentState:
        return Container();
      default:
        return Container();
    }
  }

  Widget _getPopUpDialog(List<Widget> children) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s14),
      ),
      elevation: AppSize.s1_5,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 300,
        ),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
              color: ColorManager.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(AppSize.s14),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.grey,
                )
              ]),
          child: _getItemColumn(children),
        ),
      ),
    );
  }

  Widget _getItemColumn(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _getAnimatedImage(String animationName) {
    return SizedBox(
        height: AppSize.s100,
        width: AppSize.s100,
        child: Lottie.asset(animationName));
  }

  Widget _getMessage() {
    return Text(
      message,
      style: getMessageStyle(
        color: ColorManager.black,
        fontSize: FontSize.s12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _getRetryButton(String title) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p10),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            if (stateRenderType == StateRenderType.fullScreenErrorState) {
              retryAction.call();
            } else if (stateRenderType == StateRenderType.popupErrorState ||
                title == 'Yes') {
              Navigator.of(newContext).pop();
              retryAction.call();
            } else {
              Navigator.of(newContext).pop();
            }
          },
          child: Text(
            title,
          ),
        ),
      ),
    );
  }
}
