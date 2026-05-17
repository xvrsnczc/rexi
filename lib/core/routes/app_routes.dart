/// Rutas de [GoRouter]. Ver `lib/app_router.dart`.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/recuperar';

  /// Contenedor principal (pestañas: Menú, Tienda, …).
  static const app = '/';

  static const repartidor = '/repartidor';
  static const cart = '/carrito';
  static const search = '/buscar';
  static const catalogFilters = '/filtros';
  static const checkout = '/checkout';
  static const orders = '/pedidos';
  static const favorites = '/favoritos';
  static const profile = '/perfil';
  static const settings = '/ajustes';

  static const arcade = '/arcade';
  static const rexiCore = '/rexi-core';
  static const arcovaIa = '/arcova-ia';
  static const empleos = '/empleos';
  static const notifications = '/notificaciones';
}
