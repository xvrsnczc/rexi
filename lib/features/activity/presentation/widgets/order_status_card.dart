import 'package:flutter/material.dart';

import '../../domain/order_model.dart';

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({super.key, required this.order, this.onTap});

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Pedido ${order.id}'),
        subtitle: Text(order.status),
        trailing: Text('\$${order.total.toStringAsFixed(2)}'),
        onTap: onTap,
      ),
    );
  }
}
