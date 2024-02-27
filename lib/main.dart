import 'package:flashcards/app.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/data/repositories/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final pref = await SharedPreferences.getInstance();
  runApp(App(
      themeRepository: ThemeRepository(pref),
      databaseRepository:
          DatabaseRepository("https://antek-bizon.xinit.se/pb/"),
      localStorageRepository: LocalStorageRepository(pref)));
}
