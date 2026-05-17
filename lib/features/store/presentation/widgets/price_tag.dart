import 'package:flutter/material.dart';

/// Etiqueta de precio destacada.
class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    );
  }
}
