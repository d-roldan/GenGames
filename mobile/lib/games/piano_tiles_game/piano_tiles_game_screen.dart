import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_services.dart';
import 'piano_tiles_engine.dart';

class PianoTilesGameScreen extends StatefulWidget {
  const PianoTilesGameScreen(this.services, {super.key});

  final AppServices services;

  @override
  State<PianoTilesGameScreen> createState() => _PianoTilesGameScreenState();
}

class _PianoTilesGameScreenState extends State<PianoTilesGameScreen>
    with SingleTickerProviderStateMixin {
  final engine = PianoTilesEngine();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _boardHeight = 1;
  int _levelShown = 1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final delta = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds /
            Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (engine.status != PianoGameStatus.playing || delta <= 0) return;
    final missed = engine.tick(math.min(delta, .1), _boardHeight);
    if (missed) _finish('tile_missed');
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    final savedBest =
        await widget.services.database.setting('piano_tiles_best');
    engine.start(previousBest: int.tryParse(savedBest ?? '') ?? 0);
    _levelShown = 1;
    _lastElapsed = Duration.zero;
    unawaited(widget.services.analytics
        .track('piano_game_started', gameId: 'piano_tiles'));
    if (mounted) setState(() {});
  }

  void _tapLane(int lane) {
    if (engine.status != PianoGameStatus.playing) return;
    final previousLevel = engine.level;
    final hit = engine.tap(lane, _boardHeight);
    if (!hit) {
      _finish('wrong_tile');
      return;
    }
    HapticFeedback.lightImpact();
    unawaited(widget.services.audio.playPianoNote(engine.score - 1));
    if (engine.level > previousLevel) {
      _levelShown = engine.level;
      HapticFeedback.mediumImpact();
    }
    setState(() {});
  }

  void _finish(String reason) {
    if (engine.status != PianoGameStatus.gameOver) engine.miss();
    HapticFeedback.heavyImpact();
    unawaited(widget.services.audio.playPianoMiss());
    unawaited(widget.services.analytics.track('piano_game_finished',
        gameId: 'piano_tiles',
        metadata: {
          'score': engine.score,
          'level': engine.level,
          'reason': reason
        }));
    unawaited(_saveBest());
    if (mounted) setState(() {});
  }

  Future<void> _saveBest() async {
    final previous = await widget.services.database.setting('piano_tiles_best');
    final oldBest = int.tryParse(previous ?? '') ?? 0;
    if (engine.bestScore > oldBest) {
      await widget.services.database
          .setSetting('piano_tiles_best', engine.bestScore.toString());
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF4F0FF),
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('🎹 Piano Tiles'),
          actions: [
            _Counter(label: 'NIVEL', value: '${engine.level}'),
            _Counter(label: 'PUNTOS', value: '${engine.score}'),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            _boardHeight = constraints.maxHeight;
            return Stack(
              children: [
                Row(
                  children: List.generate(
                    PianoTilesEngine.laneCount,
                    (lane) => Expanded(
                      child: GestureDetector(
                        key: Key('piano-lane-$lane'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _tapLane(lane),
                        child: Container(
                          decoration: BoxDecoration(
                            color: lane.isEven
                                ? Colors.white
                                : const Color(0xFFF8F6FC),
                            border: const Border(
                                right: BorderSide(
                                    color: Color(0xFFDDD5EA), width: 2)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: constraints.maxHeight * PianoTilesEngine.hitLine,
                  left: 0,
                  right: 0,
                  child: Container(height: 5, color: const Color(0xFFFFC857)),
                ),
                if (engine.tile case final tile?)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: Duration.zero,
                    top: tile.y,
                    left: tile.lane *
                            constraints.maxWidth /
                            PianoTilesEngine.laneCount +
                        5,
                    width:
                        constraints.maxWidth / PianoTilesEngine.laneCount - 10,
                    height: PianoTilesEngine.tileHeight,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF33265C),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.music_note_rounded,
                              color: Colors.white, size: 38),
                        ),
                      ),
                    ),
                  ),
                if (_levelShown > 1 && engine.status == PianoGameStatus.playing)
                  Positioned(
                    top: 22,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFC857),
                            borderRadius: BorderRadius.circular(24)),
                        child: Text('¡Nivel $_levelShown! Más rápido',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                if (engine.status != PianoGameStatus.playing)
                  _Overlay(
                    gameOver: engine.status == PianoGameStatus.gameOver,
                    score: engine.score,
                    best: engine.bestScore,
                    level: engine.level,
                    onStart: _start,
                  ),
              ],
            );
          }),
        ),
      );
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _Overlay extends StatelessWidget {
  const _Overlay(
      {required this.gameOver,
      required this.score,
      required this.best,
      required this.level,
      required this.onStart});
  final bool gameOver;
  final int score;
  final int best;
  final int level;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: const Color(0xD933265C),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(28),
              padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(32)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(gameOver ? '🎵 ¡Buen intento!' : '🎹',
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (gameOver) ...[
                  Text('$score puntos',
                      key: const Key('piano-final-score'),
                      style: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.w900)),
                  Text('Nivel $level  •  Récord $best',
                      style: const TextStyle(fontSize: 19)),
                ] else
                  const Text(
                      'Tocá la baldosa oscura cuando llegue a la línea amarilla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 21)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('piano-start'),
                  onPressed: onStart,
                  icon: Icon(
                      gameOver
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                      size: 34),
                  label: Text(gameOver ? 'Otra vez' : 'Jugar',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),
        ),
      );
}
