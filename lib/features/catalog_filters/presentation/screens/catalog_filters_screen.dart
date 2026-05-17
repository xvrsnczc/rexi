import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/catalog_filters_repository.dart';
import '../../domain/catalog_filter_criteria.dart';

/// Filtros de catálogo — persistencia local vía [CatalogFiltersRepository].
class CatalogFiltersScreen extends StatefulWidget {
  const CatalogFiltersScreen({super.key});

  @override
  State<CatalogFiltersScreen> createState() => _CatalogFiltersScreenState();
}

class _CatalogFiltersScreenState extends State<CatalogFiltersScreen> {
  final Set<String> _categories = {};
  String _sort = 'relevancia';
  bool _loadingPrefs = true;

  static const _cats = ['Moda', 'Calzado', 'Electrónica', 'Hogar'];

  @override
  void initState() {
    super.initState();
    CatalogFiltersRepository.instance.loadSaved().then((c) {
      if (!mounted) return;
      setState(() {
        _categories
          ..clear()
          ..addAll(c.categoryLabels);
        _sort = c.sortKey;
        _loadingPrefs = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filtros')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Filtros')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Categorías',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cats.map((c) {
              final sel = _categories.contains(c);
              return FilterChip(
                label: Text(c),
                selected: sel,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _categories.add(c);
                    } else {
                      _categories.remove(c);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Ordenar por',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          for (final e in [
            ('relevancia', 'Relevancia'),
            ('precio_asc', 'Precio: menor a mayor'),
            ('precio_desc', 'Precio: mayor a menor'),
            ('nuevo', 'Más recientes'),
          ])
            ListTile(
              title: Text(e.$2),
              trailing: _sort == e.$1 ? const Icon(Icons.check_circle, size: 22) : null,
              onTap: () => setState(() => _sort = e.$1),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final criteria = CatalogFilterCriteria(
                categoryLabels: Set<String>.from(_categories),
                sortKey: _sort,
              );
              await CatalogFiltersRepository.instance.save(criteria);
              if (!context.mounted) return;
              final n = _categories.length;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    n == 0
                        ? 'Filtros guardados: orden «$_sort».'
                        : 'Filtros guardados: $n categoría(s), orden «$_sort».',
                  ),
                ),
              );
              context.pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}
