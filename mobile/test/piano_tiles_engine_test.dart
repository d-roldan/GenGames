import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/games/piano_tiles_game/piano_tiles_engine.dart';

void main() {
  test('scores a valid tile and increases speed after each level', () {
    final engine = PianoTilesEngine(random: math.Random(4))..start();
    const height = 800.0;
    final initialSpeed = engine.speed;

    for (var i = 0; i < PianoTilesEngine.pointsPerLevel; i++) {
      final tile = engine.tile!;
      final center = height * PianoTilesEngine.hitLine;
      engine.tile = tile.copyWith(y: center - PianoTilesEngine.tileHeight / 2);
      expect(engine.tap(tile.lane, height), isTrue);
    }

    expect(engine.score, PianoTilesEngine.pointsPerLevel);
    expect(engine.level, 2);
    expect(engine.speed, greaterThan(initialSpeed));
    expect(engine.status, PianoGameStatus.playing);
  });

  test('wrong lane stops the game immediately', () {
    final engine = PianoTilesEngine(random: math.Random(2))..start();
    const height = 800.0;
    final tile = engine.tile!;
    engine.tile = tile.copyWith(
        y: height * PianoTilesEngine.hitLine - PianoTilesEngine.tileHeight / 2);

    expect(engine.tap((tile.lane + 1) % PianoTilesEngine.laneCount, height),
        isFalse);
    expect(engine.status, PianoGameStatus.gameOver);
    expect(engine.score, 0);
  });

  test('a missed tile stops the game', () {
    final engine = PianoTilesEngine(random: math.Random(1))..start();

    expect(engine.tick(10, 800), isTrue);
    expect(engine.status, PianoGameStatus.gameOver);
  });
}
