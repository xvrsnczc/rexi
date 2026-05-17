# Qué debe existir en Supabase para que REXI responda bien

Referencia de código: `lib/core/config/supabase_tables.dart` y los `*_repository.dart`.

**Reglas generales**

1. Cada tabla expuesta a la app necesita **RLS** con políticas que permitan `select` / `insert` / `update` / `delete` según el caso, para `auth.uid()` (o tu lógica de negocio).
2. Los nombres en PostgREST son **sensibles a mayúsculas** si creaste columnas con comillas en SQL (`"Nombre"`). Si en la BD todo está en **snake_case** (`nombre`, `precio`), hay que **alinear el código** o crear **vistas** que expongan los nombres que usa la app.
3. Si el error dice que la tabla no existe pero con otro nombre (ej. `conversations` vs `Conversaciones`), o bien **renombras** en BD o **cambias** la constante en `supabase_tables.dart`.

---

## Ya viste en logs (ajustar primero)

| Problema | Qué hacer en Supabase / código |
|----------|--------------------------------|
| `column marketplace_products.Nombre does not exist` | La app selecciona `"Nombre"` y `"Precio"` (mayúsculas). Crea esas columnas con esos nombres **o** cambia los `select` en `store_repository.dart` / `search_repository.dart` a `nombre` / `precio` si así está tu tabla. |
| `Could not find table 'public.Conversaciones'` (sugiere `conversations`) | Crear tabla/vista `Conversaciones` **o** renombrar a lo que use el código **o** poner en código `conversations` si esa es tu tabla real. |

---

## 1. Auth (sin tabla propia)

- **Email / contraseña** (u otro proveedor) activo en Authentication.
- Perfil en app usa **User metadata**: `full_name`, `phone` vía `auth.updateUser` (no requiere tabla, solo que Auth permita actualizar metadata).

---

## 2. Tablas / vistas que el código usa hoy

### `marketplace_products` (tienda, búsqueda, carrito, favoritos, pedidos → nombres de producto)

**Uso:** catálogo, hot deals, detalle, joins por `product_id`.

**Columnas que el código intenta usar** (ajusta nombres o el código):

| Columna (código) | Uso |
|------------------|-----|
| `id` | PK |
| `Nombre` o `nombre` | título (select con `"Nombre"` en varios sitios) |
| `Precio` o `precio` | precio |
| `Estado` | filtro `'Activo'` en tienda y búsqueda |
| `image_urls` | lista de URLs |
| `seller_id` | vendedor |
| `created_at` | orden |
| `visibility_mode` | comentado en repo; opcional |

**RLS:** lectura para usuarios autenticados (o público si el catálogo es público).

---

### `users_profile`

**Uso:** vendedores nuevos, perfil público de vendedor, nombres en comentarios de video.

| Columna | Uso |
|---------|-----|
| `id` | mismo que `auth.users.id` típicamente |
| `full_name` | nombre mostrado |
| `avatar_url` | foto |
| `created_at` | orden “nuevos” |

**RLS:** `select` al menos para perfiles visibles; `update` del propio `id = auth.uid()`.

---

### `Carro`

| Columna | Uso |
|---------|-----|
| `id` | opcional para updates |
| `user_id` | `auth.uid()` |
| `product_id` | FK producto |
| `Cantidad` | entero |

**RLS:** el usuario solo su `user_id`.

---

### `Favoritos`

| Columna | Uso |
|---------|-----|
| `id` | para borrar por fila |
| `user_id` | |
| `product_id` | |
| `tipo` / `kind` | opcional |

**RLS:** por `user_id`.

---

### `Órdenes`

| Columna | Uso |
|---------|-----|
| `id` | PK |
| `user_id` | comprador |
| `Total` | numérico |
| `Estado` | texto (ej. `pendiente`; la app filtra “activos” por palabras clave) |
| `seller_id` o `vendedor_id` | **opcional** pero necesario para “Mis ventas” en la app |

**RLS:** comprador ve sus filas; si hay vendedor, políticas para que el vendedor vea las suyas.

---

### `order_items`

| Columna | Uso |
|---------|-----|
| `order_id` o `orden_id` | la app prueba ambos en lectura |
| `product_id` | |
| `quantity` o `Cantidad` | |
| `unit_price` o `precio_unitario` | |

**Insert checkout:** `order_id`, `product_id`, `quantity`, `unit_price` (si tu BD usa otros nombres, cambia `checkout_repository.dart`).

**RLS:** solo comprador (y vendedor si aplica) del pedido padre.

---

### `Conversaciones` (chat lista)

| Columna | Uso |
|---------|-----|
| `id` | |
| `buyer_id`, `seller_id` | filtro `.or('buyer_id.eq.uid,seller_id.eq.uid')` |
| `last_message_preview` | texto en lista |
| `last_message_at`, `updated_at` | orden |

Si tu tabla se llama `conversations`, crea una **vista** `Conversaciones` o cambia el nombre en código.

---

### `Mensajes`

| Columna | Uso |
|---------|-----|
| FK al hilo | `conversacion_id` **o** `conversation_id` |
| Cuerpo | `Mensaje` / `mensaje` / `body` / … |
| Remitente | `sender_id` / `user_id` / … (para “mío” vs “otro”) |

**Insert:** la app prueba `conversacion_id` + `sender_id` + `Mensaje`, luego variante con `conversation_id` + `user_id`.

**RLS:** solo participantes del hilo.

---

### Vistas `news_with_author` y `videos_with_author`

**Noticias:** `id`, `Título`, `Extracto`, `Contenido`, `is_published`, `published_at` o `created_at`.

**Videos:** `id`, `Título`, `thumbnail_url`, `is_published`, `created_at`, y para detalle/URL: `video_url` / `url` / `enlace` / etc.

**RLS:** según si son solo lectura pública o por usuario.

---

### `video_comments` (comentarios en detalle de video)

| Columna | Uso |
|---------|-----|
| `id` | PK |
| `video_id` | FK al video (mismo `id` que en la vista/tabla de videos) |
| `user_id` | `auth.uid()` |
| `body` | texto |
| `created_at` | orden |

Ejemplo SQL está en `docs/LO_FALTANTE_Y_ESTADO.md`. **RLS:** `select` público o autenticado; `insert` solo usuario autenticado.

---

### `unread_notifications` (vista recomendada) o tabla `Notificaciones`

**Vista/tabla:** `user_id`, `id`, `Título` / `titulo`, `Mensaje` / `mensaje`, `created_at`.

**Marcar leída:** la app hace `update` en `Notificaciones` con `leido` o `read`. Si solo existe la vista, el `update` fallará → conviene tabla base + vista de no leídas.

---

### `ledger_entries` (Cash / movimientos)

| Columna | Uso |
|---------|-----|
| `user_id` | |
| `Cantidad` / `amount` / … | importe |
| `balance_after_amount` | saldo mostrado |
| `transaction_type` / `description` / … | etiqueta en lista |
| `id` | orden |

---

### `wallet_projections` (opcional)

**Uso:** fallback de saldo si no hay `ledger_entries`. Columnas flexibles: `balance`, `saldo`, etc.

---

### `withdrawal_requests`

**Insert:** `user_id`, `amount`, `Estado` (`pendiente`).

Ajusta nombres en `cash_repository.dart` si tu tabla usa otros.

---

### `Empleos`

La app hace `select *` y mapea `Título`/`titulo`, `Empresa`/`empresa`, etc. Si la tabla no existe, la lista queda vacía sin crashear.

---

## 3. Constantes en código pero aún sin repositorio activo

Están en `SupabaseTables` para uso futuro; **no hace falta** crearlas solo por la app actual:

- `products_with_seller`
- `product_categories`
- `order_tracking`
- `Noticias` / `Vídeos` (tablas base; hoy se usan las **vistas** `news_with_author` / `videos_with_author`)
- `account_identity`
- `payment_intents`

---

## 4. Orden sugerido de trabajo en Supabase

1. Alinear **`marketplace_products`** (nombres de columnas) + RLS.  
2. Crear/alinear **`users_profile`**.  
3. **Auth** + metadata.  
4. **Carro**, **Favoritos**, **Órdenes**, **order_items** + RLS.  
5. **Chat**: `Conversaciones` + `Mensajes` (nombres exactos o vistas).  
6. Vistas **noticias** / **videos**.  
7. **Notificaciones** / `unread_notifications`.  
8. **ledger_entries** (+ opcional **wallet_projections**).  
9. **withdrawal_requests**.  
10. **video_comments**.  
11. **Empleos** si usas el módulo.

---

## 5. Comprobar desde el panel

- **Table Editor:** que existan tablas/vistas y columnas.  
- **API →** revisar que PostgREST expone el recurso (no solo SQL interno).  
- **Authentication → Policies:** cada tabla con RLS debe tener políticas que no devuelvan “permission denied” para flujos normales.

Si quieres, el siguiente paso puede ser **un script SQL por módulo** (solo esquema + RLS de ejemplo) alineado a tus nombres finales de columnas.
