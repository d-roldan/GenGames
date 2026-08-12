import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_services.dart';
import 'piano_song.dart';
import 'piano_tiles_engine.dart';

class PianoTilesGameScreen extends StatefulWidget {
  const PianoTilesGameScreen(this.services, {super.key});

  final AppServices services;

  @override
  State<PianoTilesGameScreen> createState() => _PianoTilesGameScreenState();
}

class _PianoTilesGameScreenState extends State<PianoTilesGameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _songClock = Stopwatch();
  PianoSong? _song;
  PianoTilesEngine? _engine;
  final Set<int> _holdingLanes = {};
  int? _errorLane;
  String? _judgment;
  int _pointsGained = 0;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration _) {
    final engine = _engine;
    final targetTime =
        _songClock.elapsedMicroseconds / Duration.microsecondsPerSecond;
    final delta = targetTime - (engine?.time ?? 0);
    if (engine?.status != PianoGameStatus.playing || delta <= 0) return;
    final result = engine!.tick(delta);
    _holdingLanes.removeWhere(
      (lane) => !engine.notes.any(
        (note) =>
            note.beat.lane == lane && note.state == PianoNoteState.holding,
      ),
    );
    if (result.missed > 0) _showFeedback(PianoJudgment.miss, 0);
    if (result.judgment != null && result.points > 0) {
      _showFeedback(result.judgment!, result.points);
    }
    if (result.songCompleted) _finish();
    if (mounted) setState(() {});
  }

  void _selectSong(PianoSong song) {
    _song = song;
    _engine = PianoTilesEngine(song);
    _songClock.reset();
    setState(() {});
  }

  Future<void> _start() async {
    final song = _song!;
    final saved =
        await widget.services.database.setting('piano_tiles_best_${song.id}');
    await widget.services.audio.startPianoMusic(song.asset);
    if (!mounted) return;
    _engine!.start(previousBest: int.tryParse(saved ?? '') ?? 0);
    _songClock
      ..reset()
      ..start();
    _holdingLanes.clear();
    unawaited(widget.services.analytics.track('piano_song_started',
        gameId: 'piano_tiles', metadata: {'song': song.id, 'bpm': song.bpm}));
    setState(() {});
  }

  void _pressLane(int lane) {
    final engine = _engine;
    if (engine?.status != PianoGameStatus.playing) return;
    final result = engine!.press(lane);
    if (result.holdStarted) _holdingLanes.add(lane);
    if (result.accepted) {
      HapticFeedback.lightImpact();
      unawaited(widget.services.audio.playPianoNote(engine.processed));
    } else {
      _errorLane = lane;
      HapticFeedback.selectionClick();
    }
    _showFeedback(result.judgment, result.points);
    setState(() {});
  }

  void _releaseLane(int lane) {
    if (!_holdingLanes.remove(lane)) return;
    final result = _engine!.release(lane);
    if (result.accepted) HapticFeedback.mediumImpact();
    _showFeedback(result.judgment, result.points);
    setState(() {});
  }

  void _showFeedback(PianoJudgment judgment, int points) {
    _judgment = switch (judgment) {
      PianoJudgment.perfect => 'PERFECT',
      PianoJudgment.great => 'GREAT',
      PianoJudgment.good => 'GOOD',
      PianoJudgment.miss => 'MISS',
    };
    _pointsGained = points;
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 520), () {
      if (mounted) {
        setState(() {
          _judgment = null;
          _pointsGained = 0;
          _errorLane = null;
        });
      }
    });
  }

  void _finish() {
    final engine = _engine!;
    _songClock.stop();
    _holdingLanes.clear();
    unawaited(widget.services.audio.stopPianoMusic());
    HapticFeedback.heavyImpact();
    unawaited(widget.services.analytics
        .track('piano_song_finished', gameId: 'piano_tiles', metadata: {
      'song': engine.song.id,
      'score': engine.score,
      'accuracy': engine.accuracy,
      'best_combo': engine.bestCombo,
    }));
    unawaited(_saveBest());
  }

  Future<void> _saveBest() async {
    final engine = _engine!;
    final key = 'piano_tiles_best_${engine.song.id}';
    final old =
        int.tryParse(await widget.services.database.setting(key) ?? '') ?? 0;
    if (engine.bestScore > old) {
      await widget.services.database.setSetting(key, '${engine.bestScore}');
    }
  }

  void _back() {
    if (_song == null) {
      Navigator.of(context).pop();
      return;
    }
    unawaited(widget.services.audio.stopPianoMusic());
    _song = null;
    _engine = null;
    setState(() {});
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _songClock.stop();
    _ticker.dispose();
    unawaited(widget.services.audio.stopPianoMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _song;
    if (song == null) return _buildSongLibrary();
    return _buildGame(song, _engine!);
  }

  Widget _buildSongLibrary() => Scaffold(
        backgroundColor: const Color(0xFF140D2B),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          leading: BackButton(onPressed: _back),
          title: const Text('Elegí una canción'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              const Text('RHYTHM STAGE',
                  style: TextStyle(
                      color: Color(0xFFFFD45C),
                      fontSize: 15,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w900)),
              const Text('Sentí cada beat',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Pop, rock y sonidos modernos creados para GenGames.',
                  style: TextStyle(color: Colors.white70, fontSize: 17)),
              const SizedBox(height: 22),
              ...pianoSongs.map((song) => _SongCard(
                    song: song,
                    onPressed: () => _selectSong(song),
                  )),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🎵 Todas las canciones son originales y funcionan sin conexión.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildGame(PianoSong song, PianoTilesEngine engine) => Scaffold(
        backgroundColor: const Color(0xFF110B24),
        appBar: AppBar(
          leading: BackButton(onPressed: _back),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(song.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text('${song.genre} • ${song.bpm} BPM',
                style: const TextStyle(fontSize: 11)),
          ]),
          actions: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('PUNTOS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text('${engine.score}',
                    key: ValueKey(engine.score),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: engine.progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(song.colors.first),
            ),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          final hitY = constraints.maxHeight * PianoTilesEngine.hitLine;
          final laneWidth = constraints.maxWidth / PianoTilesEngine.laneCount;
          return Stack(children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    song.colors.last.withValues(alpha: .34),
                    const Color(0xFF110B24)
                  ],
                ),
              ),
              child: Row(
                children: List.generate(
                  PianoTilesEngine.laneCount,
                  (lane) => Expanded(
                    child: GestureDetector(
                      key: Key('rhythm-lane-$lane'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _pressLane(lane),
                      onTapUp: (_) => _releaseLane(lane),
                      onTapCancel: () => _releaseLane(lane),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: _errorLane == lane
                              ? Colors.red.withValues(alpha: .32)
                              : Colors.transparent,
                          border: const Border(
                            right: BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: hitY,
              left: 0,
              right: 0,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD45C),
                  boxShadow: [
                    BoxShadow(color: song.colors.first, blurRadius: 12)
                  ],
                ),
              ),
            ),
            if (engine.status == PianoGameStatus.playing)
              ...engine.activeNotes.expand((note) {
                final beat = note.beat;
                final remaining = beat.time - engine.time;
                var bottom = hitY - remaining / song.approachTime * hitY;
                var height = PianoTilesEngine.tapHeight;
                if (beat.kind == PianoNoteKind.hold) {
                  final remainingHold = note.state == PianoNoteState.holding
                      ? math.max(0.0, beat.time + beat.duration - engine.time)
                      : beat.duration;
                  height += remainingHold / song.approachTime * hitY;
                  if (note.state == PianoNoteState.holding) bottom = hitY;
                }
                final top = bottom - height;
                if (bottom < -20 || top > constraints.maxHeight) {
                  return const <Widget>[];
                }
                return [
                  Positioned(
                    key: ValueKey(beat.id),
                    left: beat.lane * laneWidth + 5,
                    top: top,
                    width: laneWidth - 10,
                    height: height,
                    child: IgnorePointer(
                      child: _RhythmTile(
                        note: note,
                        colors: song.colors,
                      ),
                    ),
                  )
                ];
              }),
            if (engine.status == PianoGameStatus.playing)
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Column(children: [
                  Text('COMBO ×${engine.combo}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 130),
                    child: _judgment == null
                        ? const SizedBox(height: 54)
                        : Text(
                            '$_judgment${_pointsGained > 0 ? '  +$_pointsGained' : ''}',
                            key: ValueKey(
                                '$_judgment-$_pointsGained-${engine.processed}'),
                            style: TextStyle(
                              color: _judgment == 'MISS'
                                  ? Colors.redAccent
                                  : const Color(0xFFFFD45C),
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 8)
                              ],
                            ),
                          ),
                  ),
                ]),
              ),
            if (engine.status != PianoGameStatus.playing)
              _GameOverlay(engine: engine, song: song, onStart: _start),
          ]);
        }),
      );
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song, required this.onPressed});
  final PianoSong song;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: song.colors),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: song.colors.last.withValues(alpha: .35), blurRadius: 16)
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    song.genre == 'ROCK'
                        ? Icons.electric_bolt_rounded
                        : song.genre == 'POP'
                            ? Icons.favorite_rounded
                            : Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 39,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.genre,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w900)),
                        Text(song.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                        Text(song.subtitle,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 7),
                        Row(children: [
                          Text('${song.bpm} BPM',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          ...List.generate(
                              3,
                              (index) => Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: index < song.difficulty
                                        ? const Color(0xFFFFD45C)
                                        : Colors.white30,
                                  )),
                        ]),
                      ]),
                ),
                const Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 46),
              ]),
            ),
          ),
        ),
      );
}

class _RhythmTile extends StatelessWidget {
  const _RhythmTile({required this.note, required this.colors});
  final PianoRuntimeNote note;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF20163B), colors.last],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: note.beat.isDouble
                  ? const Color(0xFF57F5FF)
                  : const Color(0xFFFFD45C),
              width: note.beat.isDouble ? 4 : 2),
          boxShadow: [
            BoxShadow(
                color: colors.first.withValues(alpha: .45), blurRadius: 10)
          ],
        ),
        child: Stack(children: [
          if (note.beat.kind == PianoNoteKind.hold)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Column(children: [
                Icon(Icons.pan_tool_alt_rounded, color: Colors.white, size: 30),
                Text('MANTENER',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          if (note.beat.isDouble)
            const Positioned(
              top: 10,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Color(0xFF57F5FF), shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Text('×2',
                      style: TextStyle(
                          color: Color(0xFF140D2B),
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          const Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Icon(Icons.music_note_rounded,
                color: Color(0xFFFFD45C), size: 31),
          ),
        ]),
      );
}

class _GameOverlay extends StatelessWidget {
  const _GameOverlay(
      {required this.engine, required this.song, required this.onStart});
  final PianoTilesEngine engine;
  final PianoSong song;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final complete = engine.status == PianoGameStatus.songComplete;
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xDF110B24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(complete ? '🏆 ${song.title}' : '🎧 ${song.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 29, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              if (complete) ...[
                Text('${engine.score} puntos',
                    key: const Key('rhythm-final-score'),
                    style: const TextStyle(
                        fontSize: 39, fontWeight: FontWeight.w900)),
                Text(
                    '${(engine.accuracy * 100).round()}% precisión • Combo ${engine.bestCombo}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18)),
                Text(
                    'Perfect ${engine.perfects}  •  Great ${engine.greats}  •  Good ${engine.goods}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6547F5))),
              ] else ...[
                Text('${song.genre} • ${song.bpm} BPM',
                    style: TextStyle(
                        color: song.colors.last, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text(
                  'Tocá al cruzar la línea dorada. Usá dos dedos en ×2 y mantené presionadas las notas largas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, height: 1.3),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const Key('rhythm-start'),
                onPressed: onStart,
                icon: Icon(
                    complete ? Icons.replay_rounded : Icons.play_arrow_rounded),
                label: Text(complete ? 'Otra vez' : 'Tocar canción',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
