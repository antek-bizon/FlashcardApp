import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flashcards/data/repositories/theme.dart';
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;
  final String? message;
  const ThemeState({required this.mode, this.message});
}

class SuccessThemeState {}

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository _themeRepository;
  late StreamSubscription<ThemeMode> _themeSubscription;

  ThemeCubit(ThemeRepository themeRepository)
      : _themeRepository = themeRepository,
        super(const ThemeState(mode: ThemeMode.light));

  void getCurrentTheme() {
    _themeSubscription = _themeRepository.getTheme().listen((themeMode) {
      emit(ThemeState(mode: themeMode));
    });
  }

  void setTheme(ThemeMode mode) {
    if (state.mode != mode) {
      _themeRepository.saveTheme(mode).then((success) {
        final String? message =
            !success ? "Failed to save theme in storage" : null;
        emit(ThemeState(mode: mode, message: message));
      });
    }
  }

  @override
  Future<void> close() {
    _themeSubscription.cancel();
    _themeRepository.dispose();
    return super.close();
  }
}
