import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/app_services.dart';
import 'core/storage/database_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  final services = await AppServices.create(AppConfig.fromEnvironment());
  runApp(GenGamesApp(services: services));
}
