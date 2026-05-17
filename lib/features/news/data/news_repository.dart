import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/article_model.dart';

/// Vista `news_with_author`: `Título`, `Extracto`, `Contenido`.
class NewsRepository {
  NewsRepository._();

  static final NewsRepository instance = NewsRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ArticleModel>> fetchFeed() async {
    dynamic response;
    try {
      response = await _client
          .from(SupabaseTables.newsWithAuthor)
          .select('id, "Título", "Extracto", "Contenido", is_published')
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(50);
    } catch (_) {
      response = await _client
          .from(SupabaseTables.newsWithAuthor)
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
    }

    final rows = supabaseAsMapList(response);
    return rows
        .map(
          (r) {
            final summary = pickStr(r, [
                  'Extracto',
                  'extracto',
                  'summary',
                  'resumen',
                ]) ??
                pickStr(r, ['Contenido', 'contenido']) ??
                '';
            return ArticleModel(
              id: pickStr(r, ['id']) ?? '',
              title: pickStr(r, [
                    'Título',
                    'titulo',
                    'Titulo',
                    'title',
                  ]) ??
                  'Noticia',
              summary: summary,
              body: pickStr(r, ['Contenido', 'contenido', 'content']),
            );
          },
        )
        .where((a) => a.id.isNotEmpty)
        .toList();
  }

  Future<ArticleModel?> fetchArticleById(String id) async {
    if (id.isEmpty) return null;
    try {
      final row = await _client
          .from(SupabaseTables.newsWithAuthor)
          .select('id, "Título", "Extracto", "Contenido"')
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      final r = Map<String, dynamic>.from(row as Map);
      final summary = pickStr(r, ['Extracto', 'extracto', 'summary', 'resumen']) ??
          pickStr(r, ['Contenido', 'contenido']) ??
          '';
      final content = pickStr(r, ['Contenido', 'contenido', 'content', 'cuerpo']) ?? summary;
      return ArticleModel(
        id: pickStr(r, ['id']) ?? '',
        title: pickStr(r, ['Título', 'titulo', 'Titulo', 'title']) ?? 'Noticia',
        summary: summary,
        body: content,
      );
    } catch (_) {
      return null;
    }
  }
}
