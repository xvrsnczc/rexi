import 'package:flutter/material.dart';

import '../data/activity_repository.dart';
import '../domain/favorite_model.dart';
import 'widgets/favorite_product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FavoriteModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ActivityRepository.instance.favorites();
  }

  Future<void> _onRefresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<FavoriteModel>>(
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
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  Center(
                    child: Text(
                      'Aún no guardas favoritos.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                return FavoriteProductCard(
                  item: item,
                  onRemoved: () async {
                    await ActivityRepository.instance.removeFavorite(item);
                    if (!context.mounted) return;
                    setState(_reload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quitado de favoritos.')),
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
