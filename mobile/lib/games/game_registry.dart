import 'package:flutter/material.dart';
import 'animals_game/animals_game_screen.dart';
import 'cat_game/cat_game_screen.dart';
import 'drawing_game/drawing_game_screen.dart';
import 'game_definition.dart';

const games = <GameDefinition>[
  GameDefinition(id: 'cat_game', label: 'Gatito', icon: '🐱', color: Color(0xFFFFC857), builder: CatGameScreen.new),
  GameDefinition(id: 'drawing_game', label: 'Dibujar', icon: '🎨', color: Color(0xFF58D6C7), builder: DrawingGameScreen.new),
  GameDefinition(id: 'animals_game', label: 'Animales', icon: '🐶', color: Color(0xFFFF8A80), builder: AnimalsGameScreen.new),
];

