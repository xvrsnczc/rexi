# Arquitectura REXI (Flutter)

Clean Architecture + **feature-first**: cada módulo con `data/`, `domain/`, `presentation/`.

## Raíz `lib/`

| Ruta | Rol |
|------|-----|
| `main.dart` | `runApp`, init Supabase / `.env` |
| `app.dart` | `MaterialApp.router`, tema |
| `app_router.dart` | `GoRouter`, rutas |
| `rexi_app_map.dart` | Índice comentado del árbol |
| `core/` | Constantes, tema, **routes**, widgets globales, utils, config |
| `features/` | Dominios de producto |
| `shared/` | Modelos/widgets compartidos cuando apliquen |

## `core/`

- `constants/` — `app_colors`, `app_strings`, `app_sizes`
- `routes/` — `app_routes.dart` (rutas nombradas)
- `theme/` — `app_theme.dart`
- `widgets/` — `custom_navbar.dart` ([RexiTopTabBar]), `product_card`, `badge_label` ([RexiBadgeLabel]), `carousel_widget`, `promo_banner_card`, `section_header_row`
- `utils/` — `formatters`, `validators`, `go_router_refresh`
- `config/` — Supabase

## Features principales (como en tu diagrama)

- `auth/` — `data/auth_repository`, `domain/auth_model`, `presentation/login_screen`, `register_screen`, `forgot_password_screen`
- `home/` — contenedor de pestañas `home_screen.dart`, `home_controller`, `home_repository`, `banner_model`, widgets (menú, `banner_carousel`, secciones)
- `store/` — tienda: `store_screen`, detalle producto/vendedor, `store_repository`, modelos, widgets (`product_grid`, `filter_sheet`, `price_tag`, …)
- `cash/` — `cash_screen`, `wallet_screen`, `transactions_screen`, `withdraw_screen` + repo/modelo
- `news/` — feed, detalle, `article_card`, repositorio
- `videos/` — lista, detalle, reproductor, comentarios
- `chat/` — lista, detalle, `message_bubble`
- `profile/` — `profile_screen`, `settings_screen`, `my_purchases_screen`, `my_sales_screen`

- `menu/` — `menu_drawer`, items y cabecera de usuario (`features/menu/`)
- `activity/` — carrito, pedidos, favoritos (`cart_screen`, `orders_screen`, `favorites_screen`)

Otros módulos (`checkout`, `search`, `delivery`, `arcade`, `empleos`, `arcova_ia`, `rexi_core`, …) siguen el mismo patrón bajo `features/`.

## `assets/` (recomendado)

- `assets/.env` — claves Supabase (no versionar; copia desde `assets/.env.example`).
- `assets/images/`, `assets/icons/`, `assets/fonts/` — declarar en `pubspec.yaml` cuando añadas archivos.

## Reglas de dependencias

- `features/*` → `core`, `shared`; no imports cruzados entre features salvo casos muy acotados (ideal: ninguno).
- `core` → no importa `features`.
