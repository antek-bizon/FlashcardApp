import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
              bodySmall: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
      );

  static ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey.shade800,
        textTheme: ThemeData.dark().textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
              bodySmall: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
      );
}
