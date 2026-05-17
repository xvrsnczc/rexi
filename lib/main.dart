// Punto de entrada: arranque (env, Supabase) y [RexiApp] (`lib/app.dart`).
// Mapa de carpetas: `lib/rexi_app_map.dart`.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'app_router.dart';
import 'core/config/supabase_config.dart';

/// Misma ruta que en [pubspec.yaml] → `flutter: assets:`.
const _envAssetPath = 'assets/.env';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    var raw = await rootBundle.loadString(_envAssetPath);
    if (raw.trim().isEmpty) {
      runApp(const _BootErrorApp(
        message:
            'assets/.env está vacío. Pon SUPABASE_URL y SUPABASE_ANON_KEY (una por línea, sin comillas).',
      ));
      return;
    }
    // Windows a veces guarda UTF-8 con BOM; sin esto la clave queda "\uFEFFSUPABASE_URL" y falla.
    if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
      raw = raw.substring(1);
    }
    dotenv.testLoad(fileInput: raw);
  } catch (e, st) {
    debugPrint('Error cargando $_envAssetPath: $e\n$st');
    runApp(_BootErrorApp(
      message:
          'No se pudo leer $_envAssetPath dentro del APK.\n\n'
          'En la PC el archivo puede existir, pero hay que volver a empaquetar:\n'
          'flutter clean\n'
          'flutter pub get\n'
          'flutter run\n\n'
          'Comprueba en pubspec.yaml:\n'
          '  flutter:\n'
          '    assets:\n'
          '      - assets/.env\n\n'
          'Detalle: $e',
    ));
    return;
  }

  if (!SupabaseConfig.isConfigured) {
    runApp(const _BootErrorApp(
      message:
          'Configura SUPABASE_URL y SUPABASE_ANON_KEY en assets/.env (valores reales del proyecto).',
    ));
    return;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e, st) {
    debugPrint('Supabase.initialize: $e\n$st');
    runApp(_BootErrorApp(message: 'No se pudo conectar a Supabase:\n$e'));
    return;
  }

  runApp(RexiApp(router: createAppRouter()));
}

class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
