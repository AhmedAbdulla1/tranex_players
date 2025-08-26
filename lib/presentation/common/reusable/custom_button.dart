import 'dart:async';

import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

Widget customElevatedButton({
  required Stream<bool> stream,
  required VoidCallback onPressed,
  required String text,
}) {
  return StreamBuilder<bool>(
    stream: stream,
    builder: (context, snapshot) => SizedBox(
      height: AppSize.s55,
      width: double.infinity,
      child: ElevatedButton(
          onPressed: (snapshot.data ?? false) ? onPressed : null,
          child: Text(
            text,
            style: TextStyle(color:snapshot.data??false ? ColorManager.white :ColorManager.black,fontSize: 16),
          )),
    ),
  );
}

Widget customElevatedButtonWithoutStream({
  required VoidCallback? onPressed,
  required Widget child,
}) {
  return SizedBox(
      height: AppSize.s55,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p50),
        child: ElevatedButton(
          onPressed: onPressed,
          child:child,

        ),
      ));
}

Widget textButton({
  required context,
  required VoidCallback onPressed,
  required String text,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.end,
    ),
  );
}
