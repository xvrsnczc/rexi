class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
  });

  final String id;
  final String status;
  final double total;
}
