import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/app_routes.dart';
import 'my_purchases_screen.dart';
import 'my_sales_screen.dart';
import 'widgets/avatar_verified.dart';
import 'widgets/edit_profile_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AvatarVerified(
                  verified: u?.emailConfirmedAt != null,
                ),
                const SizedBox(height: 16),
                const EditProfileForm(),
              ],
            ),
          ),
          ListTile(
            title: const Text('Correo'),
            subtitle: Text(u?.email ?? '—'),
          ),
          ListTile(
            title: const Text('Nombre (metadata)'),
            subtitle: Text(
              (u?.userMetadata?['full_name'] as String?) ?? '—',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Mis compras'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyPurchasesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Mis ventas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MySalesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ajustes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
