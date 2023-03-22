import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeService, ThemeMode>((ref) {
  return ThemeService(ref.read(sharedPreferencesProvider));
});

class ThemeService extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;

  ThemeService(this.prefs)
      : super((prefs.getBool('darkMode') ?? true)
            ? ThemeMode.dark
            : ThemeMode.light);

  void darkTheme() {
    state = ThemeMode.dark;
    prefs.setBool('darkMode', true);
  }

  void lightTheme() {
    state = ThemeMode.light;
    prefs.setBool('darkMode', false);
  }
}
