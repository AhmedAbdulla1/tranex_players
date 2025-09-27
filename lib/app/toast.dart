import 'package:flutter/material.dart';

class ShowToast {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static String _cleanErrorMessage(String errorMsg) {
    final authApiRegex = RegExp(r'AuthApiException\(message: ([^,]+)');
    final authApiMatch = authApiRegex.firstMatch(errorMsg);
    if (authApiMatch != null && authApiMatch.groupCount >= 1) {
      return authApiMatch.group(1)!;
    }

    final generalExceptionRegex = RegExp(r'Exception: (.+)');
    final generalMatch = generalExceptionRegex.firstMatch(errorMsg);
    if (generalMatch != null && generalMatch.groupCount >= 1) {
      return generalMatch.group(1)!;
    }

    return errorMsg;
  }

  static void show(
    String msg, {
    Duration duration = const Duration(seconds: 2), // أقل شوية للموبايل
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14, // أنسب للموبايل
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () {
                  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                },
              ),
            ],
          ),
          duration: duration,
          backgroundColor: backgroundColor,
          behavior: behavior,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }

  static void showSuccess(String msg) {
    show(msg, backgroundColor: Colors.green.shade700);
  }

  static void showError(String msg) {
    final cleanedMsg = _cleanErrorMessage(msg);
    show(cleanedMsg, backgroundColor: Colors.red.shade700);
  }

  static void showInfo(String msg) {
    show(msg, backgroundColor: Colors.blue.shade700);
  }
}
