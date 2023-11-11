import 'package:flashcards/model/theme.dart';
import 'package:flashcards/pages/starting_page.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.greenAccent);
    final darkScheme = ColorScheme.fromSeed(
        seedColor: Colors.pink, brightness: Brightness.dark);

    return ChangeNotifierProvider<ThemeModel>(
        create: (_) => ThemeModel(),
        child: Consumer<ThemeModel>(builder: (context, value, child) {
          return MaterialApp(
              title: 'Flashcards',
              theme: ThemeData(
                  colorScheme: lightScheme,
                  useMaterial3: true,
                  textTheme: GoogleFonts.mulishTextTheme()),
              darkTheme: ThemeData(
                  colorScheme: darkScheme,
                  useMaterial3: true,
                  textTheme: GoogleFonts.mulishTextTheme(const TextTheme(
                      titleMedium: TextStyle(color: Colors.white)))),
              themeMode: value.mode,
              home: const StartingPage());
        }));
  }
}
