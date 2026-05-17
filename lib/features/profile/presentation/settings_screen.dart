import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
