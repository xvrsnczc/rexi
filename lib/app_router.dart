import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/utils/go_router_refresh.dart';
import 'features/activity/presentation/cart_screen.dart';
import 'features/activity/presentation/favorites_screen.dart';
import 'features/activity/presentation/orders_screen.dart';
import 'features/arcade/presentation/arcade_screen.dart';
import 'features/arcova_ia/presentation/arcova_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/catalog_filters/presentation/screens/catalog_filters_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/delivery/presentation/screens/repartidor_loader_screen.dart';
import 'features/empleos/presentation/jobs_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/settings_screen.dart';
import 'features/rexi_core/presentation/core_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';

GoRouter createAppRouter() {
  final client = Supabase.instance.client;

  return GoRouter(
    initialLocation: AppRoutes.app,
    refreshListenable: GoRouterRefreshStream(client.auth.onAuthStateChange),
    redirect: (context, state) {
      final session = client.auth.currentSession;
      final loggedIn = session != null;
      final loc = state.matchedLocation;

      if (!loggedIn) {
        if (loc == AppRoutes.login ||
            loc == AppRoutes.register ||
            loc == AppRoutes.forgotPassword) {
          return null;
        }
        return AppRoutes.login;
      }

      if (loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.forgotPassword) {
        return AppRoutes.app;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.app,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.repartidor,
        builder: (_, __) => const RepartidorLoaderScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalogFilters,
        builder: (_, __) => const CatalogFiltersScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.arcade,
        builder: (_, __) => const ArcadeScreen(),
      ),
      GoRoute(
        path: AppRoutes.rexiCore,
        builder: (_, __) => const CoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.arcovaIa,
        builder: (_, __) => const ArcovaScreen(),
      ),
      GoRoute(
        path: AppRoutes.empleos,
        builder: (_, __) => const JobsScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
}
