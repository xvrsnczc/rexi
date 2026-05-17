import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/product_model.dart';
import '../domain/seller_model.dart';

/// Catálogo desde Supabase.
///
/// **marketplace_products** — columnas usadas en código (nombres exactos en BD):
/// - `id`, `Nombre`, `Precio`, `Estado`, `visibility_mode`, `image_urls`, `seller_id`, `created_at`
///
/// Hot Deals: solo filas con **`Estado` = `'Activo'`** (sin `is_hot_deal`).
///
/// **users_profile** — `fetchNewSellers`: ids obtenidos con `seller_id` DISTINCT desde
/// [marketplace_products], luego filas de perfil con `id IN (...)`.
class StoreRepository {
  StoreRepository._(this._client);

  final SupabaseClient _client;

  static StoreRepository? _instance;

  static StoreRepository get instance {
    _instance ??= StoreRepository._(Supabase.instance.client);
    return _instance!;
  }

  /// Una fila de [marketplace_products] por `id` (activa o no; la UI puede advertir).
  Future<ProductModel?> fetchProductById(String id) async {
    if (id.isEmpty) return null;
    final row = await _client
        .from(SupabaseTables.marketplaceProducts)
        .select('id, "Nombre", "Precio", image_urls, seller_id, Estado')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _rowToProduct(Map<String, dynamic>.from(row as Map));
  }

  /// Hot Deals: [marketplace_products] con `Estado` = `'Activo'`.
  ///
  /// Proyección: `id`, `Nombre`, `Precio`, `image_urls`, `seller_id`.
  Future<List<ProductModel>> fetchHotDeals() async {
    final rows = await _client
        .from(SupabaseTables.marketplaceProducts)
        .select('id, "Nombre", "Precio", image_urls, seller_id')
        .eq('Estado', 'Activo')
        .order('created_at', ascending: false)
        .limit(40);

    return _mapProducts(supabaseAsMapList(rows));
  }

  /// 1) `seller_id` desde [marketplace_products] (únicos en cliente).
  /// 2) Perfiles en [users_profile] con `id` en ese conjunto.
  ///
  /// Select perfil: `id`, `full_name`, `avatar_url`, `created_at` (orden descendente, máx. 20).
  Future<List<SellerModel>> fetchNewSellers() async {
    final mpRows = await _client.from(SupabaseTables.marketplaceProducts).select('seller_id');
    final sellerIds = <String>{};
    for (final row in supabaseAsMapList(mpRows)) {
      final sid = row['seller_id']?.toString();
      if (sid != null && sid.isNotEmpty) sellerIds.add(sid);
    }
    if (sellerIds.isEmpty) return [];

    final idList = sellerIds.toList();
    final profRows = await _client
        .from(SupabaseTables.usersProfile)
        .select('id, full_name, avatar_url, created_at')
        .inFilter('id', idList);

    final profiles = supabaseAsMapList(profRows);
    profiles.sort((a, b) {
      final ta = _parseTimestamp(a['created_at']);
      final tb = _parseTimestamp(b['created_at']);
      return tb.compareTo(ta);
    });

    return profiles
        .take(20)
        .map(_rowToSeller)
        .where((s) => s.id.isNotEmpty)
        .toList();
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<ProductModel> _mapProducts(List<Map<String, dynamic>> rows) {
    return rows.map(_rowToProduct).where((p) => p.id.isNotEmpty).toList();
  }

  ProductModel _rowToProduct(Map<String, dynamic> row) {
    final rawPrice = row['Precio'];
    double price = 0;
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    }
    final nombre = row['Nombre'];
    final sid = row['seller_id'];
    return ProductModel(
      id: row['id']?.toString() ?? '',
      title: nombre?.toString() ?? 'Producto',
      price: price,
      imageUrls: _parseImageUrls(row['image_urls']),
      sellerId: sid?.toString(),
    );
  }

  List<String>? _parseImageUrls(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;
    final out = <String>[];
    for (final e in value) {
      if (e != null) out.add(e.toString());
    }
    return out.isEmpty ? null : out;
  }

  /// Perfil público para ficha de vendedor (`users_profile`).
  Future<({String name, String? avatarUrl})?> fetchPublicProfile(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final row = await _client
          .from(SupabaseTables.usersProfile)
          .select('id, full_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      final r = Map<String, dynamic>.from(row as Map);
      final name = pickStr(r, ['full_name', 'nombre', 'name']) ?? 'Vendedor';
      final avatar = pickStr(r, ['avatar_url', 'avatarUrl', 'foto']);
      return (name: name, avatarUrl: avatar);
    } catch (_) {
      return null;
    }
  }

  SellerModel _rowToSeller(Map<String, dynamic> row) {
    final raw = row['full_name'];
    final name = raw?.toString().trim();
    return SellerModel(
      id: row['id']?.toString() ?? '',
      name: (name == null || name.isEmpty) ? 'Vendedor' : name,
    );
  }
}
