import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Edición de nombre y teléfono (metadata de usuario en Supabase).
class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = Supabase.instance.client.auth.currentUser;
    final meta = u?.userMetadata;
    _name = TextEditingController(text: (meta?['full_name'] as String?) ?? '');
    _phone = TextEditingController(text: (meta?['phone'] as String?) ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _message = null;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _name.text.trim(),
            'phone': _phone.text.trim(),
          },
        ),
      );
      if (mounted) {
        setState(() => _message = 'Cambios guardados.');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
