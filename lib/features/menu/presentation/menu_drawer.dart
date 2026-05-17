import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/badge_label.dart';
import '../../activity/data/activity_repository.dart';
import '../domain/menu_item_model.dart';
import 'widgets/activity_tile.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/user_header.dart';

/// Contenido del [Drawer] lateral (hamburguesa). Cierra el drawer y navega con GoRouter.
class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key, this.onCloseDrawer});

  /// Llamar antes de [GoRouter.push] / [go] para cerrar el drawer (p. ej. `Navigator.pop`).
  final VoidCallback? onCloseDrawer;

  static const List<MenuItemModel> _navItems = [
    MenuItemModel(
      id: 'arcade',
      title: 'REXI ARCADE',
      subtitle: 'Juegos creados con IA',
      routeLocation: AppRoutes.arcade,
      badgeLabel: 'HOT',
    ),
    MenuItemModel(
      id: 'core',
      title: 'REXI Core',
      subtitle: 'El núcleo del conocimiento',
      routeLocation: AppRoutes.rexiCore,
      badgeLabel: 'NEW',
    ),
    MenuItemModel(
      id: 'arcova',
      title: 'ARCOVA IA',
      subtitle: 'Tu asistente inteligente',
      routeLocation: AppRoutes.arcovaIa,
      badgeLabel: 'AI',
    ),
    MenuItemModel(
      id: 'empleos',
      title: 'REXI Empleos',
      subtitle: 'Encuentra trabajos',
      routeLocation: AppRoutes.empleos,
      trailingChevronOnly: true,
    ),
  ];

  static String _displayName(User? u) {
    final meta = u?.userMetadata;
    final n = meta?['full_name'] as String?;
    if (n != null && n.trim().isNotEmpty) return n.trim();
    final email = u?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Usuario';
  }

  static IconData _iconFor(String id) {
    switch (id) {
      case 'arcade':
        return Icons.sports_esports_rounded;
      case 'core':
        return Icons.diamond_outlined;
      case 'arcova':
        return Icons.auto_awesome;
      case 'empleos':
        return Icons.work_outline_rounded;
      default:
        return Icons.circle;
    }
  }

  static LinearGradient _gradientFor(String id) {
    switch (id) {
      case 'arcade':
        return const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF1A237E)],
        );
      case 'core':
        return const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF2196F3)],
        );
      case 'arcova':
        return const LinearGradient(
          colors: [Color(0xFFC2185B), Color(0xFFE040FB)],
        );
      case 'empleos':
        return const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00BCD4)],
        );
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.black54]);
    }
  }

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late Future<({int cart, int orders, int favorites})> _countsFuture;

  @override
  void initState() {
    super.initState();
    _reloadCounts();
  }

  void _reloadCounts() {
    _countsFuture = Future.wait([
      ActivityRepository.instance.cartLines(),
      ActivityRepository.instance.activeOrders(),
      ActivityRepository.instance.favorites(),
    ]).then((lists) {
      final c = lists[0].length;
      final o = lists[1].length;
      final f = lists[2].length;
      return (cart: c, orders: o, favorites: f);
    });
  }

  void _go(BuildContext context, String location) {
    final router = GoRouter.of(context);
    widget.onCloseDrawer?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.push(location);
    });
  }

  Future<void> _logout(BuildContext context) async {
    final router = GoRouter.of(context);
    widget.onCloseDrawer?.call();
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = Supabase.instance.client.auth.currentUser;
    final email = u?.email ?? '—';
    final verified = u?.emailConfirmedAt != null;

    return ColoredBox(
      color: const Color(0xFFF5F7F9),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: UserHeader(
              displayName: MenuDrawer._displayName(u),
              email: email,
              verified: verified,
              onProfile: () => _go(context, AppRoutes.profile),
              onLogout: () => _logout(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (final item in MenuDrawer._navItems)
                  MenuItemCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: MenuDrawer._iconFor(item.id),
                    gradient: MenuDrawer._gradientFor(item.id),
                    badgeKind: item.trailingChevronOnly
                        ? null
                        : RexiBadgeLabel.fromString(item.badgeLabel ?? ''),
                    trailingChevronOnly: item.trailingChevronOnly,
                    onTap: () => _go(context, item.routeLocation),
                  ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'MI ACTIVIDAD',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder(
                future: _countsFuture,
                builder: (context, snap) {
                  final c = snap.data?.cart ?? 0;
                  final o = snap.data?.orders ?? 0;
                  final f = snap.data?.favorites ?? 0;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ActivityTile(
                          title: 'Mi carrito',
                          subtitle: snap.connectionState == ConnectionState.waiting
                              ? '…'
                              : '$c ${c == 1 ? 'producto' : 'productos'}',
                          icon: Icons.shopping_cart_outlined,
                          iconColor: Colors.blue.shade700,
                          onTap: () => _go(context, AppRoutes.cart),
                        ),
                        const Divider(height: 1),
                        ActivityTile(
                          title: 'Mis pedidos',
                          subtitle: snap.connectionState == ConnectionState.waiting
                              ? '…'
                              : '$o activos',
                          icon: Icons.receipt_long_outlined,
                          iconColor: Colors.blue.shade700,
                          onTap: () => _go(context, AppRoutes.orders),
                        ),
                        const Divider(height: 1),
                        ActivityTile(
                          title: 'Favoritos',
                          subtitle: snap.connectionState == ConnectionState.waiting
                              ? '…'
                              : '$f guardados',
                          icon: Icons.favorite_outline,
                          iconColor: Colors.red.shade400,
                          onTap: () => _go(context, AppRoutes.favorites),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.local_shipping_outlined, color: Colors.teal.shade700),
                      title: const Text('Modo repartidor'),
                      subtitle: const Text('Carga bajo demanda · cola offline'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _go(context, AppRoutes.repartidor),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.settings_outlined, color: Colors.grey.shade700),
                      title: const Text('Ajustes'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _go(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
