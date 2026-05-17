import 'package:flutter/material.dart';

import '../../../../core/widgets/badge_label.dart';

/// Card grande del menú (Arcade, Core, Arcova, Empleos).
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.badgeKind,
    this.trailingChevronOnly = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final RexiBadgeKind? badgeKind;
  final bool trailingChevronOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (badgeKind != null)
                    RexiBadgeLabel(kind: badgeKind!)
                  else if (trailingChevronOnly)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
