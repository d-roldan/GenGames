import 'package:flutter/material.dart';
import '../core/services/app_services.dart';

class GameDefinition {
  const GameDefinition(
      {required this.id,
      required this.label,
      required this.icon,
      required this.color,
      required this.builder});
  final String id;
  final String label;
  final String icon;
  final Color color;
  final Widget Function(AppServices services) builder;
}
