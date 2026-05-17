class CartModel {
  const CartModel({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String title;
  final int quantity;
  final double unitPrice;
}
