import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isMine});

  final String text;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}
