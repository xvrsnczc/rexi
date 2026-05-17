import 'package:flutter/material.dart';

import '../data/chat_repository.dart';
import '../domain/conversation_preview.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ConversationPreview>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChatRepository.instance.myConversations();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = ChatRepository.instance.myConversations();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<ConversationPreview>>(
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
                Center(child: Text('No se pudieron cargar conversaciones:\n${snap.error}')),
              ],
            );
          }
          final threads = snap.data ?? [];
          if (threads.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                Center(
                  child: Text(
                    'No tienes conversaciones. Aparecerán desde Conversaciones.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = threads[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
                title: Text(t.lastPreview.isEmpty ? 'Conversación' : t.lastPreview),
                subtitle: Text(
                  t.lastAt != null
                      ? '${t.lastAt}'
                      : 'Hilo ${t.id.length > 8 ? '${t.id.substring(0, 8)}…' : t.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChatDetailScreen(threadId: t.id),
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
