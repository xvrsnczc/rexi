import 'package:flutter/material.dart';

/// Badges del menú: `HOT`, `NEW`, `AI`.
enum RexiBadgeKind { hot, newBadge, ai }

/// Chip de etiqueta para cards del drawer (Arcade, Core, Arcova…).
class RexiBadgeLabel extends StatelessWidget {
  const RexiBadgeLabel({super.key, required this.kind});

  final RexiBadgeKind kind;

  static RexiBadgeKind? fromString(String type) {
    switch (type.toUpperCase()) {
      case 'HOT':
        return RexiBadgeKind.hot;
      case 'NEW':
        return RexiBadgeKind.newBadge;
      case 'AI':
        return RexiBadgeKind.ai;
      default:
        return null;
    }
  }

  String get _label {
    switch (kind) {
      case RexiBadgeKind.hot:
        return 'HOT';
      case RexiBadgeKind.newBadge:
        return 'NEW';
      case RexiBadgeKind.ai:
        return 'AI';
    }
  }

  Color _background(BuildContext context) {
    switch (kind) {
      case RexiBadgeKind.hot:
        return Colors.blue.shade700;
      case RexiBadgeKind.newBadge:
        return Colors.amber.shade800;
      case RexiBadgeKind.ai:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _background(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
