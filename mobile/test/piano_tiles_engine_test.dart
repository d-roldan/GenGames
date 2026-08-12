import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/games/piano_tiles_game/piano_tiles_engine.dart';

void main() {
  const height = 800.0;

  test('starts with a continuous queue of playable tiles', () {
    final engine = PianoTilesEngine(random: math.Random(4))..start(height);

    expect(engine.tiles, hasLength(PianoTilesEngine.initialTileCount));
    expect(engine.status, PianoGameStatus.playing);
    expect(engine.tiles.map((tile) => tile.id).toSet(), hasLength(7));
  });

  test('valid tiles build score and speed increases after a level', () {
    final engine = PianoTilesEngine(random: math.Random(4))..start(height);
    final initialSpeed = engine.speed;

    for (var i = 0; i < PianoTilesEngine.tilesPerLevel; i++) {
      final tile = engine.tiles.first;
      engine.tiles[0] = tile.copyWith(y: height * .66);
      expect(engine.tap(tile.lane, height), isTrue);
    }

    expect(engine.hits, PianoTilesEngine.tilesPerLevel);
    expect(engine.level, 2);
    expect(engine.speed, greaterThan(initialSpeed));
    expect(engine.combo, PianoTilesEngine.tilesPerLevel);
    expect(engine.status, PianoGameStatus.playing);
  });

  test('wrong taps reset the combo but do not end the song', () {
    final engine = PianoTilesEngine(random: math.Random(2))..start(height);

    expect(engine.tap(engine.tiles.first.lane, height), isTrue);
    expect(engine.tap((engine.tiles.first.lane + 1) % 4, height), isFalse);

    expect(engine.mistakes, 1);
    expect(engine.combo, 0);
    expect(engine.status, PianoGameStatus.playing);
  });

  test('missed tiles are counted and the song keeps flowing', () {
    final engine = PianoTilesEngine(random: math.Random(1))..start(height);

    final result = engine.tick(10, height);

    expect(result.missed, greaterThan(0));
    expect(engine.misses, result.missed);
    expect(engine.status, PianoGameStatus.playing);
    expect(engine.tiles, isNotEmpty);
  });

  test('the song ends only after all tiles have been processed', () {
    final engine = PianoTilesEngine(random: math.Random(8))..start(height);

    for (var i = 0; i < PianoTilesEngine.songTileCount; i++) {
      final tile = engine.tiles.first;
      engine.tiles[0] = tile.copyWith(y: height * .66);
      expect(engine.tap(tile.lane, height), isTrue);
    }

    expect(engine.status, PianoGameStatus.songComplete);
    expect(engine.hits, PianoTilesEngine.songTileCount);
    expect(engine.progress, 1);
  });
}
