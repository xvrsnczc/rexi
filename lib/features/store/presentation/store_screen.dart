import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/carousel_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/section_header_row.dart';
import '../../home/data/home_repository.dart';
import '../../home/presentation/widgets/banner_carousel.dart';
import '../data/store_repository.dart';
import '../domain/product_model.dart';
import '../domain/seller_model.dart';
import 'product_detail_screen.dart';
import 'seller_profile_screen.dart';
import 'widgets/new_seller_card.dart';

/// Pestaña **Tienda** — datos desde [StoreRepository] (Supabase).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<({List<ProductModel> products, List<SellerModel> sellers, String? error})> _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = _loadCatalog();
  }

  Future<({List<ProductModel> products, List<SellerModel> sellers, String? error})> _loadCatalog() async {
    try {
      final repo = StoreRepository.instance;
      final products = await repo.fetchHotDeals();
      final sellers = await repo.fetchNewSellers();
      return (products: products, sellers: sellers, error: null);
    } catch (e, st) {
      debugPrint('StoreRepository: $e\n$st');
      return (
        products: <ProductModel>[],
        sellers: <SellerModel>[],
        error: e.toString(),
      );
    }
  }

  Future<void> _retry() async {
    setState(() {
      _catalog = _loadCatalog();
    });
    await _catalog;
  }

  void _openProduct(BuildContext context, ProductModel p) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(productId: p.id, title: p.title),
      ),
    );
  }

  String _priceLabel(double price) => r'$' + price.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _catalog,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data;
        final err = data?.error;
        final products = data?.products ?? [];
        final sellers = data?.sellers ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _catalog = _loadCatalog();
            });
            await _catalog;
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 8),
              if (err != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'No se pudo cargar el catálogo.',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: _retry,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              BannerCarousel(
                banners: HomeRepository.fromProducts(products.take(8)),
              ),
              SectionHeaderRow(
                leading: const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                title: 'Hot Deals',
                subtitle: 'Los más vendidos esta semana',
                trailing: TextButton(
                  onPressed: () => context.push(AppRoutes.search),
                  child: const Text('Ver todos'),
                ),
              ),
              if (products.isEmpty)
                (err == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No hay productos con Estado = Activo. Añade filas en marketplace_products o revisa RLS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      )
                    : const SizedBox.shrink())
              else
                RexiCarousel(
                  height: 200,
                  children: [
                    for (var i = 0; i < products.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      ProductCard(
                        title: products[i].title,
                        priceLabel: _priceLabel(products[i].price),
                        imagePlaceholder: () {
                          final t = products[i].title;
                          if (t.isEmpty) return '·';
                          return t.substring(0, 1).toUpperCase();
                        }(),
                        onTap: () => _openProduct(context, products[i]),
                      ),
                    ],
                  ],
                ),
              SectionHeaderRow(
                leading: const Icon(Icons.auto_awesome, color: Colors.amber),
                title: 'Nuevos en REXI',
                subtitle: 'Apóyalos en sus primeros 30 días',
                trailing: FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.catalogFilters),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('BOOST'),
                ),
              ),
              if (sellers.isEmpty)
                (err == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No hay vendedores en `sellers` o la tabla está vacía.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      )
                    : const SizedBox.shrink())
              else
                RexiCarousel(
                  height: 120,
                  children: [
                    for (var i = 0; i < sellers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      NewSellerCard(
                        name: sellers[i].name,
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => SellerProfileScreen(sellerId: sellers[i].id),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
