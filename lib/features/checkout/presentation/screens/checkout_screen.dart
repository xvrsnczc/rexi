import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../activity/data/activity_repository.dart';
import '../../data/checkout_repository.dart';

/// Checkout tras el carrito — confirma pedido en Supabase (`Órdenes` + `order_items`).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _submitting = false;

  Future<void> _confirm(BuildContext context) async {
    setState(() => _submitting = true);
    final result = await CheckoutRepository.instance.placeOrderFromCart();
    if (!context.mounted) return;
    setState(() => _submitting = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido registrado: ${result.orderId}')),
      );
      context.go(AppRoutes.orders);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Error al confirmar'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: FutureBuilder(
        future: ActivityRepository.instance.cartLines(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lines = snap.data ?? [];
          if (lines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tu carrito está vacío.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Volver a la tienda'),
                    ),
                  ],
                ),
              ),
            );
          }
          final subtotal = lines.fold<double>(
            0,
            (sum, line) => sum + line.quantity * line.unitPrice,
          );
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Resumen del pedido',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (final line in lines)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(line.title),
                        subtitle: Text('Cantidad: ${line.quantity}'),
                        trailing: Text(
                          '\$${(line.quantity * line.unitPrice).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Total estimado'),
                      trailing: Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: _submitting ? null : () => _confirm(context),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Confirmar pedido'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _submitting ? null : () => context.pop(),
                        child: const Text('Volver al carrito'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
