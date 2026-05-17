import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../data/activity_repository.dart';
import '../domain/order_line_model.dart';
import '../domain/order_model.dart';
import '../../store/presentation/product_detail_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido ${order.id}')),
      body: FutureBuilder<List<OrderLineModel>>(
        future: ActivityRepository.instance.orderLinesForOrder(order.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las líneas:\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final lines = snap.data ?? [];
          final linesSubtotal =
              lines.fold<double>(0, (s, l) => s + l.lineTotal);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Estado'),
                subtitle: Text(order.status),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Total (pedido)'),
                subtitle: Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 32),
              Text(
                'Productos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              if (lines.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'No hay líneas en order_items o no tienes permiso (RLS). '
                    'Si el FK usa otro nombre, revisa ActivityRepository.orderLinesForOrder.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                )
              else ...[
                for (final line in lines)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(line.title),
                      subtitle: Text('Cantidad: ${line.quantity} × \$${line.unitPrice.toStringAsFixed(2)}'),
                      trailing: Text(
                        '\$${line.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => ProductDetailScreen(
                              productId: line.productId,
                              title: line.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suma líneas',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '\$${linesSubtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ],
                ),
                if ((order.total - linesSubtotal).abs() > 0.02)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'El total del pedido puede incluir envío u otros cargos no listados en líneas.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.app),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Volver al inicio (tienda)'),
              ),
            ],
          );
        },
      ),
    );
  }
}
