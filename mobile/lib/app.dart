import 'package:flutter/material.dart';
import 'core/services/app_services.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

class KidsGameApp extends StatefulWidget {
  const KidsGameApp({super.key, required this.services});
  final AppServices services;

  @override
  State<KidsGameApp> createState() => _KidsGameAppState();
}

class _KidsGameAppState extends State<KidsGameApp> {
  @override
  void dispose() {
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'KidsGame',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.childFriendly,
        home: HomeScreen(services: widget.services),
      );
}

