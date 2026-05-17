import 'dart:async';

import 'package:flutter/foundation.dart';

/// Hace que [GoRouter] se reconstruya cuando cambia el stream (p. ej. sesión Supabase).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
