import 'package:flutter/material.dart';

/// Cabecera de sección (título + subtítulo + acción).
class SectionHeaderRow extends StatelessWidget {
  const SectionHeaderRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
