import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/catalog_filter_criteria.dart';

/// Preferencias de filtros en Hive (misma familia que repartidor; sin Supabase).
class CatalogFiltersRepository {
  CatalogFiltersRepository._();

  static final CatalogFiltersRepository instance = CatalogFiltersRepository._();

  static const _boxName = 'rexi_catalog_filters';
  static const _key = 'criteria_v1';
  static bool _opened = false;
  static Completer<void>? _opening;

  static Future<void> _ensureReady() async {
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

  Future<CatalogFilterCriteria> loadSaved() async {
    try {
      await _ensureReady();
      final raw = Hive.box<String>(_boxName).get(_key);
      if (raw == null || raw.isEmpty) return const CatalogFilterCriteria();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CatalogFilterCriteria.fromJson(map);
    } catch (_) {
      return const CatalogFilterCriteria();
    }
  }

  Future<void> save(CatalogFilterCriteria criteria) async {
    await _ensureReady();
    await Hive.box<String>(_boxName).put(_key, jsonEncode(criteria.toJson()));
  }
}
