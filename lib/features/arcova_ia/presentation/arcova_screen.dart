import 'package:flutter/material.dart';

import 'widgets/ai_chat_bubble.dart';
import 'widgets/ai_input_bar.dart';

/// ARCOVA IA — chat asistente (`AiRepository`).
class ArcovaScreen extends StatefulWidget {
  const ArcovaScreen({super.key});

  @override
  State<ArcovaScreen> createState() => _ArcovaScreenState();
}

class _ArcovaScreenState extends State<ArcovaScreen> {
  final List<({String text, bool user})> _lines = [];

  void _add(String text, bool user) {
    setState(() => _lines.add((text: text, user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARCOVA IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_lines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Escribe un mensaje abajo para hablar con Arcova.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final line in _lines)
                  AiChatBubble(text: line.text, isUser: line.user),
              ],
            ),
          ),
          AiInputBar(
            onSend: (t) {
              _add(t, true);
              _add(
                'He recibido tu mensaje. Cuando conectes el asistente, aquí verás la respuesta en tiempo real.',
                false,
              );
            },
          ),
        ],
      ),
    );
  }
}
