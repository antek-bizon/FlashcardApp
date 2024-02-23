import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemePersistence {
  Stream<ThemeMode> getTheme();
  Future<void> saveTheme(ThemeMode theme);
  void dispose();
}

class ThemeRepository implements ThemePersistence {
  final SharedPreferences _pref;
  static const _kThemePersistenceKey = '__theme_persistence_key__';
  final _controller = StreamController<ThemeMode>();

  ThemeRepository(SharedPreferences sharedPreferences)
      : _pref = sharedPreferences {
    _init();
  }

  @override
  Stream<ThemeMode> getTheme() async* {
    yield* _controller.stream;
  }

  @override
  Future<bool> saveTheme(ThemeMode mode) {
    _controller.add(mode);
    return _setValue(_kThemePersistenceKey, mode.name);
  }

  @override
  void dispose() => _controller.close();

  String? _getValue(String key) {
    try {
      return _pref.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _setValue(String key, String value) =>
      _pref.setString(key, value);

  void _init() {
    final themeString = _getValue(_kThemePersistenceKey);
    try {
      if (themeString == null) {
        throw 'Null theme string';
      }

      final themeMode = ThemeMode.values.byName(themeString);
      _controller.add(themeMode);
    } catch (_) {
      _controller.add(ThemeMode.light);
    }
  }
}
