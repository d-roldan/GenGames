import 'package:flutter/material.dart';
import '../../core/services/app_services.dart';
import '../../games/game_definition.dart';
import '../../games/game_registry.dart';
import '../parent/parent_gate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.services});
  final AppServices services;

  void _open(BuildContext context, GameDefinition game) {
    services.analytics.track('game_opened', gameId: game.id);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => game.builder(services)))
        .then((_) => services.analytics.track('game_closed', gameId: game.id));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('¡A jugar! 🌈'),
          actions: [ParentGateButton(services: services)],
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 700
                ? 3
                : constraints.maxWidth > 430
                    ? 2
                    : 1;
            return GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: columns,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: columns == 1 ? 1.8 : 1.05,
              children: games
                  .map((game) =>
                      _GameCard(game: game, onTap: () => _open(context, game)))
                  .toList(),
            );
          }),
        ),
      );
}

class _GameCard extends StatefulWidget {
  const _GameCard({required this.game, required this.onTap});
  final GameDefinition game;
  final VoidCallback onTap;
  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: pressed ? .94 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          elevation: pressed ? 2 : 8,
          borderRadius: BorderRadius.circular(34),
          color: widget.game.color,
          child: InkWell(
            borderRadius: BorderRadius.circular(34),
            onHighlightChanged: (value) => setState(() => pressed = value),
            onTap: widget.onTap,
            child: Semantics(
              label: widget.game.label,
              button: true,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: .9, end: 1.05),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.elasticOut,
                        builder: (_, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Text(widget.game.icon,
                            style: const TextStyle(fontSize: 92))),
                    const SizedBox(height: 4),
                    Text(widget.game.label,
                        style: Theme.of(context).textTheme.headlineLarge),
                  ]),
            ),
          ),
        ),
      );
}
