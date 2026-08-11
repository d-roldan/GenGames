import 'package:flutter/material.dart';
import '../../core/services/app_services.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key, required this.services});
  final AppServices services;
  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  double volume = 1;
  late Future<_ParentData> data;
  @override
  void initState() {
    super.initState();
    data = _load();
  }

  Future<_ParentData> _load() async => _ParentData(
      await widget.services.database.stats(),
      await widget.services.database.pendingCount(),
      await widget.services.database.installedContent());
  Future<void> _sync() async {
    await widget.services.sync.synchronize();
    setState(() => data = _load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Área para adultos')),
      body: FutureBuilder<_ParentData>(
          future: data,
          builder: (_, snapshot) {
            final value = snapshot.data;
            if (value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(padding: const EdgeInsets.all(20), children: [
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Actividad local'),
                      subtitle: Text(
                          '${value.stats.values.fold<int>(0, (sum, item) => sum + item)} acciones registradas'))),
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.cloud_sync),
                      title: const Text('Pendiente de sincronizar'),
                      subtitle: Text('${value.pending} eventos'),
                      trailing: FilledButton(
                          onPressed: _sync, child: const Text('Sincronizar')))),
              Card(
                  child: Column(children: [
                const ListTile(
                    leading: Icon(Icons.volume_up), title: Text('Volumen')),
                Slider(
                    value: volume,
                    onChanged: (value) {
                      setState(() => volume = value);
                      widget.services.database.setSetting('volume', '$value');
                    })
              ])),
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.download_done),
                      title: const Text('Contenido instalado'),
                      subtitle: Text('${value.content.length} packs'))),
              const Card(
                  child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('KidsGame 0.1.1'),
                      subtitle: Text('Entorno configurado en la compilación'))),
              const SizedBox(height: 16),
              const Text('Juegos usados',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              for (final entry in value.stats.entries
                  .where((entry) => entry.key.startsWith('game:')))
                ListTile(
                    title: Text(entry.key.substring(5)),
                    trailing: Text('${entry.value}')),
            ]);
          }));
}

class _ParentData {
  const _ParentData(this.stats, this.pending, this.content);
  final Map<String, int> stats;
  final int pending;
  final List<Map<String, Object?>> content;
}
