import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/promo_banner_card.dart';
import '../../../../core/widgets/carousel_widget.dart';
import '../../domain/banner_model.dart';

/// Carrusel horizontal de ofertas (datos ya cargados; sin segunda petición a Supabase).
class BannerCarousel extends StatelessWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 120,
  });

  final List<BannerModel> banners;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return PromoBannerCard(
        onCtaPressed: () => context.push(AppRoutes.search),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return RexiCarousel(
      height: height,
      children: [
        for (var i = 0; i < banners.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.72,
            child: Material(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push(AppRoutes.search),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      if (banners[i].imageUrl != null &&
                          banners[i].imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            banners[i].imageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.local_offer_outlined, color: scheme.primary),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Destacado',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banners[i].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: scheme.outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
