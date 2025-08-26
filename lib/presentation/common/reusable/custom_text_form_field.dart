// import 'package:easy_localization/easy_localization.dart';
import 'package:firesport_users/presentation/resources/color_manager.dart';
import 'package:firesport_users/presentation/resources/font_manager.dart';
import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:firesport_users/presentation/resources/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

Widget customTextFormField({
  required Stream<String?> stream,
  required TextEditingController textEditingController,
  TextInputType textInputType = TextInputType.emailAddress,
  required String hintText,
}) {
  return StreamBuilder<String?>(
    stream: stream,
    builder: (context, snapshot) => TextFormField(
      style: getLightStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s16,
      ),
      keyboardType: textInputType,
      controller: textEditingController,
      decoration: InputDecoration(hintText: hintText, errorText: snapshot.data),
    ),
  );
}

//
Widget customPasswordFormField({
  required Stream<String?> stream1,
  required Stream<bool> stream2,
  required TextEditingController textEditingController,
  required VoidCallback onPressed,
  String title = AppStrings.password,

}) {
  return StreamBuilder2<String?, bool>(
    streams: StreamTuple2(stream1, stream2),
    builder: (context, snapshot) => TextFormField(

      style: getLightStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s16,
      ),
      keyboardType: TextInputType.visiblePassword,
      controller: textEditingController,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          splashColor: ColorManager.white,
          onPressed: onPressed,
          icon: !(snapshot.snapshot2.data ?? true)
              ? Icon(
                  Icons.visibility_outlined,
                  color: ColorManager.textFormIcon,
                )
              : Icon(Icons.visibility_off_outlined, color: ColorManager.textFormIcon),
        ),
        hintText: title,
        errorText: snapshot.snapshot1.data,
        errorMaxLines: 2
      ),
      obscureText: snapshot.snapshot2.data ?? true,
    ),
  );
}
