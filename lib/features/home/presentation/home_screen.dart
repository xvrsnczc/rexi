import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../cash/presentation/cash_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../news/presentation/news_screen.dart';
import '../../store/presentation/store_screen.dart';
import '../../videos/presentation/videos_screen.dart';
import '../../menu/presentation/menu_drawer.dart';

/// Contenedor principal: pestañas + cabecera + menú lateral (hamburguesa).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _labels = [
    AppStrings.tabStore,
    AppStrings.tabCash,
    AppStrings.tabNews,
    AppStrings.tabVideos,
    AppStrings.tabChat,
  ];

  /// Primera pestaña: Tienda.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.shellBackground,
      drawer: Drawer(
        width: (MediaQuery.sizeOf(context).width * 0.88).clamp(280.0, 340.0),
        child: MenuDrawer(
          onCloseDrawer: () => _scaffoldKey.currentState?.closeDrawer(),
        ),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  RexiTopTabBar(
                    labels: _labels,
                    selectedIndex: _index,
                    onSelected: (i) => setState(() => _index = i),
                  ),
                  _subHeader(context),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              sizing: StackFit.expand,
              children: const [
                StoreScreen(),
                CashScreen(),
                NewsScreen(),
                VideosScreen(),
                ChatListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menú',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            icon: const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Mi Perfil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.catalogFilters),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
