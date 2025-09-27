import 'package:flutter/material.dart';

import 'color_manager.dart';
import 'font_manager.dart';
import 'style_manager.dart';
import 'values_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    //main color
    scaffoldBackgroundColor: ColorManager.white,
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.lightPrimary,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.grey1,
    splashColor: ColorManager.lightPrimary,
    //cardView theme
    cardTheme: CardThemeData(
      color: ColorManager.white,
      elevation: AppSize.s4,
      shadowColor: ColorManager.grey,
    ),
    //appBar Theme
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: AppSize.s4,
      color: ColorManager.primary,
      shadowColor: ColorManager.lightPrimary,
      titleTextStyle: getBoldStyle(
        fontSize: FontSize.s20,
        color: ColorManager.white,
      ),
      foregroundColor: ColorManager.white
    ),
    // button theme
    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.grey,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.white,
    ),
    // elevated button them
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle:
            getRegularStyle(color: ColorManager.white, fontSize: FontSize.s17),
        backgroundColor: ColorManager.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSize.s12,
          ),
        ),
      ),
    ),
    //text theme
    textTheme: TextTheme(
      displayLarge: getLightStyle(
        color: ColorManager.white,
        fontSize: FontSize.s22,
      ),
      // use in title for pages
      headlineLarge: getMediumStyle(
        color: ColorManager.simiBlack,
        fontSize: FontSize.s20,
      ),
      // used in sub title for pages
      headlineMedium: getRegularStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s14,
      ),
      headlineSmall: getMediumStyle(
        color: ColorManager.grey,
        fontSize: AppSize.s14,
      ),
      bodyLarge: getRegularStyle(
        color: ColorManager.primary,
        fontSize: FontSize.s14,
      ),
      // used in google and facebook buttons
      bodySmall: getLightStyle(
        color: ColorManager.grey,
        fontSize: FontSize.s16,
      ),
      labelSmall: getRegularStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s14,
      ),
      labelMedium: getMediumStyle(
        color: ColorManager.simiBlack,
        fontSize: FontSize.s18,
      ),
      labelLarge: getBoldStyle(
        color: ColorManager.simiBlack,
        fontSize: FontSize.s20,
      ),
      displayMedium: getBoldStyle(
        color: ColorManager.white,
        fontSize: FontSize.s25,

      ),
      titleLarge: getMediumStyle(
        color: ColorManager.simiBlack,
        fontSize: FontSize.s48,
      ),
      titleMedium: getRegularStyle(
        fontSize: FontSize.s16,
        color: ColorManager.simiBlack,
      ),
      bodyMedium: getLightStyle(
        color: ColorManager.grey,
        fontSize: FontSize.s12,
      ),
    ),
    //input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      //content padding
      contentPadding: const EdgeInsets.all(
        AppPadding.p16,
      ),
      //error style
      errorStyle: getRegularStyle(
        fontSize: FontSize.s12,
        color: ColorManager.textFormErrorBorder,
      ),

      //hint style
      hintStyle: getRegularStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s14,
      ),
      //label style
      labelStyle: getMediumStyle(
        color: ColorManager.simiBlue,
        fontSize: FontSize.s14,
      ),
      fillColor: ColorManager.grey,
      filled: true,
      //enable border style
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.grey,
        ),
        borderRadius: BorderRadius.circular(
          AppSize.s12,
        ),
      ),

      //focused Border style
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppSize.s12,
        ),
        borderSide: BorderSide(
          color: ColorManager.textFormEnabledBorder,
          width: AppSize.s1_5,
        ),
      ),

      //error border style
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppSize.s12,
        ),
        borderSide: BorderSide(
          color: ColorManager.textFormErrorBorder,
          width: AppSize.s1_5,
        ),
      ),

      //focused error border style
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppSize.s12,
        ),
        borderSide: BorderSide(
          color: ColorManager.textFormEnabledBorder,
          width: AppSize.s1_5,
        ),
      ),
    ),
  );
}
