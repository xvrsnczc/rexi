import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/cart_model.dart';
import '../domain/favorite_model.dart';
import '../domain/order_line_model.dart';
import '../domain/order_model.dart';

/// Carrito, pedidos y favoritos vía Supabase.
///
/// Tablas: [SupabaseTables.carro], [SupabaseTables.favoritos], [SupabaseTables.ordenes],
/// más [SupabaseTables.marketplaceProducts] para títulos y precios.
///
/// **Carro** (tu BD): `Cantidad` (entero), `product_id`, `user_id`, `created_at`.
/// **Favoritos**: `id`, `user_id`, `product_id`, `created_at`.
class ActivityRepository {
  ActivityRepository._(this._client);

  final SupabaseClient _client;

  static ActivityRepository? _instance;

  static ActivityRepository get instance {
    _instance ??= ActivityRepository._(Supabase.instance.client);
    return _instance!;
  }

  String? get _uid => _client.auth.currentUser?.id;

  Future<List<CartModel>> cartLines() async {
    final uid = _uid;
    if (uid == null) return [];

    final rows = supabaseAsMapList(
      await _client.from(SupabaseTables.carro).select('*').eq('user_id', uid),
    );

    final productIds = <String>{};
    for (final row in rows) {
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid != null && pid.isNotEmpty) productIds.add(pid);
    }
    final products = await _fetchProductMap(productIds);

    final out = <CartModel>[];
    for (final row in rows) {
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid == null || pid.isEmpty) continue;
      final p = products[pid];
      final qty = asInt(
        row['Cantidad'] ?? row['cantidad'] ?? row['quantity'] ?? row['qty'],
        1,
      );
      final unit = asDouble(
        row['precio_unitario'] ??
            row['Precio_unitario'] ??
            row['unit_price'] ??
            (p != null ? p['Precio'] : null),
      );
      final title = p != null
          ? (pickStr(p, ['Nombre', 'nombre', 'title']) ?? 'Producto')
          : 'Producto';
      out.add(
        CartModel(
          productId: pid,
          title: title,
          quantity: qty,
          unitPrice: unit,
        ),
      );
    }
    return out;
  }

  OrderModel? _rowToOrder(Map<String, dynamic> row) {
    final id = pickStr(row, ['id']) ?? '';
    if (id.isEmpty) return null;
    final status = pickStr(row, ['Estado', 'estado', 'status']) ?? '—';
    final total = asDouble(
      row['Total'] ??
          row['total'] ??
          row['monto_total'] ??
          row['Monto'] ??
          row['monto'],
    );
    return OrderModel(id: id, status: status, total: total);
  }

  /// Todos los pedidos del usuario (comprador).
  Future<List<OrderModel>> myOrders() async {
    final uid = _uid;
    if (uid == null) return [];

    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.ordenes)
          .select('*')
          .eq('user_id', uid)
          .order('id', ascending: false),
    );

    return rows.map(_rowToOrder).whereType<OrderModel>().toList();
  }

  /// Pedidos no terminados (mismo criterio que antes).
  Future<List<OrderModel>> activeOrders() async {
    const terminal = {'entregado', 'completado', 'cancelado', 'cerrado'};
    final all = await myOrders();
    return all
        .where((o) => !terminal.contains(o.status.trim().toLowerCase()))
        .toList();
  }

  /// Pedidos donde el usuario es vendedor (`seller_id` o `vendedor_id` en `Órdenes`).
  Future<List<OrderModel>> sellerOrders() async {
    final uid = _uid;
    if (uid == null) return [];

    for (final col in ['seller_id', 'vendedor_id']) {
      try {
        final rows = supabaseAsMapList(
          await _client
              .from(SupabaseTables.ordenes)
              .select('*')
              .eq(col, uid)
              .order('id', ascending: false),
        );
        final list = rows.map(_rowToOrder).whereType<OrderModel>().toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }
    return [];
  }

  /// Líneas de [SupabaseTables.orderItems] para un pedido (solo si eres comprador o vendedor).
  Future<List<OrderLineModel>> orderLinesForOrder(String orderId) async {
    final uid = _uid;
    if (uid == null || orderId.isEmpty) return [];

    final orderRows = supabaseAsMapList(
      await _client.from(SupabaseTables.ordenes).select('*').eq('id', orderId).limit(1),
    );
    if (orderRows.isEmpty) return [];

    final o = orderRows.first;
    final buyer = pickStr(o, ['user_id', 'buyer_id', 'comprador_id']);
    final seller =
        pickStr(o, ['seller_id', 'vendedor_id', 'vendor_id']) ?? pickStr(o, ['sellerId']);
    final allowed = uid == buyer || uid == seller;
    if (!allowed) return [];

    var itemRows = supabaseAsMapList(
      await _client.from(SupabaseTables.orderItems).select('*').eq('order_id', orderId),
    );
    if (itemRows.isEmpty) {
      try {
        itemRows = supabaseAsMapList(
          await _client.from(SupabaseTables.orderItems).select('*').eq('orden_id', orderId),
        );
      } catch (_) {}
    }

    final productIds = <String>{};
    for (final row in itemRows) {
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid != null && pid.isNotEmpty) productIds.add(pid);
    }
    final products = await _fetchProductMap(productIds);

    final out = <OrderLineModel>[];
    for (final row in itemRows) {
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid == null || pid.isEmpty) continue;
      final p = products[pid];
      final title = p != null
          ? (pickStr(p, ['Nombre', 'nombre', 'title']) ?? 'Producto')
          : 'Producto';
      final qty = asInt(
        row['quantity'] ?? row['Cantidad'] ?? row['cantidad'] ?? row['qty'],
        1,
      );
      final unit = asDouble(
        row['unit_price'] ??
            row['precio_unitario'] ??
            row['Precio_unitario'] ??
            row['precio'] ??
            (p != null ? p['Precio'] : null),
      );
      out.add(
        OrderLineModel(
          productId: pid,
          title: title,
          quantity: qty,
          unitPrice: unit,
        ),
      );
    }
    return out;
  }

  Future<List<FavoriteModel>> favorites() async {
    final uid = _uid;
    if (uid == null) return [];

    final rows = supabaseAsMapList(
      await _client.from(SupabaseTables.favoritos).select('*').eq('user_id', uid),
    );

    final productIds = <String>{};
    for (final row in rows) {
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid != null && pid.isNotEmpty) productIds.add(pid);
    }
    final products = await _fetchProductMap(productIds);

    final out = <FavoriteModel>[];
    for (final row in rows) {
      final favId = pickStr(row, ['id']) ?? '';
      final pid = pickStr(row, ['product_id', 'producto_id', 'productId']);
      if (pid == null || pid.isEmpty) continue;
      final p = products[pid];
      final title = p != null
          ? (pickStr(p, ['Nombre', 'nombre', 'title']) ?? 'Producto')
          : 'Producto';
      out.add(
        FavoriteModel(
          id: favId.isNotEmpty ? favId : pid,
          productId: pid,
          title: title,
          kind: pickStr(row, ['tipo', 'kind', 'type']) ?? 'producto',
        ),
      );
    }
    return out;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProductMap(Set<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.marketplaceProducts)
          .select('id, "Nombre", "Precio"')
          .inFilter('id', ids.toList()),
    );
    final map = <String, Map<String, dynamic>>{};
    for (final r in rows) {
      final id = pickStr(r, ['id']);
      if (id != null) map[id] = r;
    }
    return map;
  }

  /// Suma [delta] a la línea del carrito o inserta con `Cantidad` = [delta].
  Future<void> addToCart(String productId, {int delta = 1}) async {
    final uid = _uid;
    if (uid == null || productId.isEmpty || delta < 1) return;

    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.carro)
          .select('id, Cantidad, cantidad, quantity')
          .eq('user_id', uid)
          .eq('product_id', productId)
          .limit(1),
    );

    if (rows.isEmpty) {
      await _client.from(SupabaseTables.carro).insert({
        'user_id': uid,
        'product_id': productId,
        'Cantidad': delta,
      });
      return;
    }

    final row = rows.first;
    final current = asInt(
      row['Cantidad'] ?? row['cantidad'] ?? row['quantity'],
      0,
    );
    final next = current + delta;
    final rowId = pickStr(row, ['id']);
    if (rowId != null && rowId.isNotEmpty) {
      await _client.from(SupabaseTables.carro).update({'Cantidad': next}).eq('id', rowId);
    } else {
      await _client
          .from(SupabaseTables.carro)
          .update({'Cantidad': next})
          .eq('user_id', uid)
          .eq('product_id', productId);
    }
  }

  /// Fija la cantidad; si [quantity] es 0 o negativa, elimina la línea.
  Future<void> setCartQuantity(String productId, int quantity) async {
    final uid = _uid;
    if (uid == null || productId.isEmpty) return;
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.carro)
          .select('id')
          .eq('user_id', uid)
          .eq('product_id', productId)
          .limit(1),
    );

    if (rows.isEmpty) {
      await _client.from(SupabaseTables.carro).insert({
        'user_id': uid,
        'product_id': productId,
        'Cantidad': quantity,
      });
      return;
    }

    final rowId = pickStr(rows.first, ['id']);
    if (rowId != null && rowId.isNotEmpty) {
      await _client.from(SupabaseTables.carro).update({'Cantidad': quantity}).eq('id', rowId);
    }
  }

  Future<void> removeFromCart(String productId) async {
    final uid = _uid;
    if (uid == null || productId.isEmpty) return;
    await _client.from(SupabaseTables.carro).delete().eq('user_id', uid).eq('product_id', productId);
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    await _client.from(SupabaseTables.carro).delete().eq('user_id', uid);
  }

  Future<void> addFavorite(String productId) async {
    final uid = _uid;
    if (uid == null || productId.isEmpty) return;
    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.favoritos)
          .select('id')
          .eq('user_id', uid)
          .eq('product_id', productId)
          .limit(1),
    );
    if (rows.isNotEmpty) return;
    await _client.from(SupabaseTables.favoritos).insert({
      'user_id': uid,
      'product_id': productId,
    });
  }

  /// Quita un favorito por id de fila o por `user_id` + `product_id`.
  Future<void> removeFavorite(FavoriteModel f) async {
    final uid = _uid;
    if (uid == null) return;
    if (f.id.isNotEmpty && f.id != f.productId) {
      try {
        await _client.from(SupabaseTables.favoritos).delete().eq('id', f.id);
        return;
      } catch (_) {}
    }
    await _client.from(SupabaseTables.favoritos).delete().eq('user_id', uid).eq('product_id', f.productId);
  }
}
