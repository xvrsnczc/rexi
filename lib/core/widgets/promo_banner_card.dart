import 'package:flutter/material.dart';

/// Banner tipo "Ofertas especiales" (tienda / home).
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, this.onCtaPressed});

  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Ofertas especiales!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onCtaPressed,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('50% OFF'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
