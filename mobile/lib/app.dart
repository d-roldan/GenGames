import 'package:flutter/material.dart';
import 'core/services/app_services.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

class GenGamesApp extends StatefulWidget {
  const GenGamesApp({super.key, required this.services});
  final AppServices services;

  @override
  State<GenGamesApp> createState() => _GenGamesAppState();
}

class _GenGamesAppState extends State<GenGamesApp> {
  @override
  void dispose() {
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'GenGames',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.childFriendly,
        home: HomeScreen(services: widget.services),
      );
}
