import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/search_repository.dart';
import '../../domain/search_result.dart';
import '../../../store/presentation/product_detail_screen.dart';

/// Búsqueda en catálogo [SearchRepository] → detalle de producto.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _lastQuery = '';
  Future<List<SearchResult>>? _future;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch(String raw) {
    final q = raw.trim();
    setState(() {
      _lastQuery = q;
      _future = SearchRepository.instance.query(q);
    });
  }

  void _openResult(SearchResult r) {
    if (r.type == 'Producto') {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(productId: r.id, title: r.title),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('«${r.title}» (${r.type}) — detalle próximamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar en REXI…',
            border: InputBorder.none,
          ),
          onSubmitted: _runSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _runSearch(_controller.text),
          ),
        ],
      ),
      body: _future == null
          ? Center(
              child: Text(
                'Escribe y pulsa buscar o Intro.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : FutureBuilder<List<SearchResult>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                if (_lastQuery.isEmpty) {
                  return const Center(child: Text('Escribe algo para buscar.'));
                }
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Sin resultados para «$_lastQuery».',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return ListTile(
                      title: Text(r.title),
                      subtitle: Text(r.type),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openResult(r),
                    );
                  },
                );
              },
            ),
    );
  }
}
