import 'package:flutter/material.dart';

import '../data/news_repository.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artículo')),
      body: FutureBuilder(
        future: NewsRepository.instance.fetchArticleById(articleId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final a = snap.data;
          if (a == null) {
            return const Center(child: Text('No se encontró el artículo.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                a.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                a.fullText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          );
        },
      ),
    );
  }
}
