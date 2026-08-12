import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../config/app_version.dart';
import '../network/api_client.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUri,
    this.downloadSize,
  });

  final String currentVersion;
  final String latestVersion;
  final Uri downloadUri;
  final int? downloadSize;
}

enum UpdateInstallResult { installerOpened, permissionRequired }

class UpdateService {
  UpdateService(this.api, {http.Client? client})
      : client = client ?? http.Client();

  static const _channel = MethodChannel('com.kidsgame.app/updater');

  final ApiClient api;
  final http.Client client;

  Future<UpdateInfo?> check() async {
    if (!Platform.isAndroid) return null;
    final data = await api.getMap('/version?platform=android');
    final latest = data['latest_version'] as String;
    final download = data['download_url'] as String?;
    if (download == null || compareVersions(latest, currentAppVersion) <= 0) {
      return null;
    }
    return UpdateInfo(
      currentVersion: currentAppVersion,
      latestVersion: latest,
      downloadUri: Uri.parse(api.baseUrl).resolve(download),
      downloadSize: data['download_size'] as int?,
    );
  }

  Future<UpdateInstallResult> downloadAndInstall(
    UpdateInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', info.downloadUri);
    final response =
        await client.send(request).timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }

    final directory = Directory(
      '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}updates',
    );
    await directory.create(recursive: true);
    final apk =
        File('${directory.path}${Platform.pathSeparator}gengames-update.apk');
    final sink = apk.openWrite();
    final total = response.contentLength ?? info.downloadSize ?? 0;
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }

    final allowed =
        await _channel.invokeMethod<bool>('canInstallPackages') ?? false;
    if (!allowed) {
      await _channel.invokeMethod<void>('openInstallPermission');
      return UpdateInstallResult.permissionRequired;
    }
    await _channel.invokeMethod<void>('installApk', {'path': apk.path});
    return UpdateInstallResult.installerOpened;
  }

  Future<void> resumeInstall() async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}updates',
    );
    final apk =
        File('${directory.path}${Platform.pathSeparator}gengames-update.apk');
    if (apk.existsSync()) {
      await _channel.invokeMethod<void>('installApk', {'path': apk.path});
    }
  }
}

int compareVersions(String left, String right) {
  final a = left.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final b = right.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final length = a.length > b.length ? a.length : b.length;
  for (var index = 0; index < length; index++) {
    final av = index < a.length ? a[index] : 0;
    final bv = index < b.length ? b[index] : 0;
    if (av != bv) return av.compareTo(bv);
  }
  return 0;
}
