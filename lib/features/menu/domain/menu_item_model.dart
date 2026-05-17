/// Definición de una fila/card del menú lateral (sin widgets).
class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routeLocation,
    this.badgeLabel,
    this.trailingChevronOnly = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String routeLocation;
  /// `HOT`, `NEW` o `AI`; ver [RexiBadgeLabel] en `core/widgets/badge_label.dart`.
  final String? badgeLabel;
  final bool trailingChevronOnly;
}
