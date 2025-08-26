
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NfCWidget extends StatelessWidget {
  final String iconPath;

  const NfCWidget({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(iconPath),
    );
  }
}
