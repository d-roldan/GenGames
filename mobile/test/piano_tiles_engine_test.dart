import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/games/piano_tiles_game/piano_song.dart';
import 'package:kids_game/games/piano_tiles_game/piano_tiles_engine.dart';

void main() {
  test('catalog has three original songs with genuinely different speeds', () {
    expect(pianoSongs.map((song) => song.genre), ['POP', 'ROCK', 'ELECTROPOP']);
    expect(pianoSongs.map((song) => song.bpm), [96, 124, 148]);
    expect(pianoSongs.map((song) => song.approachTime),
        orderedEquals([2.25, 1.78, 1.4]));
    final densities =
        pianoSongs.map((song) => song.notes.length / song.duration).toList();
    expect(densities[0], lessThan(densities[1]));
    expect(densities[1], lessThan(densities[2]));
  });

  test('every map includes regular, double and hold notes', () {
    for (final song in pianoSongs) {
      expect(song.notes.any((note) => note.kind == PianoNoteKind.tap), isTrue);
      expect(song.notes.any((note) => note.kind == PianoNoteKind.hold), isTrue);
      expect(song.notes.any((note) => note.isDouble), isTrue);
    }
  });

  test('an exactly timed note gives a perfect and raises score', () {
    final engine = PianoTilesEngine(pianoSongs.first)..start();
    final first = pianoSongs.first.notes.first;
    engine.tick(first.time);

    final result = engine.press(first.lane);

    expect(result.accepted, isTrue);
    expect(result.judgment, PianoJudgment.perfect);
    expect(result.points, greaterThanOrEqualTo(100));
    expect(engine.score, result.points);
    expect(engine.combo, 1);
  });

  test('double notes require both lanes and award two hits', () {
    final song = pianoSongs.first;
    final pair = song.notes.where((note) => note.doubleGroup != null).toList();
    final group = pair.first.doubleGroup;
    final doubleNotes =
        pair.where((note) => note.doubleGroup == group).toList();
    final engine = PianoTilesEngine(song)..start();
    engine.tick(doubleNotes.first.time);

    final first = engine.press(doubleNotes[0].lane);
    final second = engine.press(doubleNotes[1].lane);

    expect(first.accepted, isTrue);
    expect(second.accepted, isTrue);
    expect(engine.combo, 2);
  });

  test('a hold note must remain pressed until its marked ending', () {
    final song = pianoSongs.first;
    final hold =
        song.notes.firstWhere((note) => note.kind == PianoNoteKind.hold);
    final engine = PianoTilesEngine(song)..start();
    engine.tick(hold.time);

    expect(engine.press(hold.lane).holdStarted, isTrue);
    engine.tick(hold.duration - .1);
    final released = engine.release(hold.lane);

    expect(released.accepted, isTrue);
    expect(released.points, greaterThan(100));
  });

  test('a hold kept down completes on its tail and reports its points', () {
    final song = pianoSongs.first;
    final hold =
        song.notes.firstWhere((note) => note.kind == PianoNoteKind.hold);
    final engine = PianoTilesEngine(song)..start();
    engine.tick(hold.time);
    engine.press(hold.lane);

    final tick = engine.tick(hold.duration);

    expect(tick.judgment, PianoJudgment.perfect);
    expect(tick.points, greaterThan(100));
    expect(engine.notes[hold.id].state, PianoNoteState.hit);
  });

  test('releasing a hold too early records a miss without ending the song', () {
    final song = pianoSongs.first;
    final hold =
        song.notes.firstWhere((note) => note.kind == PianoNoteKind.hold);
    final engine = PianoTilesEngine(song)..start();
    engine.tick(hold.time);
    engine.press(hold.lane);

    final released = engine.release(hold.lane);

    expect(released.accepted, isFalse);
    expect(engine.misses, greaterThan(0));
    expect(engine.status, PianoGameStatus.playing);
  });

  test('missed notes keep the track running and the song completes at its end',
      () {
    final song = pianoSongs.last;
    final engine = PianoTilesEngine(song)..start();

    engine.tick(5);
    expect(engine.misses, greaterThan(0));
    expect(engine.status, PianoGameStatus.playing);

    engine.tick(song.duration);
    expect(engine.status, PianoGameStatus.songComplete);
    expect(engine.processed, song.notes.length);
  });
}
