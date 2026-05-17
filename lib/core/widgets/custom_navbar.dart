import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// Barra horizontal de pestañas (referencia: chips superiores REXI).
class RexiTopTabBar extends StatelessWidget {
  const RexiTopTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: AppSizes.topTabHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return ChoiceChip(
            label: Text(labels[i]),
            selected: selected,
            onSelected: (_) => onSelected(i),
            selectedColor: scheme.primary.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: selected ? scheme.primary : Colors.black87,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            side: BorderSide.none,
            backgroundColor: Colors.transparent,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }
}
