class VideoCommentModel {
  const VideoCommentModel({
    required this.id,
    required this.body,
    required this.authorLabel,
    this.createdAt,
  });

  final String id;
  final String body;
  final String authorLabel;
  final DateTime? createdAt;
}
