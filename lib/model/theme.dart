import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final themeEntry = "theme";
  ThemeMode get mode => _mode;
  ThemeModel() {
    _pref.then((pref) {
      _mode = _getThemeMode(pref);
      notifyListeners();
    });
  }

  void selectTheme(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
    _pref.then((pref) => pref.setInt(themeEntry, _themeModeToInt(mode)));
  }

  ThemeMode _getThemeMode(SharedPreferences pref) {
    final int mode = pref.getInt(themeEntry) ?? 0;
    switch (mode) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }
}
