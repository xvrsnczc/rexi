import 'package:flutter/material.dart';

class ApplyButton extends StatelessWidget {
  const ApplyButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: const Text('Postular'),
    );
  }
}
