import 'package:flutter/material.dart';

class ThemeColor {
  static final ThemeColor _instance = ThemeColor._internal();

  ThemeColor._internal();
  factory ThemeColor() {
    return _instance;
  }

  Color configurationBoard = const Color.fromARGB(255, 45, 74, 168);
  Color configurationText = Colors.white;
  Color pomodoroText = Colors.white;
  Color hallOfFame = const Color.fromARGB(255, 45, 74, 168);
  Color hallOfFameText = Colors.white;
  Color conceiled = const Color.fromARGB(255, 45, 74, 168);
  Color conceiledContrast = Colors.amber;
  Color revealed = const Color.fromARGB(255, 204, 234, 248);
}

class ThemeButton {
  static ButtonStyle elevated =
      ElevatedButton.styleFrom(backgroundColor: Colors.white);
}

class ThemeSize {
  static double title(context) => MediaQuery.of(context).size.height * 0.028;
  static double text(context) => MediaQuery.of(context).size.height * 0.02;
}

class ThemePadding {
  static double normal(context) => MediaQuery.of(context).size.height * 0.015;
  static double interline(context) =>
      MediaQuery.of(context).size.height * 0.005;
}
