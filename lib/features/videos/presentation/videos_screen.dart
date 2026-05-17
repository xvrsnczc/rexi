import 'package:flutter/material.dart';

import '../data/video_repository.dart';
import '../domain/video_model.dart';
import 'video_detail_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<List<VideoModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = VideoRepository.instance.fetchFeed();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = VideoRepository.instance.fetchFeed();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<VideoModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              ],
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: Text('No se pudieron cargar videos:\n${snap.error}')),
              ],
            );
          }
          final videos = snap.data ?? [];
          if (videos.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                Center(child: Text('No hay videos por ahora.')),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final v = videos[i];
              return ListTile(
                leading: v.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        v.thumbnailUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.play_circle_outline, size: 40),
                      )
                    : const Icon(Icons.play_circle_outline, size: 40),
                title: Text(v.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VideoDetailScreen(videoId: v.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
