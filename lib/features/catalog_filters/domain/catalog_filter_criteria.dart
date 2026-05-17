class CatalogFilterCriteria {
  const CatalogFilterCriteria({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.categoryLabels = const {},
    this.sortKey = 'relevancia',
  });

  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final Set<String> categoryLabels;
  final String sortKey;

  Map<String, dynamic> toJson() {
    final labels = categoryLabels.toList()..sort();
    return {
      'categoryId': categoryId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'categoryLabels': labels,
      'sortKey': sortKey,
    };
  }

  factory CatalogFilterCriteria.fromJson(Map<String, dynamic> j) {
    final raw = j['categoryLabels'];
    final labels = raw is List
        ? raw.map((e) => e.toString()).toSet()
        : <String>{};
    return CatalogFilterCriteria(
      categoryId: j['categoryId']?.toString(),
      minPrice: (j['minPrice'] as num?)?.toDouble(),
      maxPrice: (j['maxPrice'] as num?)?.toDouble(),
      categoryLabels: labels,
      sortKey: j['sortKey']?.toString() ?? 'relevancia',
    );
  }
}
