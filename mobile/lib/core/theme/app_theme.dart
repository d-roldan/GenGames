import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get childFriendly => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        textTheme: const TextTheme(headlineLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 34), titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 25)),
        iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(64, 64), iconSize: 38)),
      );
}

