import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/video_comment_model.dart';

/// Tabla [SupabaseTables.videoComments]: `video_id`, `user_id`, `body`, `created_at`.
class VideoCommentsRepository {
  VideoCommentsRepository._();

  static final VideoCommentsRepository instance = VideoCommentsRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<List<VideoCommentModel>> listForVideo(String videoId) async {
    if (videoId.isEmpty) return [];
    try {
      final rows = supabaseAsMapList(
        await _client
            .from(SupabaseTables.videoComments)
            .select('*')
            .eq('video_id', videoId)
            .order('created_at', ascending: true)
            .limit(200),
      );
      final uids = <String>{};
      for (final r in rows) {
        final u = pickStr(r, ['user_id']);
        if (u != null && u.isNotEmpty) uids.add(u);
      }
      final names = await _displayNamesFor(uids);

      return rows
          .map((r) {
            final id = pickStr(r, ['id']) ?? '';
            if (id.isEmpty) return null;
            final uid = pickStr(r, ['user_id']) ?? '';
            final body = pickStr(r, ['body', 'mensaje', 'texto', 'comentario', 'Contenido']) ?? '';
            final raw = r['created_at'];
            DateTime? at;
            if (raw is DateTime) {
              at = raw;
            } else if (raw != null) {
              at = DateTime.tryParse(raw.toString());
            }
            final label = names[uid] ?? (uid.length > 6 ? '${uid.substring(0, 6)}…' : 'Usuario');
            return VideoCommentModel(
              id: id,
              body: body.isEmpty ? '—' : body,
              authorLabel: label,
              createdAt: at,
            );
          })
          .whereType<VideoCommentModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, String>> _displayNamesFor(Set<String> uids) async {
    if (uids.isEmpty) return {};
    try {
      final rows = supabaseAsMapList(
        await _client
            .from(SupabaseTables.usersProfile)
            .select('id, full_name')
            .inFilter('id', uids.toList()),
      );
      final map = <String, String>{};
      for (final r in rows) {
        final id = pickStr(r, ['id']);
        final name = pickStr(r, ['full_name', 'nombre', 'name']);
        if (id != null && name != null && name.isNotEmpty) map[id] = name;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Devuelve mensaje de error o null si OK.
  Future<String?> addComment(String videoId, String text) async {
    final uid = _uid;
    if (uid == null) return 'Inicia sesión para comentar.';
    final t = text.trim();
    if (t.isEmpty) return 'Escribe algo.';
    if (videoId.isEmpty) return 'Video no válido.';
    try {
      await _client.from(SupabaseTables.videoComments).insert({
        'video_id': videoId,
        'user_id': uid,
        'body': t,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
