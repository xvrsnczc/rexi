# REXI

Marketplace **web** (PWA): pestañas **Menú · Tienda · Cash · Noticias · Videos · Chat**, más **perfil**, **carrito** y **ajustes**. Módulo **repartidor** con carga diferida y cola local (Hive).

## Documentación

- [`docs/ARQUITECTURA_CARPETAS.md`](docs/ARQUITECTURA_CARPETAS.md) — carpetas, reglas y mapa UI ↔ código.
- [`docs/MODULO_REPARTIDOR_WEB.md`](docs/MODULO_REPARTIDOR_WEB.md) — descarga bajo demanda, offline, límites.

## Configuración

`assets/.env` con `SUPABASE_URL` y `SUPABASE_ANON_KEY`.

```bash
flutter pub get
flutter run -d chrome
flutter build web
```

## Estructura rápida

- `features/shell` — contenedor con `IndexedStack` (cambio de pestaña rápido).
- `shared/widgets` — piezas reutilizables de la tienda (tarjetas, banner).
- `features/delivery` — ruta `/repartidor`, import **deferred** + `DeliveryLocalStore`.
