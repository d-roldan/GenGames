import 'dart:convert';
import '../network/api_client.dart';
import '../storage/local_database.dart';

class SyncService {
  SyncService({required this.database, required this.api});
  final LocalDatabase database;
  final ApiClient api;
  bool _running = false;

  Future<bool> synchronize() async {
    if (_running) return false;
    _running = true;
    try {
      final installationId = await database.installationId;
      await api.post('/installations', {'installation_uuid': installationId, 'app_version': '0.1.0', 'platform': 'flutter'});
      final rows = await database.pending();
      if (rows.isEmpty) return true;
      final events = rows.map((row) => {'client_event_id': row['id'], 'installation_uuid': installationId, 'game_id': row['game_id'], 'event_type': row['event_type'], 'created_at': row['created_at'], 'metadata': jsonDecode(row['metadata']! as String)}).toList();
      final result = await api.post('/events/batch', {'events': events});
      final accepted = (result['accepted']! as List).cast<String>();
      await database.acknowledge(accepted);
      return true;
    } catch (_) {
      final rows = await database.pending();
      await database.markFailed(rows.map((row) => row['id']! as String));
      return false;
    } finally {
      _running = false;
    }
  }
}

