import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeService, ThemeData>((ref) {
  return ThemeService(ref.read(sharedPreferencesProvider));
});

const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryBlack =
    MaterialColor(_blackPrimaryValue, <int, Color>{
  50: Color(0xFF000000),
  100: Color(0xFF000000),
  200: Color(0xFF000000),
  300: Color(0xFF000000),
  400: Color(0xFF000000),
  500: Color(0xFF000000),
  600: Color(0xFF000000),
  700: Color(0xFF000000),
  800: Color(0xFF000000),
  900: Color(0xFF000000),
});

ThemeData darkThemeData = ThemeData(
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.yellow,
    actionsIconTheme: IconThemeData(color: Colors.yellow),
  ),
  scaffoldBackgroundColor: Colors.grey[800],
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black, foregroundColor: Colors.yellow),
  primarySwatch: primaryBlack,
  dialogBackgroundColor: Colors.grey[900],
  colorScheme: const ColorScheme.highContrastDark(
      brightness: Brightness.dark,
      primary: Colors.yellow,
      primaryContainer: Colors.yellow,
      secondary: Colors.black,
      secondaryContainer: Colors.black,
      onPrimary: Colors.black,
      onSecondary: Colors.yellow,
      onError: Colors.white,
      error: Colors.red,
      surface: Colors.black),
);
ThemeData lightThemeData = ThemeData(
  primarySwatch: primaryBlack,
  scaffoldBackgroundColor: Colors.grey[300],
  dialogBackgroundColor: Colors.grey[300],
  colorScheme: ColorScheme.highContrastLight(
    brightness: Brightness.light,
    primary: Colors.black87,
    primaryContainer: Colors.black,
    secondary: Colors.grey,
    secondaryContainer: Colors.grey[500],
    background: Colors.black45,
    onPrimary: Colors.amber,
    onSecondary: Colors.amber,
    onError: Colors.white,
    error: Colors.red,
  ),
);

class ThemeService extends StateNotifier<ThemeData> {
  final SharedPreferences prefs;

  ThemeService(this.prefs)
      : super((prefs.getBool('darkMode') ?? true)
            ? darkThemeData
            : lightThemeData);

  void darkTheme() {
    state = darkThemeData;
    prefs.setBool('darkMode', true);
  }

  void lightTheme() {
    state = lightThemeData;
    prefs.setBool('darkMode', false);
  }
}
