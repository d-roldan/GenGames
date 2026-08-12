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
  int? _errorLane;
  int _announcedLevel = 1;
  Timer? _feedbackTimer;
  Timer? _levelTimer;
  bool _showLevel = false;

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
    final result = engine.tick(math.min(delta, .1), _boardHeight);
    if (result.missed > 0) {
      HapticFeedback.selectionClick();
    }
    if (result.levelAdvanced) _announceLevel();
    if (result.songCompleted) _finish();
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    final savedBest =
        await widget.services.database.setting('piano_tiles_best');
    await widget.services.audio.startPianoMusic();
    if (!mounted) return;
    engine.start(_boardHeight,
        previousBest: int.tryParse(savedBest ?? '') ?? 0);
    _announcedLevel = 1;
    _lastElapsed = Duration.zero;
    _showLevel = false;
    unawaited(widget.services.analytics
        .track('piano_game_started', gameId: 'piano_tiles'));
    setState(() {});
  }

  void _tapLane(int lane) {
    if (engine.status != PianoGameStatus.playing) return;
    final previousLevel = engine.level;
    final hit = engine.tap(lane, _boardHeight);
    if (!hit) {
      _showMistake(lane);
      return;
    }
    HapticFeedback.lightImpact();
    unawaited(widget.services.audio.playPianoNote(engine.hits - 1));
    if (engine.level > previousLevel) _announceLevel();
    if (engine.status == PianoGameStatus.songComplete) _finish();
    setState(() {});
  }

  void _showMistake(int lane) {
    HapticFeedback.mediumImpact();
    _errorLane = lane;
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 260), () {
      if (mounted) setState(() => _errorLane = null);
    });
    if (mounted) setState(() {});
  }

  void _announceLevel() {
    if (engine.level <= _announcedLevel) return;
    _announcedLevel = engine.level;
    _showLevel = true;
    HapticFeedback.mediumImpact();
    unawaited(widget.services.audio.setPianoLevel(engine.level));
    _levelTimer?.cancel();
    _levelTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showLevel = false);
    });
  }

  void _finish() {
    unawaited(widget.services.audio.stopPianoMusic());
    HapticFeedback.heavyImpact();
    unawaited(widget.services.analytics
        .track('piano_game_finished', gameId: 'piano_tiles', metadata: {
      'score': engine.score,
      'hits': engine.hits,
      'misses': engine.misses,
      'mistakes': engine.mistakes,
      'best_combo': engine.bestCombo,
      'reason': 'song_complete'
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
    _feedbackTimer?.cancel();
    _levelTimer?.cancel();
    _ticker.dispose();
    unawaited(widget.services.audio.stopPianoMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvokedWithResult: (_, __) =>
            unawaited(widget.services.audio.stopPianoMusic()),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F5FA),
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('🎹 Piano Tiles'),
            actions: [
              _Counter(label: 'NIVEL', value: '${engine.level}/3'),
              _Counter(label: 'PUNTOS', value: '${engine.score}'),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(7),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: engine.status == PianoGameStatus.ready
                    ? 0
                    : engine.progress.clamp(0, 1),
                backgroundColor: const Color(0xFFE7E0EF),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFFC857)),
              ),
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              _boardHeight = constraints.maxHeight;
              final laneWidth =
                  constraints.maxWidth / PianoTilesEngine.laneCount;
              return Stack(children: [
                Row(
                  children: List.generate(
                    PianoTilesEngine.laneCount,
                    (lane) => Expanded(
                      child: GestureDetector(
                        key: Key('piano-lane-$lane'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _tapLane(lane),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color: _errorLane == lane
                                ? const Color(0xFFFFCDD2)
                                : lane.isEven
                                    ? Colors.white
                                    : const Color(0xFFFAF8FC),
                            border: const Border(
                              right: BorderSide(
                                  color: Color(0xFFD8D2DF), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: constraints.maxHeight * PianoTilesEngine.hitZoneStart,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFFFC857).withValues(alpha: .05),
                            const Color(0xFFFFC857).withValues(alpha: .18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ...engine.tiles.map((tile) => Positioned(
                      key: ValueKey(tile.id),
                      top: tile.y,
                      left: tile.lane * laneWidth + 5,
                      width: laneWidth - 10,
                      height: PianoTilesEngine.tileHeight,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF251A45), Color(0xFF4D347D)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF6F52A2), width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 7,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: Icon(Icons.music_note_rounded,
                                  color: Color(0xFFFFD978), size: 30),
                            ),
                          ),
                        ),
                      ),
                    )),
                if (engine.status == PianoGameStatus.playing)
                  Positioned(
                    top: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _showLevel
                            ? _Pill(
                                key: ValueKey(engine.level),
                                text: '¡Nivel ${engine.level}! Más rápido ⚡',
                                color: const Color(0xFFFFC857))
                            : engine.combo >= 3
                                ? _Pill(
                                    key: ValueKey(engine.combo),
                                    text: 'Combo ×${engine.combo}',
                                    color: const Color(0xFFB9F6CA))
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (engine.status != PianoGameStatus.playing)
                  _Overlay(
                    complete: engine.status == PianoGameStatus.songComplete,
                    score: engine.score,
                    best: engine.bestScore,
                    accuracy: engine.accuracy,
                    bestCombo: engine.bestCombo,
                    onStart: _start,
                  ),
              ]);
            }),
          ),
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
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      );
}

class _Overlay extends StatelessWidget {
  const _Overlay({
    required this.complete,
    required this.score,
    required this.best,
    required this.accuracy,
    required this.bestCombo,
    required this.onStart,
  });

  final bool complete;
  final int score;
  final int best;
  final double accuracy;
  final int bestCombo;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ColoredBox(
          color: const Color(0xDD251A45),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(28),
              padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(complete ? '🎉 ¡Canción completa!' : '🎹 Modo acompañado',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 31, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (complete) ...[
                  Text('$score puntos',
                      key: const Key('piano-final-score'),
                      style: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.w900)),
                  Text(
                      '${(accuracy * 100).round()}% de aciertos  •  Combo $bestCombo',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18)),
                  Text('Récord $best', style: const TextStyle(fontSize: 18)),
                ] else ...[
                  const Text(
                    'Tocá las baldosas oscuras al ritmo de la música. Los errores no cortan la canción.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, height: 1.25),
                  ),
                  const SizedBox(height: 10),
                  const Text('3 niveles • cada vez más rápido',
                      style: TextStyle(
                          color: Color(0xFF6F52A2),
                          fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  key: const Key('piano-start'),
                  onPressed: onStart,
                  icon: Icon(complete
                      ? Icons.replay_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(complete ? 'Tocar otra vez' : 'Empezar',
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),
        ),
      );
}
