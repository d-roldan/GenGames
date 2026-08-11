import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/app_services.dart';

class Animal {
  const Animal(this.id, this.icon, this.sound, this.color);
  final String id, icon, sound;
  final Color color;
}

const animals = [
  Animal('dog', '🐶', '¡Guau, guau!', Color(0xFFFFCC80)),
  Animal('cat', '🐱', '¡Miau!', Color(0xFFFFAB91)),
  Animal('cow', '🐮', '¡Muuu!', Color(0xFFE0E0E0)),
  Animal('horse', '🐴', '¡Hiii!', Color(0xFFD7CCC8)),
  Animal('duck', '🦆', '¡Cuac, cuac!', Color(0xFFFFF59D)),
  Animal('sheep', '🐑', '¡Beeee!', Color(0xFFB3E5FC))
];

class AnimalsGameScreen extends StatefulWidget {
  const AnimalsGameScreen(this.services, {super.key});
  final AppServices services;
  @override
  State<AnimalsGameScreen> createState() => _AnimalsGameScreenState();
}

class _AnimalsGameScreenState extends State<AnimalsGameScreen> {
  String? selected;
  void choose(Animal animal) {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    widget.services.audio.playAnimal(animal.id);
    widget.services.analytics.track('animal_selected',
        gameId: 'animals_game', metadata: {'animal': animal.id});
    setState(() => selected = animal.id);
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => selected = null);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 600),
        backgroundColor: animal.color,
        content: Center(
            child: Text(animal.sound,
                style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: const BackButton(), title: const Text('🐾')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (_, constraints) => GridView.count(
              padding: const EdgeInsets.all(18),
              crossAxisCount: constraints.maxWidth > 700 ? 3 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: animals
                  .map(
                    (animal) => AnimatedScale(
                      scale: selected == animal.id ? 1.15 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: Material(
                        color: animal.color,
                        elevation: 6,
                        borderRadius: BorderRadius.circular(32),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: () => choose(animal),
                          child: Center(
                              child: Text(animal.icon,
                                  style: const TextStyle(fontSize: 88))),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
}
