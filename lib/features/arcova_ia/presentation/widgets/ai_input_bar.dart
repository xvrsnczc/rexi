import 'package:flutter/material.dart';

class AiInputBar extends StatefulWidget {
  const AiInputBar({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends State<AiInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _controller.text.trim();
    if (v.isEmpty) return;
    widget.onSend(v);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Escribe a ARCOVA…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
