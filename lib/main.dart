import 'package:flashcards/app.dart';
import 'package:flashcards/data/repositories/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final pref = await SharedPreferences.getInstance();
  runApp(
    App(
      themeRepository: ThemeRepository(pref),
    ),
  );
}
