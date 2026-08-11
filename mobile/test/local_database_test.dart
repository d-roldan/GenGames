import 'package:flutter_test/flutter_test.dart';
import 'package:kids_game/core/analytics/analytics_service.dart';
import 'package:kids_game/core/storage/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('persists anonymous installation and queues events offline', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    final id = await db.installationId;
    await AnalyticsService(db).track('cat_interaction',
        gameId: 'cat_game', metadata: {'interaction': 'head'});
    expect(id, isNotEmpty);
    expect(await db.installationId, id);
    expect(await db.pendingCount(), 1);
    expect((await db.stats())['game:cat_game'], 1);
    await db.close();
  });
}
