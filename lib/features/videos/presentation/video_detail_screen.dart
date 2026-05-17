import 'package:flutter/material.dart';

import '../data/video_repository.dart';
import 'widgets/comments_section.dart';
import 'widgets/video_player_widget.dart';

class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: FutureBuilder(
        future: VideoRepository.instance.fetchVideoById(videoId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final v = snap.data;
          if (v == null) {
            return const Center(child: Text('No se encontró el video.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VideoPlayerWidget(
                title: v.title,
                thumbnailUrl: v.thumbnailUrl,
                videoUrl: v.videoUrl,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  v.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (v.videoUrl.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Añade una columna de URL del video en la vista o tabla de Supabase.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
              Expanded(child: CommentsSection(videoId: videoId)),
            ],
          );
        },
      ),
    );
  }
}
