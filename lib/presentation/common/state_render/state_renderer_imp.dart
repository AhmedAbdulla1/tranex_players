import 'package:tranex_users/app/constant.dart';
import 'package:tranex_users/presentation/common/state_render/state_render.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:flutter/material.dart';

abstract class StateFlow {
  String getMessage();

  Function getRetryAction();
  Function? getOnCancelAction();
  StateRenderType getStateRenderType();
}

// loading State (popup ,fullscreen)
class LoadingState extends StateFlow {
  final StateRenderType stateRenderType;
  final String message;

  LoadingState({
    required this.stateRenderType,
    this.message = AppStrings.loading,
  });

  @override
  String getMessage() => message;

  @override
  StateRenderType getStateRenderType() => stateRenderType;

  @override
  Function getRetryAction() {
    return () {};
  }

  @override
  Function? getOnCancelAction() {
    return null;
  }
}

// error State (popup ,fullscreen)
class ErrorState extends StateFlow {
  final StateRenderType stateRenderType;
  final String message;
  final Function? retryAction;

  ErrorState({
    required this.stateRenderType,
    required this.message,
    required this.retryAction,
  });

  @override
  String getMessage() => message;

  @override
  StateRenderType getStateRenderType() => stateRenderType;

  @override
  Function getRetryAction() {
    return retryAction ??
        () {
          ContentState();
        };
  }

  @override
  Function? getOnCancelAction() {
    return null;
  }
}

//empty state
class EmptyState extends StateFlow {
  final String message;

  EmptyState({
    required this.message,
  });

  @override
  String getMessage() => message;

  @override
  StateRenderType getStateRenderType() => StateRenderType.fullScreenEmptyState;

  @override
  Function getRetryAction() {
    return () {};
  }

  @override
  Function? getOnCancelAction() {
    return null;
  }
}

// success state
class SuccessState extends StateFlow {
  final String message;

  SuccessState(this.message);

  @override
  String getMessage() => message;

  @override
  Function getRetryAction() {
    return () {};
  }

  @override
  StateRenderType getStateRenderType() => StateRenderType.popupSuccessState;

  @override
  Function? getOnCancelAction() {
    return null;
  }
}

// delete state
class DeleteState extends StateFlow {
  final Function retryAction;
  final Function onCancel;

  DeleteState({required this.retryAction, required this.onCancel});

  @override
  String getMessage() => 'Are you sure you want to delete?';

  @override
  Function getRetryAction() {
    return retryAction;
  }

  @override
  StateRenderType getStateRenderType() => StateRenderType.popupSuccessState;

  @override
  Function? getOnCancelAction() {
    return onCancel;
  }
}

// content state

class ContentState extends StateFlow {
  @override
  String getMessage() => Constant.empty;

  @override
  Function getRetryAction() {
    return () {};
  }

  @override
  StateRenderType getStateRenderType() => StateRenderType.contentState;

  @override
  Function? getOnCancelAction() {
    return null;
  }
}

extension StateFlowExtension on StateFlow {
  Widget getScreenWidget(BuildContext context, Widget contentScreenWidget) {
    switch (runtimeType) {
      case LoadingState:
        {
          dismissDialog(context);
          if (getStateRenderType() == StateRenderType.popupLoadingState) {
            // popup show
            showPopup(context, getStateRenderType(), getMessage(),
                getRetryAction(), null);
            //return content screen
            return contentScreenWidget;
          } else {
            //return full screen loading state
            return StateRenderer(
              stateRenderType: StateRenderType.fullScreenLoadingState,
              retryAction: getRetryAction(),
            );
          }
        }
      case ErrorState:
        {
          dismissDialog(context);
          if (getStateRenderType() == StateRenderType.popupErrorState) {
            showPopup(context, getStateRenderType(), getMessage(),
                getRetryAction(), null);
            return contentScreenWidget;
          } else {
            return StateRenderer(
              stateRenderType: StateRenderType.fullScreenErrorState,
              message: getMessage(),
              retryAction: getRetryAction(),
            );
          }
        }
      case EmptyState:
        return StateRenderer(
            stateRenderType: StateRenderType.fullScreenEmptyState,
            message: getMessage(),
            retryAction: () {});
      case ContentState:
        {
          return contentScreenWidget;
        }
      case SuccessState:
        {
          dismissDialog(context);
          showPopup(context, StateRenderType.popupSuccessState, getMessage(),
              getRetryAction(), null);
          return contentScreenWidget;
        }
      case DeleteState:
        {
          dismissDialog(context);
          showPopup(context, StateRenderType.deleteState, getMessage(),
              getRetryAction(), getOnCancelAction());
          return contentScreenWidget;
        }
      default:
        dismissDialog(context);
        return contentScreenWidget;
    }
  }

  showPopup(BuildContext context, StateRenderType stateRenderType,
      String message, Function retryAction, Function? cancelAction) {
    WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
        context: context,
        builder: (BuildContext context) => StateRenderer(
              stateRenderType: stateRenderType,
              message: message,
              retryAction: retryAction,
              cancelAction: cancelAction,
            )));
  }

  // for check if there dialog message or not

  dismissDialog(BuildContext context) {
    if (_isCurrentDialogShowing(context)) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  _isCurrentDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;
}
