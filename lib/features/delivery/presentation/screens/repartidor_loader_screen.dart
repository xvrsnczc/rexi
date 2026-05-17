import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rexi/features/delivery/presentation/screens/repartidor_home_screen.dart'
    deferred as repartidor;

/// Carga el **chunk** del repartidor solo al entrar (web: menos JS inicial para el resto).
class RepartidorLoaderScreen extends StatefulWidget {
  const RepartidorLoaderScreen({super.key});

  @override
  State<RepartidorLoaderScreen> createState() => _RepartidorLoaderScreenState();
}

class _RepartidorLoaderScreenState extends State<RepartidorLoaderScreen> {
  bool _ready = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await repartidor.loadLibrary();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Repartidor'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error cargando módulo:\n$_error'),
          ),
        ),
      );
    }
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Repartidor'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return repartidor.RepartidorHomeScreen();
  }
}
