import 'package:flutter/material.dart';

import '../data/store_repository.dart';
import '../domain/product_model.dart';
import '../../activity/data/activity_repository.dart';

/// Ficha de producto desde [StoreRepository]; añadir al carrito vía [ActivityRepository].
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.title,
  });

  final String productId;
  final String? title;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductModel?> _product;
  bool _adding = false;
  bool _favBusy = false;

  @override
  void initState() {
    super.initState();
    _product = StoreRepository.instance.fetchProductById(widget.productId);
  }

  Future<void> _addToCart(ProductModel p) async {
    setState(() => _adding = true);
    try {
      await ActivityRepository.instance.addToCart(p.id, delta: 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añadido al carrito.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo añadir: $e')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _addFavorite(ProductModel p) async {
    setState(() => _favBusy = true);
    try {
      await ActivityRepository.instance.addFavorite(p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado en favoritos.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _favBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackName = widget.title ?? 'Producto';
    return Scaffold(
      appBar: AppBar(title: Text(fallbackName)),
      body: FutureBuilder<ProductModel?>(
        future: _product,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se encontró el producto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }

          final imageUrl = p.imageUrls != null && p.imageUrls!.isNotEmpty
              ? p.imageUrls!.first
              : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(context),
                        )
                      : _placeholder(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                p.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                r'$' + p.price.toStringAsFixed(2),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Referencia: ${p.id}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _adding ? null : () => _addToCart(p),
                child: _adding
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Añadir al carrito'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _favBusy ? null : () => _addFavorite(p),
                icon: _favBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.favorite_border),
                label: const Text('Añadir a favoritos'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
