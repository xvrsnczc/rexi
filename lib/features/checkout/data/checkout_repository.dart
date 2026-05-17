import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../../activity/data/activity_repository.dart';
import '../domain/place_order_result.dart';

/// Crea un pedido en [SupabaseTables.ordenes] y líneas en [SupabaseTables.orderItems].
///
/// Columnas esperadas en **`order_items`**: `order_id`, `product_id`, `quantity`, `unit_price`.
/// En **`Órdenes`**: `user_id`, `Total`, `Estado` (se envía `pendiente`).
/// Si tu esquema usa otros nombres, ajusta los mapas de [placeOrderFromCart] aquí.
class CheckoutRepository {
  CheckoutRepository._(this._client);

  final SupabaseClient _client;

  static CheckoutRepository? _instance;

  static CheckoutRepository get instance {
    _instance ??= CheckoutRepository._(Supabase.instance.client);
    return _instance!;
  }

  String? get _uid => _client.auth.currentUser?.id;

  Future<PlaceOrderResult> placeOrderFromCart() async {
    final uid = _uid;
    if (uid == null) {
      return const PlaceOrderResult.failure('Inicia sesión para confirmar el pedido.');
    }

    final lines = await ActivityRepository.instance.cartLines();
    if (lines.isEmpty) {
      return const PlaceOrderResult.failure('El carrito está vacío.');
    }

    final subtotal = lines.fold<double>(
      0,
      (sum, line) => sum + line.quantity * line.unitPrice,
    );

    String? createdOrderId;
    try {
      final orderRow = await _client
          .from(SupabaseTables.ordenes)
          .insert({
            'user_id': uid,
            'Total': subtotal,
            'Estado': 'pendiente',
          })
          .select('id')
          .single();

      createdOrderId = pickStr(
        Map<String, dynamic>.from(orderRow as Map),
        ['id'],
      );
      if (createdOrderId == null || createdOrderId.isEmpty) {
        return const PlaceOrderResult.failure('No se obtuvo el id del pedido.');
      }

      for (final line in lines) {
        await _client.from(SupabaseTables.orderItems).insert({
          'order_id': createdOrderId,
          'product_id': line.productId,
          'quantity': line.quantity,
          'unit_price': line.unitPrice,
        });
      }

      await ActivityRepository.instance.clearCart();
      return PlaceOrderResult.success(createdOrderId);
    } catch (e) {
      if (createdOrderId != null && createdOrderId.isNotEmpty) {
        try {
          await _client.from(SupabaseTables.ordenes).delete().eq('id', createdOrderId);
        } catch (_) {}
      }

      return PlaceOrderResult.failure(
        'No se pudo completar el pedido. Revisa RLS y columnas en Órdenes/order_items.\n$e',
      );
    }
  }
}
