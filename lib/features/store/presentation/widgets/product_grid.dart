import 'package:flutter/material.dart';

import '../../../../core/widgets/product_card.dart';

/// Rejilla de productos (conectar a [StoreRepository]).
class StoreProductGrid extends StatelessWidget {
  const StoreProductGrid({super.key, required this.products});

  final List<({String title, String price})> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return ProductCard(title: p.title, priceLabel: p.price);
      },
    );
  }
}
