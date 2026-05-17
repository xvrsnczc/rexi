class ChatAiMessage {
  const ChatAiMessage({
    required this.id,
    required this.role,
    required this.text,
  });

  final String id;
  final String role;
  final String text;
}
