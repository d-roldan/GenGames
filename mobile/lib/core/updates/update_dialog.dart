import 'package:flutter/material.dart';

import 'update_service.dart';

Future<void> showUpdateDialog(
  BuildContext context,
  UpdateService service,
  UpdateInfo info,
) async {
  var progress = 0.0;
  var downloading = false;
  var permissionRequired = false;
  String? error;

  await showDialog<void>(
    context: context,
    barrierDismissible: !downloading,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> install() async {
          if (permissionRequired) {
            try {
              await service.resumeInstall();
            } catch (_) {
              setState(() => error = 'No se pudo abrir el instalador.');
            }
            return;
          }
          setState(() {
            downloading = true;
            error = null;
          });
          try {
            final result = await service.downloadAndInstall(
              info,
              onProgress: (value) {
                if (dialogContext.mounted) {
                  setState(() => progress = value.clamp(0, 1));
                }
              },
            );
            if (result == UpdateInstallResult.permissionRequired &&
                dialogContext.mounted) {
              setState(() {
                downloading = false;
                permissionRequired = true;
              });
            }
          } catch (_) {
            if (dialogContext.mounted) {
              setState(() {
                downloading = false;
                error =
                    'No se pudo descargar la actualización. Revisá el Wi-Fi.';
              });
            }
          }
        }

        return AlertDialog(
          title: const Text('Nueva actualización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Versión ${info.latestVersion} disponible.'),
              const SizedBox(height: 12),
              if (downloading) ...[
                LinearProgressIndicator(value: progress == 0 ? null : progress),
                const SizedBox(height: 8),
                Text('Descargando ${(progress * 100).round()}%'),
              ],
              if (permissionRequired)
                const Text(
                  'Activá “Permitir desde esta fuente”, volvé a GenGames y '
                  'presioná “Continuar instalación”.',
                ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            if (!downloading)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Más tarde'),
              ),
            FilledButton.icon(
              onPressed: downloading ? null : install,
              icon: const Icon(Icons.system_update),
              label: Text(
                permissionRequired
                    ? 'Continuar instalación'
                    : 'Descargar e instalar',
              ),
            ),
          ],
        );
      },
    ),
  );
}
