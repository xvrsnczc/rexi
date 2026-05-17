import 'package:flutter/material.dart';

/// Carrusel horizontal genérico (altura fija + lista de hijos).
class RexiCarousel extends StatelessWidget {
  const RexiCarousel({
    super.key,
    required this.height,
    required this.children,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final double height;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: children,
      ),
    );
  }
}
