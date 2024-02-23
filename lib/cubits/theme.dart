import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flashcards/data/repositories/theme.dart';
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);
}

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository _themeRepository;
  late StreamSubscription<ThemeMode> _themeSubscription;

  ThemeCubit(ThemeRepository themeRepository)
      : _themeRepository = themeRepository,
        super(const ThemeState(ThemeMode.light));

  void getCurrentTheme() {
    _themeSubscription = _themeRepository.getTheme().listen((themeMode) {
      emit(ThemeState(themeMode));
    });
  }

  void setTheme(ThemeMode mode) {
    if (state.mode != mode) {
      emit(ThemeState(mode));
    }
  }

  @override
  Future<void> close() {
    _themeSubscription.cancel();
    _themeRepository.dispose();
    return super.close();
  }
}
