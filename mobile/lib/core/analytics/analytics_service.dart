import 'package:uuid/uuid.dart';
import '../storage/local_database.dart';

class AnalyticsService {
  AnalyticsService(this.database);
  final LocalDatabase database;

  Future<void> track(String eventType, {String? gameId, Map<String, Object?> metadata = const {}}) async {
    await database.enqueue(id: const Uuid().v4(), eventType: eventType, gameId: gameId, metadata: metadata);
    await database.increment('event:$eventType');
    if (gameId != null) await database.increment('game:$gameId');
  }
}

