import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class LocalDatabase {
  LocalDatabase._(this.db);
  final Database db;

  static Future<LocalDatabase> open({String? path}) async {
    final actualPath = path ?? p.join((await getApplicationSupportDirectory()).path, 'gengames.sqlite3');
    final database = await openDatabase(actualPath, version: 1, onCreate: (db, _) async {
      await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      await db.execute('CREATE TABLE stats (key TEXT PRIMARY KEY, value INTEGER NOT NULL DEFAULT 0)');
      await db.execute('CREATE TABLE sync_queue (id TEXT PRIMARY KEY, event_type TEXT NOT NULL, game_id TEXT, metadata TEXT NOT NULL, created_at TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, next_attempt_at TEXT)');
      await db.execute('CREATE TABLE content_versions (content_id TEXT PRIMARY KEY, version INTEGER NOT NULL, checksum TEXT NOT NULL, file_path TEXT NOT NULL, installed_at TEXT NOT NULL)');
    });
    final result = LocalDatabase._(database);
    await result.installationId;
    return result;
  }

  Future<String> get installationId async {
    final rows = await db.query('settings', where: 'key = ?', whereArgs: ['installation_id']);
    if (rows.isNotEmpty) return rows.first['value']! as String;
    final id = const Uuid().v4();
    await setSetting('installation_id', id);
    return id;
  }

  Future<void> setSetting(String key, String value) => db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<String?> setting(String key) async {
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> increment(String key) async => db.transaction((txn) async {
        final rows = await txn.query('stats', where: 'key = ?', whereArgs: [key]);
        final value = rows.isEmpty ? 1 : (rows.first['value']! as int) + 1;
        await txn.insert('stats', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
      });

  Future<Map<String, int>> stats() async => {for (final row in await db.query('stats')) row['key']! as String: row['value']! as int};

  Future<void> enqueue({required String id, required String eventType, String? gameId, Map<String, Object?> metadata = const {}}) => db.insert('sync_queue', {'id': id, 'event_type': eventType, 'game_id': gameId, 'metadata': jsonEncode(metadata), 'created_at': DateTime.now().toUtc().toIso8601String(), 'attempts': 0});

  Future<List<Map<String, Object?>>> pending({int limit = 50}) => db.query('sync_queue', orderBy: 'created_at', limit: limit);

  Future<int> pendingCount() async => Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sync_queue')) ?? 0;

  Future<void> acknowledge(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final marks = List.filled(ids.length, '?').join(',');
    await db.delete('sync_queue', where: 'id IN ($marks)', whereArgs: ids.toList());
  }

  Future<void> markFailed(Iterable<String> ids) async {
    final next = DateTime.now().toUtc().add(const Duration(seconds: 30)).toIso8601String();
    for (final id in ids) {
      await db.rawUpdate('UPDATE sync_queue SET attempts = attempts + 1, next_attempt_at = ? WHERE id = ?', [next, id]);
    }
  }

  Future<void> saveContent({required String id, required int version, required String checksum, required String path}) => db.insert('content_versions', {'content_id': id, 'version': version, 'checksum': checksum, 'file_path': path, 'installed_at': DateTime.now().toUtc().toIso8601String()}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Map<String, Object?>>> installedContent() => db.query('content_versions', orderBy: 'installed_at DESC');
  Future<void> close() => db.close();
}

