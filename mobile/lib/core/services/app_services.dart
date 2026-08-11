import 'dart:async';
import '../audio/audio_service.dart';
import '../analytics/analytics_service.dart';
import '../config/app_config.dart';
import '../content/content_service.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../storage/local_database.dart';
import '../sync/sync_service.dart';

class AppServices {
  AppServices._(
      {required this.config,
      required this.database,
      required this.analytics,
      required this.sync,
      required this.content,
      required this.connectivity,
      required this.audio});
  final AppConfig config;
  final LocalDatabase database;
  final AnalyticsService analytics;
  final SyncService sync;
  final ContentService content;
  final ConnectivityService connectivity;
  final AudioService audio;
  Timer? _timer;

  static Future<AppServices> create(AppConfig config,
      {LocalDatabase? database}) async {
    final db = database ?? await LocalDatabase.open();
    final api = ApiClient(config.apiUrl);
    final services = AppServices._(
        config: config,
        database: db,
        analytics: AnalyticsService(db),
        sync: SyncService(database: db, api: api),
        content: ContentService(database: db, api: api),
        connectivity: ConnectivityService(),
        audio: AudioService());
    services.connectivity.onNetworkAvailable(services.sync.synchronize);
    services._timer = Timer.periodic(
        const Duration(seconds: 30), (_) => services.sync.synchronize());
    unawaited(services.analytics.track('app_opened'));
    unawaited(services.sync.synchronize());
    return services;
  }

  static AppServices forTesting(LocalDatabase database, {ApiClient? api}) {
    final client = api ?? ApiClient('http://example.invalid/api/v1');
    return AppServices._(
      config: const AppConfig(
          environment: 'test', apiUrl: 'http://example.invalid/api/v1'),
      database: database,
      analytics: AnalyticsService(database),
      sync: SyncService(database: database, api: client),
      content: ContentService(database: database, api: client),
      connectivity: ConnectivityService(),
      audio: AudioService.silent(),
    );
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await connectivity.dispose();
    await audio.dispose();
    await database.close();
  }
}
