import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/core/services/app_services.dart';
import 'package:kids_game/core/storage/local_database.dart';
import 'package:kids_game/games/animals_game/animals_game_screen.dart';
import 'package:kids_game/games/cat_game/cat_game_screen.dart';
import 'package:kids_game/games/drawing_game/drawing_game_screen.dart';
import 'package:kids_game/games/game_registry.dart';
import 'package:kids_game/games/piano_tiles_game/piano_tiles_game_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('registers four independent functional game modules', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    final services = AppServices.forTesting(db);
    expect(games.map((game) => game.id),
        ['cat_game', 'drawing_game', 'animals_game', 'piano_tiles']);
    expect(games[0].builder(services), isA<CatGameScreen>());
    expect(games[1].builder(services), isA<DrawingGameScreen>());
    expect(games[2].builder(services), isA<AnimalsGameScreen>());
    expect(games[3].builder(services), isA<PianoTilesGameScreen>());
    await db.close();
  });
}
