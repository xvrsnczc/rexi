import 'package:flutter/material.dart';

import '../data/news_repository.dart';
import '../domain/article_model.dart';
import 'article_detail_screen.dart';
import 'widgets/article_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<ArticleModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = NewsRepository.instance.fetchFeed();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = NewsRepository.instance.fetchFeed();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<ArticleModel>>(
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
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: Text('No se pudieron cargar noticias:\n${snap.error}')),
              ],
            );
          }
          final articles = snap.data ?? [];
          if (articles.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                Center(child: Text('No hay noticias por ahora.')),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = articles[i];
              return ArticleCard(
                title: a.title,
                summary: a.summary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ArticleDetailScreen(articleId: a.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
