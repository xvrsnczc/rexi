import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Cola local para repartidor (web: IndexedDB vía Hive). Sin duplicar lógica de red aquí.
class DeliveryLocalStore {
  DeliveryLocalStore._();

  static const _boxName = 'delivery_outbox';
  static bool _opened = false;
  static Completer<void>? _opening;

  static Future<void> ensureReady() async {
    if (_opened) return;
    if (_opening != null) return _opening!.future;
    final c = Completer<void>();
    _opening = c;
    try {
      await Hive.initFlutter();
      await Hive.openBox<String>(_boxName);
      _opened = true;
      c.complete();
    } catch (e, st) {
      _opening = null;
      c.completeError(e, st);
      rethrow;
    }
  }

  static Future<void> enqueuePayload(Map<String, dynamic> payload) async {
    await ensureReady();
    final box = Hive.box<String>(_boxName);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, jsonEncode(payload));
  }

  static Future<List<Map<String, dynamic>>> pendingItems() async {
    await ensureReady();
    final box = Hive.box<String>(_boxName);
    final out = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        map['_localId'] = key;
        out.add(map);
      } catch (_) {}
    }
    return out;
  }

  static Future<void> remove(String localId) async {
    await ensureReady();
    await Hive.box<String>(_boxName).delete(localId);
  }
}
