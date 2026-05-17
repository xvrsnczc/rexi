/// Mapa de carpetas REXI (Clean Architecture + feature-first).
///
/// - `lib/app.dart` + `lib/app_router.dart` — MaterialApp y GoRouter.
/// - `lib/core/` — constantes, tema, rutas nombradas, widgets globales (`badge_label`, …), utils.
/// - `lib/features/<feature>/` — `data/`, `domain/`, `presentation/`.
///
/// ### Contenedor principal (pestañas)
/// `features/home/presentation/home_screen.dart` — IndexedStack (tienda, efectivo, noticias, videos, chat).
///
/// ### Menú lateral / Mi actividad
/// `features/menu/` — drawer; `features/activity/` — carrito, pedidos, favoritos.
///
/// ### Tienda y módulos REXI
/// `features/store/`, `cash/`, `news/`, `videos/`, `chat/`, `profile/`, `auth/`.
///
/// ### Arcade, Core, Arcova, Empleos
/// `features/arcade/`, `rexi_core/`, `arcova_ia/`, `empleos/`.
///
/// Repartidor, checkout, búsqueda y el resto siguen el mismo patrón bajo `features/`.
///
/// Inventario de módulos listos vs pendientes: `docs/LO_FALTANTE_Y_ESTADO.md`.
library;
