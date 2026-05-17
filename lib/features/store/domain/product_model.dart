class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrls,
    this.sellerId,
  });

  final String id;
  /// Mapeado desde la columna `Nombre` de `marketplace_products`.
  final String title;
  /// Mapeado desde la columna `Precio`.
  final double price;
  /// Mapeado desde `image_urls` (arreglo en BD).
  final List<String>? imageUrls;
  /// Mapeado desde `seller_id`.
  final String? sellerId;
}
