import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/notification_item.dart';

/// Vista `unread_notifications`: `Título`, `Mensaje` (como en tu BD).
/// Si falla, intenta tabla `Notificaciones`.
class NotificationsRepository {
  NotificationsRepository._();

  static final NotificationsRepository instance = NotificationsRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NotificationItem>> list() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    dynamic response;
    try {
      response = await _client
          .from(SupabaseTables.unreadNotifications)
          .select('id, user_id, "Título", "Mensaje", created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(100);
    } catch (_) {
      response = await _client
          .from(SupabaseTables.notificaciones)
          .select('*')
          .eq('user_id', uid)
          .order('id', ascending: false)
          .limit(100);
    }

    final rows = supabaseAsMapList(response);
    return rows
        .map(
          (r) => NotificationItem(
            id: pickStr(r, ['id']) ?? '',
            title: pickStr(r, [
                  'Título',
                  'titulo',
                  'Titulo',
                  'title',
                ]) ??
                'Notificación',
            body: pickStr(r, [
                  'Mensaje',
                  'mensaje',
                  'cuerpo',
                  'body',
                  'descripcion',
                ]) ??
                '',
          ),
        )
        .where((n) => n.id.isNotEmpty)
        .toList();
  }

  /// Intenta marcar leída en tabla `Notificaciones` (las vistas pueden ser solo lectura).
  Future<void> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) return;
    try {
      await _client
          .from(SupabaseTables.notificaciones)
          .update({'leido': true})
          .eq('id', notificationId);
    } catch (_) {
      try {
        await _client
            .from(SupabaseTables.notificaciones)
            .update({'read': true})
            .eq('id', notificationId);
      } catch (_) {}
    }
  }
}
