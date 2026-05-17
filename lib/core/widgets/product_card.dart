import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// Tarjeta de producto reutilizable (listados / grids).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.priceLabel,
    this.imagePlaceholder,
    this.width = 140,
    this.onTap,
  });

  final String title;
  final String priceLabel;
  final String? imagePlaceholder;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: Text(
                      imagePlaceholder ?? title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceLabel,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
