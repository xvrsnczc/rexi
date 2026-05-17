class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String? imageUrl;
}
