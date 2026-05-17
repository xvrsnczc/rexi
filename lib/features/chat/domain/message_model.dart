class MessageModel {
  const MessageModel({
    required this.id,
    required this.body,
    required this.isMine,
  });

  final String id;
  final String body;
  final bool isMine;
}
