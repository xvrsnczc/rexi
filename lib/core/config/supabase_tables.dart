/// Nombres de tablas/vistas en Supabase (un solo lugar para alinear con el proyecto).
abstract final class SupabaseTables {
  // Tienda
  static const marketplaceProducts = 'marketplace_products';
  static const productsWithSeller = 'products_with_seller';
  static const productCategories = 'product_categories';

  // Actividad (nombres que indicaste; si PostgREST falla, prueba minúsculas en BD)
  static const carro = 'Carro';
  static const favoritos = 'Favoritos';
  static const ordenes = 'Órdenes';
  static const orderItems = 'order_items';
  static const orderTracking = 'order_tracking';

  // Chat
  static const conversaciones = 'Conversaciones';
  static const mensajes = 'Mensajes';

  // Contenido
  static const noticias = 'Noticias';
  static const videos = 'Vídeos';
  static const newsWithAuthor = 'news_with_author';
  static const videosWithAuthor = 'videos_with_author';

  /// Comentarios bajo cada video (`video_id`, `user_id`, `body`, `created_at`).
  static const videoComments = 'video_comments';

  // Notificaciones
  static const notificaciones = 'Notificaciones';
  static const unreadNotifications = 'unread_notifications';

  // Usuarios
  static const usersProfile = 'users_profile';
  static const accountIdentity = 'account_identity';

  /// Ofertas de empleo (nombre a confirmar en el panel SQL; si no existe, el repo devuelve []).
  static const empleos = 'Empleos';

  // Finanzas
  static const ledgerEntries = 'ledger_entries';
  static const walletProjections = 'wallet_projections';
  static const withdrawalRequests = 'withdrawal_requests';
  static const paymentIntents = 'payment_intents';
}
