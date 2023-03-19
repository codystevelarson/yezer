import 'package:flutter/material.dart';
import 'package:yezer/themes/text_styles.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: TextTheme(
    displayLarge: kTDisplayLarge,
    displayMedium: kTDisplayMedium,
    displaySmall: kTDisplaySmall,
    headlineLarge: kTBasic,
    headlineMedium: kTBasic,
    headlineSmall: kTBasic,
    titleLarge: kTBasic,
    titleMedium: kTBasic,
    titleSmall: kTDisplaySmall.copyWith(fontSize: 25),
    bodyLarge: kTBasic,
    bodyMedium: kTBasic,
    bodySmall: kTBasic,
    labelLarge: kTBasic,
    labelMedium: kTBasic,
    labelSmall: kTBasic,
  ),
);
