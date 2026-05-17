# REXI — Una sola lista: fuera de Supabase o por verificar

Todo lo que **ya usa tablas/vistas de Supabase** está en código con nombres en `lib/core/config/supabase_tables.dart`.  
Esta lista es **solo** lo que **no** depende de tu proyecto remoto o hay que **validar en el panel SQL / RLS**.

---

## Por verificar en Supabase (esquema y políticas)

1. **`order_items`** — columnas `order_id`, `product_id`, `quantity`, `unit_price` en inserts de checkout; si usas otros nombres, ajusta `checkout_repository.dart`.
2. **`Órdenes`** — columnas al crear pedido: `user_id`, `Total`, `Estado`; ventas: si existe `seller_id` / `vendedor_id` para “Mis ventas”.
3. **`Mensajes`** — insert al enviar chat: `conversacion_id` (o `conversation_id`), cuerpo `Mensaje`, y columna de remitente que acepte RLS.
4. **`withdrawal_requests`** — columnas para retiros (p. ej. `user_id`, `amount`, `Estado`); si la tabla no existe, el botón Retirar mostrará el error.
5. **`Notificaciones`** — marcar leída: columnas `leido` / `read_at` si quieres persistir; si es solo vista `unread_notifications`, el tap puede no persistir.
6. **`Empleos`** — nombre real de la tabla y columnas de título/empresa (o deja la app con lista vacía).
7. **`video_comments`** — tabla esperada: `video_id`, `user_id`, `body`, `created_at` (nombre en código: `SupabaseTables.videoComments`). Ejemplo SQL:

```sql
create table public.video_comments (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);
```

   Activa RLS y políticas `select`/`insert` para usuarios autenticados según tu modelo.

8. **RLS** en todas las tablas anteriores + `Carro`, `Favoritos`, `ledger_entries`, vistas de noticias/videos.

---

## Fuera de Supabase (producto local / demo — no bloquea el resto)

| Módulo | Qué es |
|--------|--------|
| **REXI Arcade** | Juegos demo sin tabla. |
| **REXI Core** | Artículos estáticos demo. |
| **ARCOVA IA** | Falta Edge Function / API + clave en `.env`. |
| **Repartidor** | Cola offline Hive; sync con backend por definir. |

---

## Referencia rápida (sí en Supabase en la app)

Tienda, búsqueda, carrito, favoritos, pedidos, **detalle de pedido con líneas `order_items`**, checkout, noticias, videos (**comentarios** si existe `video_comments`), chat lista + envío, notificaciones (lista), cash/saldo/movimientos, perfil auth/metadata, empleos (si hay tabla), filtros guardados en Hive (local). **Pull-to-refresh** en pedidos, favoritos, carrito, noticias, videos, chat, notificaciones, movimientos, compras/ventas y billetera.
