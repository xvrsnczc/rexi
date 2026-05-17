import 'package:flutter/material.dart';

import '../../../store/presentation/product_detail_screen.dart';
import '../../domain/favorite_model.dart';

class FavoriteProductCard extends StatelessWidget {
  const FavoriteProductCard({
    super.key,
    required this.item,
    required this.onRemoved,
  });

  final FavoriteModel item;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.redAccent),
        title: Text(item.title),
        subtitle: Text(item.kind),
        trailing: IconButton(
          tooltip: 'Quitar de favoritos',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => onRemoved(),
        ),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailScreen(
                productId: item.productId,
                title: item.title,
              ),
            ),
          );
        },
      ),
    );
  }
}
