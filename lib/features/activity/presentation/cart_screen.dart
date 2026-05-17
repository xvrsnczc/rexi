import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../data/activity_repository.dart';
import '../domain/cart_model.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartModel>> _cartFuture;
  String? _busyProductId;

  @override
  void initState() {
    super.initState();
    _cartFuture = ActivityRepository.instance.cartLines();
  }

  void _reload() {
    setState(() {
      _cartFuture = ActivityRepository.instance.cartLines();
    });
  }

  Future<void> _onPullRefresh() async {
    _reload();
    await _cartFuture;
  }

  Future<void> _adjustQuantity(String productId, int currentQty, int delta) async {
    setState(() => _busyProductId = productId);
    try {
      final next = currentQty + delta;
      await ActivityRepository.instance.setCartQuantity(productId, next);
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyProductId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: FutureBuilder<List<CartModel>>(
        future: _cartFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          final lines = snap.data ?? [];
          if (lines.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onPullRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Tu carrito está vacío.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
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
                child: RefreshIndicator(
                  onRefresh: _onPullRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final line in lines)
                        CartItemTile(
                          line: line,
                          busy: _busyProductId == line.productId,
                          onAdjustQuantity: (delta) =>
                              _adjustQuantity(line.productId, line.quantity, delta),
                        ),
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 8,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.push(AppRoutes.checkout),
                            child: const Text('Ir a checkout'),
                          ),
                        ),
                      ],
                    ),
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
