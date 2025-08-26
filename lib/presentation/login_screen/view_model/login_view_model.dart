import 'dart:async';

import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/usecase/user_usecase.dart';
import 'package:firesport_users/presentation/base/base_view_model.dart';
import 'package:firesport_users/presentation/common/state_render/state_render.dart';
import 'package:firesport_users/presentation/common/state_render/state_renderer_imp.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../../app/app_prefs.dart';

class LoginViewModel extends BaseViewModel {
  final AppPreferences _appPreferences = instance<AppPreferences>();

  final StreamController<bool> isUserLoginSuccessfullyStreamController =
      StreamController.broadcast();
  final UserUsecase _loginUseCase;
  String qrCode = "3BE3B322";

  LoginViewModel(this._loginUseCase);

  bool visible = false;

  @override
  void start() {
    inputState.add(ContentState());
  }
  String processQRCode(String? value, {int targetLength = 32}) {
    // ?????? ?? ?? ?????? ?? null ?? ????? ?? "-1"
    if (value == null || value.isEmpty || value == "-1") {
      return "00000000000000000000000000000000"; // ???? ????? ??? ???? ?????? ??? ?????
    }

    // ????? ?????? ?? ???????? ????????? ?? ?? ???? ??? ???????????
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();

    // ??? ???? ?????? ????? ??? ???????? ???? ?????
    if (cleanedValue.isEmpty) {
      return "00000000000000000000000000000000";
    }

    // ????? ????? ??? ?????? ??? ?? ???? ????? ???????
    if (cleanedValue.length < targetLength) {
      cleanedValue = cleanedValue.padRight(targetLength, '0');
    } else if (cleanedValue.length > targetLength) {
      // ?? ?????? ???? ?? ???????? ?????
      cleanedValue = cleanedValue.substring(0, targetLength);
    }

    return cleanedValue;
  }

// ??????? ????? ?? ???? scan ?? login
  void handleQRCodeScan(String? value) {

    print("Processed QR Code: $qrCode");
    login(); // ??????? ???? login
  }

  void scanQR() {
    FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    ).then((value) {
      if (value != '-1') {
        qrCode = processQRCode(value);
        login();
      }
    });
  }

  login() async {
    inputState.add(
      LoadingState(
        stateRenderType: StateRenderType.popupLoadingState,
      ),
    );
    (await _loginUseCase.login(
      LoginRequest(
        userId: qrCode,
      ),
    ))
        .fold((failure) {
      inputState.add(
        ErrorState(
            stateRenderType: StateRenderType.popupErrorState,
            message: failure.message,
            retryAction: () {
              inputState.add(ContentState());
            }),
      );
    }, (data) async {
      inputState.add(
        ContentState(),
      );
      isUserLoginSuccessfullyStreamController.add(true);
    });
  }
}
