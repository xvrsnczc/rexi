import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/notifications_repository.dart';
import '../../domain/notification_item.dart';

/// Centro de notificaciones (lista + marcar leída en tabla cuando RLS lo permita).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationsRepository.instance.list();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = NotificationsRepository.instance.list();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<NotificationItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  Center(child: Text('No hay notificaciones.')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
                return Card(
                  child: ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    isThreeLine: true,
                    trailing: const Icon(Icons.touch_app_outlined, size: 20),
                    onTap: () async {
                      await NotificationsRepository.instance.markAsRead(n.id);
                      if (!context.mounted) return;
                      await showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                n.title,
                                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(n.body, style: Theme.of(ctx).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
