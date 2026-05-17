import 'package:flutter/material.dart';

/// Sección Hot Deals reutilizable (puede envolver listas desde `StoreRepository`).
class HotDealsSection extends StatelessWidget {
  const HotDealsSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
