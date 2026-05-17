import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/delivery_local_store.dart';

/// UI del módulo repartidor (cargada con `deferred` en web para no pesar al resto de usuarios).
class RepartidorHomeScreen extends StatefulWidget {
  const RepartidorHomeScreen({super.key});

  @override
  State<RepartidorHomeScreen> createState() => _RepartidorHomeScreenState();
}

class _RepartidorHomeScreenState extends State<RepartidorHomeScreen> {
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final list = await DeliveryLocalStore.pendingItems();
    if (mounted) {
      setState(() {
        _pending = list;
        _loading = false;
      });
    }
  }

  Future<void> _addDemo() async {
    await DeliveryLocalStore.enqueuePayload({
      'type': 'entrega_demo',
      'creado': DateTime.now().toIso8601String(),
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repartidor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar vista local',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo baja señal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Las entregas guardadas aquí están en este dispositivo '
                          '(Hive/IndexedDB en web). Cuando vuelva la conexión, '
                          'envía la cola desde `data/` con Supabase.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _addDemo,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar entrega local (demo)'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cola local (${_pending.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_pending.isEmpty)
                  const Text('Sin elementos pendientes.')
                else
                  ..._pending.map(
                    (e) => ListTile(
                      title: Text(e['type']?.toString() ?? 'evento'),
                      subtitle: Text(e['creado']?.toString() ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final id = e['_localId']?.toString();
                          if (id != null) {
                            await DeliveryLocalStore.remove(id);
                            await _refresh();
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
