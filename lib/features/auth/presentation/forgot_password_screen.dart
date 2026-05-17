import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _message = 'Correo no válido');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        setState(() => _message = 'Revisa tu correo para restablecer la contraseña.');
      }
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar enlace'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
