import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  final SharedPreferences prefs;

  ThemeProvider(this.prefs) {
    final darkMode = prefs.getBool('darkMode') ?? true;
    if (darkMode) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
  }

  // static Future<ThemeProvider> loadThemeMode() async {
  //   SharedPreferences prefs;
  //   prefs = await SharedPreferences.getInstance();
  //   final darkMode = prefs.getBool('darkMode') ?? true;
  //   if (darkMode) {
  //     _themeMode = ThemeMode.dark;
  //   } else {
  //     _themeMode = ThemeMode.light;
  //   }
  //   return ThemeProvider(_themeMode);
  // }

  ThemeMode get currentThemeMode {
    return _themeMode;
  }

  void darkTheme() {
    _themeMode = ThemeMode.dark;
    //_prefs.setBool('darkMode', true);
    notifyListeners();
  }

  void lightTheme() {
    _themeMode = ThemeMode.light;
    //_prefs.setBool('darkMode', false);
    notifyListeners();
  }
}
