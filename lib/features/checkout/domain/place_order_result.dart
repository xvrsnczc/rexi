/// Resultado de confirmar pedido desde el carrito.
class PlaceOrderResult {
  const PlaceOrderResult.success(String id)
      : orderId = id,
        errorMessage = null;

  const PlaceOrderResult.failure(String message)
      : orderId = null,
        errorMessage = message;

  final String? orderId;
  final String? errorMessage;

  bool get isSuccess => orderId != null && orderId!.isNotEmpty;
}
