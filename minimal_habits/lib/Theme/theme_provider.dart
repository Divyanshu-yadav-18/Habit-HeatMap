import 'package:flutter/material.dart';
import 'package:minimal_habits/Theme/darkmode.dart';
import 'package:minimal_habits/Theme/lightmode.dart';

class ThemeProvider extends ChangeNotifier {
  //initially theme is lightmode
  ThemeData _themeData = lightMode;

  //get current theme
  ThemeData get themeData => _themeData;

  //is colot theme dark mode
  bool get isDarkMode => _themeData == darkMode;

  //set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //toggle between lightmode and darkmode

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
