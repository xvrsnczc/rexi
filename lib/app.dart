import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';

/// [MaterialApp.router] + tema global REXI.
class RexiApp extends StatelessWidget {
  const RexiApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'REXI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
