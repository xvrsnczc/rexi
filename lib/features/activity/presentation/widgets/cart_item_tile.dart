import 'package:flutter/material.dart';

import '../../domain/cart_model.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.line,
    this.onAdjustQuantity,
    this.busy = false,
  });

  final CartModel line;
  final void Function(int delta)? onAdjustQuantity;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(line.title),
      subtitle: Text('Cantidad: ${line.quantity}'),
      trailing: SizedBox(
        width: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '\$${(line.quantity * line.unitPrice).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              tooltip: 'Menos',
              onPressed: busy || onAdjustQuantity == null
                  ? null
                  : () => onAdjustQuantity!(-1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              tooltip: 'Más',
              onPressed: busy || onAdjustQuantity == null
                  ? null
                  : () => onAdjustQuantity!(1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
