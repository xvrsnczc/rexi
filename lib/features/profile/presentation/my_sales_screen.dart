import 'package:flutter/material.dart';

import '../../activity/data/activity_repository.dart';
import '../../activity/domain/order_model.dart';
import '../../activity/presentation/order_detail_screen.dart';
import '../../activity/presentation/widgets/order_status_card.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({super.key});

  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen> {
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ActivityRepository.instance.sellerOrders();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = ActivityRepository.instance.sellerOrders();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ventas')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<OrderModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            final orders = snap.data ?? [];
            if (orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Text(
                      'No hay ventas con seller_id/vendedor_id en Órdenes, o la tabla no expone esas columnas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final order = orders[i];
                return OrderStatusCard(
                  order: order,
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
