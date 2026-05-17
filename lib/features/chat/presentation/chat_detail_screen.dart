import 'package:flutter/material.dart';

import '../data/chat_repository.dart';
import '../domain/message_model.dart';
import 'widgets/message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _input = TextEditingController();
  late Future<List<MessageModel>> _messagesFuture;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = ChatRepository.instance.messages(widget.threadId);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _reloadMessages() {
    setState(() {
      _messagesFuture = ChatRepository.instance.messages(widget.threadId);
    });
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ChatRepository.instance.sendMessage(widget.threadId, t);
      _input.clear();
      _reloadMessages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _messagesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Sin mensajes. Escribe el primero abajo.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final m = list[i];
                    return MessageBubble(text: m.body, isMine: m.isMine);
                  },
                );
              },
            ),
          ),
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje…',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
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
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
