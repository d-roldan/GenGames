import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kids_game/core/content/content_service.dart';
import 'package:kids_game/core/network/api_client.dart';
import 'package:kids_game/core/storage/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });
  test('validates checksum and atomically installs a pack', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    final bytes = utf8.encode('animal pack');
    final dir = await Directory.systemTemp.createTemp('gengames_content_');
    final service = ContentService(database: db, api: ApiClient('http://local'), client: MockClient((_) async => http.Response.bytes(bytes, 200)));
    final installed = await service.download({'content_id': 'farm', 'version': 1, 'checksum': sha256.convert(bytes).toString(), 'download_url': 'http://local/farm'}, directory: dir);
    expect(installed, isTrue);
    expect(await File('${dir.path}${Platform.pathSeparator}farm.pack').readAsString(), 'animal pack');
    expect(await db.installedContent(), hasLength(1));
    await db.close(); await dir.delete(recursive: true);
  });

  test('bad checksum preserves an existing pack', () async {
    final db = await LocalDatabase.open(path: inMemoryDatabasePath);
    final dir = await Directory.systemTemp.createTemp('gengames_content_');
    final existing = File('${dir.path}${Platform.pathSeparator}farm.pack'); await existing.writeAsString('good');
    final service = ContentService(database: db, api: ApiClient('http://local'), client: MockClient((_) async => http.Response('corrupt', 200)));
    expect(await service.download({'content_id': 'farm', 'version': 2, 'checksum': 'bad', 'download_url': 'http://local/farm'}, directory: dir), isFalse);
    expect(await existing.readAsString(), 'good');
    await db.close(); await dir.delete(recursive: true);
  });
}

