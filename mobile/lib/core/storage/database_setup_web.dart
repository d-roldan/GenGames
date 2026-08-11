import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void configureDatabaseFactory() {
  // The shared-worker implementation can stall during browser startup on
  // some Chrome/Nginx combinations. Our workload is intentionally small, so
  // running SQLite on the UI isolate is both reliable and fast enough while
  // still persisting the database in IndexedDB.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
