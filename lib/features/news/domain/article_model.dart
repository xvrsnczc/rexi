class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    this.body,
  });

  final String id;
  final String title;
  final String summary;
  /// Texto largo si existe (detalle); si no, usar [summary].
  final String? body;

  String get fullText => (body != null && body!.trim().isNotEmpty) ? body! : summary;
}
