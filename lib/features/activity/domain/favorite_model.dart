class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.kind,
  });

  /// Id de la fila en `Favoritos` (para borrar).
  final String id;
  final String productId;
  final String title;
  final String kind;
}
