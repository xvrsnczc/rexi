import 'package:flutter/material.dart';

import '../../data/video_comments_repository.dart';
import '../../domain/video_comment_model.dart';

/// Comentarios del video vía `video_comments` en Supabase.
class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key, required this.videoId});

  final String videoId;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late Future<List<VideoCommentModel>> _future;
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _reload() {
    _future = VideoCommentsRepository.instance.listForVideo(widget.videoId);
  }

  Future<void> _onRefresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    final err = await VideoCommentsRepository.instance.addComment(widget.videoId, t);
    if (!mounted) return;
    setState(() => _sending = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    _input.clear();
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Comentarios',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: FutureBuilder<List<VideoCommentModel>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                    ],
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Sé el primero en comentar. Si no ves nada tras enviar, crea la tabla `video_comments` en Supabase y revisa RLS.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(
                          c.authorLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        subtitle: Text(c.body),
                        isThreeLine: c.body.length > 60,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Material(
          elevation: 6,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: const CircleBorder(),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 22),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
