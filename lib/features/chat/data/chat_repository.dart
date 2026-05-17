import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/conversation_preview.dart';
import '../domain/message_model.dart';

/// Chat: tabla `Conversaciones`, `Mensajes` (nombres según tu BD).
class ChatRepository {
  ChatRepository._();

  static final ChatRepository instance = ChatRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  /// Hilos donde el usuario es comprador o vendedor.
  Future<List<ConversationPreview>> myConversations() async {
    final uid = _uid;
    if (uid == null) return [];

    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.conversaciones)
          .select('id, last_message_preview, last_message_at, updated_at')
          .or('buyer_id.eq.$uid,seller_id.eq.$uid')
          .order('last_message_at', ascending: false)
          .limit(50),
    );

    return rows
        .map((r) {
          final id = pickStr(r, ['id']) ?? '';
          final preview = pickStr(r, ['last_message_preview']) ?? '';
          final raw = r['last_message_at'] ?? r['updated_at'];
          DateTime? at;
          if (raw is DateTime) {
            at = raw;
          } else if (raw != null) {
            at = DateTime.tryParse(raw.toString());
          }
          return ConversationPreview(id: id, lastPreview: preview, lastAt: at);
        })
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  /// Mensajes de un hilo (`Conversaciones.id`).
  Future<List<MessageModel>> messages(String threadId) async {
    if (threadId.isEmpty) return [];
    final uid = _uid;

    var rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.mensajes)
          .select('*')
          .eq('conversacion_id', threadId)
          .order('id', ascending: true),
    );
    if (rows.isEmpty) {
      rows = supabaseAsMapList(
        await _client
            .from(SupabaseTables.mensajes)
            .select('*')
            .eq('conversation_id', threadId)
            .order('id', ascending: true),
      );
    }

    return rows
        .map(
          (r) {
            final sender = pickStr(r, [
              'sender_id',
              'user_id',
              'from_user_id',
              'autor_id',
              'enviado_por',
              'buyer_id',
              'seller_id',
            ]);
            final mine = uid != null && sender == uid;
            final body = pickStr(r, [
                  'Mensaje',
                  'mensaje',
                  'body',
                  'texto',
                  'contenido',
                  'Contenido',
                ]) ??
                '';
            return MessageModel(
              id: pickStr(r, ['id']) ?? '',
              body: body,
              isMine: mine,
            );
          },
        )
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  Future<void> sendMessage(String threadId, String text) async {
    final uid = _uid;
    if (uid == null || threadId.isEmpty) return;
    final t = text.trim();
    if (t.isEmpty) return;

    try {
      await _client.from(SupabaseTables.mensajes).insert({
        'conversacion_id': threadId,
        'sender_id': uid,
        'Mensaje': t,
      });
      return;
    } catch (_) {}

    try {
      await _client.from(SupabaseTables.mensajes).insert({
        'conversation_id': threadId,
        'user_id': uid,
        'Mensaje': t,
      });
    } catch (_) {
      rethrow;
    }
  }
}
