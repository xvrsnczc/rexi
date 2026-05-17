import 'package:flutter/material.dart';

import '../data/core_repository.dart';
import '../domain/knowledge_model.dart';
import 'widgets/knowledge_card.dart';

/// REXI Core — conocimiento; al tocar un artículo se abre el detalle.
class CoreScreen extends StatelessWidget {
  const CoreScreen({super.key});

  void _openArticle(BuildContext context, KnowledgeModel item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: Text(item.title)),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Aquí se mostrará el contenido completo de «${item.title}».',
              style: TextStyle(fontSize: 16, height: 1.4, color: Colors.grey.shade800),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REXI Core')),
      body: FutureBuilder(
        future: CoreRepository.instance.articles(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay artículos todavía.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = items[i];
              return KnowledgeCard(
                item: item,
                onTap: () => _openArticle(context, item),
              );
            },
          );
        },
      ),
    );
  }
}
