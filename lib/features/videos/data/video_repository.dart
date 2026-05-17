import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/video_model.dart';

/// Vista `videos_with_author`: `Título`, `thumbnail_url`.
class VideoRepository {
  VideoRepository._();

  static final VideoRepository instance = VideoRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<VideoModel>> fetchFeed() async {
    dynamic response;
    try {
      response = await _client
          .from(SupabaseTables.videosWithAuthor)
          .select('id, "Título", thumbnail_url, is_published')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(50);
    } catch (_) {
      response = await _client
          .from(SupabaseTables.videosWithAuthor)
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
    }

    final rows = supabaseAsMapList(response);
    return rows
        .map(
          (r) => VideoModel(
            id: pickStr(r, ['id']) ?? '',
            title: pickStr(r, [
                  'Título',
                  'titulo',
                  'Titulo',
                  'title',
                ]) ??
                'Video',
            thumbnailUrl: pickStr(r, [
                  'thumbnail_url',
                  'thumbnailUrl',
                  'imagen_url',
                ]) ??
                '',
            videoUrl: pickStr(r, [
                  'video_url',
                  'Video_URL',
                  'url',
                  'enlace',
                  'link',
                  'embed_url',
                ]) ??
                '',
          ),
        )
        .where((v) => v.id.isNotEmpty)
        .toList();
  }

  Future<VideoModel?> fetchVideoById(String id) async {
    if (id.isEmpty) return null;
    try {
      final row = await _client
          .from(SupabaseTables.videosWithAuthor)
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      final r = Map<String, dynamic>.from(row as Map);
      return VideoModel(
        id: pickStr(r, ['id']) ?? '',
        title: pickStr(r, ['Título', 'titulo', 'Titulo', 'title']) ?? 'Video',
        thumbnailUrl: pickStr(r, ['thumbnail_url', 'thumbnailUrl', 'imagen_url']) ?? '',
        videoUrl: pickStr(r, [
              'video_url',
              'Video_URL',
              'url',
              'enlace',
              'link',
              'embed_url',
            ]) ??
            '',
      );
    } catch (_) {
      return null;
    }
  }
}
