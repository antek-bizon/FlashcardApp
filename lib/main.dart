import 'package:flashcards/app.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/data/repositories/theme.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );
  runApp(App(
      themeRepository: ThemeRepository(prefs),
      databaseRepository: DatabaseRepository(
        PocketBase("https://antek-bizon.xinit.se/pb/", authStore: store),
      ),
      localStorageRepository: LocalStorageRepository(prefs)));
}
