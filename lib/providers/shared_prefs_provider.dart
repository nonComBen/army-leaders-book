import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider with ChangeNotifier {
  final SharedPreferences prefs;
  SharedPreferencesProvider(this.prefs);

  SharedPreferences get sharedPrefs {
    return prefs;
  }
}
