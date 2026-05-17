import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  final String title;
  final String thumbnailUrl;
  final String videoUrl;

  Future<void> _open(BuildContext context) async {
    final u = videoUrl.trim();
    if (u.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este video no tiene URL en la base de datos.')),
      );
      return;
    }
    final uri = Uri.tryParse(u);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL de video no válida.')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: () => _open(context),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl.isNotEmpty)
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black26),
                )
              else
                const ColoredBox(color: Colors.black26),
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
