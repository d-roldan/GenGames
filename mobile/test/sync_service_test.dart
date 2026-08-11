import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kids_game/core/analytics/analytics_service.dart';
import 'package:kids_game/core/network/api_client.dart';
import 'package:kids_game/core/storage/local_database.dart';
import 'package:kids_game/core/sync/sync_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('acknowledges confirmed events after connectivity returns', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    await AnalyticsService(db).track('app_opened');
    final queuedId = (await db.pending()).single['id'];
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/installations')) {
        return http.Response(
            jsonEncode({
              'registered': true,
              'installation_uuid': await db.installationId
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'accepted': [queuedId]
          }),
          200);
    });
    final result = await SyncService(
            database: db, api: ApiClient('http://local/api/v1', client: client))
        .synchronize();
    expect(result, isTrue);
    expect(await db.pendingCount(), 0);
    await db.close();
  });

  test('server timeout keeps queue without throwing', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    await AnalyticsService(db).track('app_opened');
    final client = MockClient((_) async => http.Response('unavailable', 503));
    expect(
        await SyncService(
                database: db,
                api: ApiClient('http://local/api/v1', client: client))
            .synchronize(),
        isFalse);
    expect(await db.pendingCount(), 1);
    expect((await db.pending()).single['attempts'], 1);
    await db.close();
  });
}
