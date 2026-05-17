# Módulo repartidor en web — qué sí y qué no

## ¿Se puede “descargar” solo el repartidor dentro de la app?

**En parte, sí (técnicamente):**

- En **Flutter web**, el código del repartidor (`repartidor_home_screen` + Hive + lógica asociada) va en un **chunk separado** usando `import ... deferred as repartidor` y `loadLibrary()`.
- Hasta que el usuario **no** abre la ruta `/repartidor`, ese fragmento **no se descarga**. Así la **primera carga** para compradores es más ligera.
- **No** es una “app aparte” en la tienda de aplicaciones: sigue siendo la misma PWA / sitio, con un **módulo bajo demanda**.

## ¿Sale de la aplicación?

**No.** Es una pantalla a pantalla completa con botón **atrás** que vuelve al contenedor principal (pestañas). Sigue siendo el mismo origen y el mismo `GoRouter`.

## Bajo consumo de datos y zonas sin señal

**Lo que hace el código hoy:**

- **Cola local** con **Hive** (en web usa **IndexedDB**): puedes guardar entregas o eventos sin red y listarlos en pantalla.
- Cuando haya conexión, un repositorio en `features/delivery/data/` debería **enviar** esa cola a Supabase y borrar entradas sincronizadas (pendiente de implementar el `sync` real).

**Límites honestos:**

- Sin red **no** puedes autenticarte ni consultar catálogo en vivo desde el servidor.
- **Offline completo** (toda la UI sin internet) requiere cachear también assets y datos con **service worker** personalizado y/o más almacenamiento local; Flutter ya genera un SW básico en `build web`, pero no sustituye un diseño offline-first completo por sí solo.
- Para **fotos o mapas** pesados, conviene compresión, paginación y endpoints mínimos (eso es trabajo de API y UI, no solo del módulo).

## Resumen

| Objetivo | Estado |
|----------|--------|
| Chunk solo para repartidor | Sí (`deferred`) |
| Cola local sin red | Sí (Hive / IndexedDB, demo en UI) |
| Sincronizar con Supabase | Implementar en `data/` |
| App instalable (PWA) | `manifest` + `build web` |
| Cero datos móviles en túnel, etc. | Requiere diseño adicional |
