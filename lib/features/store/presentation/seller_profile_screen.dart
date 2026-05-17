import 'package:flutter/material.dart';

import '../data/store_repository.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendedor')),
      body: FutureBuilder(
        future: StoreRepository.instance.fetchPublicProfile(sellerId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No hay perfil en users_profile para este vendedor ($sellerId).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: p.avatarUrl != null && p.avatarUrl!.isNotEmpty
                    ? NetworkImage(p.avatarUrl!)
                    : null,
                child: p.avatarUrl == null || p.avatarUrl!.isEmpty
                    ? Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                p.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: $sellerId',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}
