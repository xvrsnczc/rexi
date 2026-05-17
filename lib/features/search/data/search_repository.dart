import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/search_result.dart';

class SearchRepository {
  SearchRepository._();

  static final SearchRepository instance = SearchRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SearchResult>> query(String q) async {
    final t = q.trim();
    if (t.isEmpty) return [];

    final pattern = '%$t%';
    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.marketplaceProducts)
          .select('id, "Nombre", "Precio"')
          .eq('Estado', 'Activo')
          .ilike('Nombre', pattern)
          .limit(40),
    );

    return rows
        .map(
          (r) => SearchResult(
            id: pickStr(r, ['id']) ?? '',
            title: pickStr(r, ['Nombre', 'nombre']) ?? 'Producto',
            type: 'Producto',
          ),
        )
        .where((e) => e.id.isNotEmpty)
        .toList();
  }
}
