class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    this.videoUrl = '',
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
}
