import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../network/api_client.dart';
import '../storage/local_database.dart';

class ContentService {
  ContentService(
      {required this.database, required this.api, http.Client? client})
      : client = client ?? http.Client();
  final LocalDatabase database;
  final ApiClient api;
  final http.Client client;

  Future<List<Map<String, Object?>>> manifest() async =>
      (await api.getList('/content/manifest')).cast<Map<String, Object?>>();

  Future<bool> download(Map<String, Object?> item,
      {Directory? directory}) async {
    File? temporary;
    try {
      final targetDirectory = directory ??
          Directory(
              p.join((await getApplicationSupportDirectory()).path, 'content'));
      await targetDirectory.create(recursive: true);
      final id = item['content_id']! as String;
      final target = File(p.join(targetDirectory.path, '$id.pack'));
      temporary = File('${target.path}.download');
      final response = await client
          .get(Uri.parse(item['download_url']! as String))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        return false;
      }
      await temporary.writeAsBytes(response.bodyBytes, flush: true);
      final digest = sha256.convert(await temporary.readAsBytes()).toString();
      if (digest != item['checksum']) {
        return false;
      }
      if (await target.exists()) {
        await target.delete();
      }
      await temporary.rename(target.path);
      await database.saveContent(
          id: id,
          version: item['version']! as int,
          checksum: digest,
          path: target.path);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (temporary != null && await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
