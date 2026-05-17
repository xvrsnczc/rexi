/// Fila de lista de chats (tabla `Conversaciones`).
class ConversationPreview {
  const ConversationPreview({
    required this.id,
    this.lastPreview = '',
    this.lastAt,
  });

  final String id;
  final String lastPreview;
  final DateTime? lastAt;
}
