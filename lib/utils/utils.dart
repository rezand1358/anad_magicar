import 'package:anad_magicar/ui/theme/dark_theme.dart';
import 'package:anad_magicar/ui/theme/theme.dart';
import 'package:flutter/material.dart';


const MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);

final ThemeData kLightTheme = _buildLightTheme();



ThemeData _buildLightTheme() {
  final ThemeData base = myLightTheme; //ThemeData.light();
  return base;/*.copyWith(

      );*/
}

final ThemeData kDarkTheme = _buildDarkTheme();

ThemeData _buildDarkTheme() {
  final ThemeData base = myDarkTheme;//ThemeData.dark();
  return base;
}
