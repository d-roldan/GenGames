import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> defaultDatabasePath() async =>
    p.join((await getApplicationSupportDirectory()).path, 'gengames.sqlite3');
