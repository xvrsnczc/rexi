import '../../store/data/store_repository.dart';
import '../../store/domain/product_model.dart';
import '../domain/banner_model.dart';

/// Promociones / banners derivados del catálogo (sin tabla extra en Supabase).
class HomeRepository {
  HomeRepository._();

  static final HomeRepository instance = HomeRepository._();

  /// Máximo [limit] productos activos recientes como banners.
  Future<List<BannerModel>> fetchPromoBanners({int limit = 8}) async {
    final products = await StoreRepository.instance.fetchHotDeals();
    return fromProducts(products.take(limit));
  }

  static List<BannerModel> fromProducts(Iterable<ProductModel> products) {
    return products
        .map(
          (p) => BannerModel(
            id: p.id,
            title: p.title,
            imageUrl: (p.imageUrls != null && p.imageUrls!.isNotEmpty)
                ? p.imageUrls!.first
                : null,
          ),
        )
        .where((b) => b.id.isNotEmpty)
        .toList();
  }
}
