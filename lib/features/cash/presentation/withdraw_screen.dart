import 'package:flutter/material.dart';

import '../data/cash_repository.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amount = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final v = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (v == null || v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe válido.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final err = await CashRepository.instance.submitWithdrawal(v);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err == null) {
      _amount.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar: $err'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retiro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Solicitud de retiro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Se guarda en withdrawal_requests (user_id, amount, Estado pendiente).',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Importe',
                prefixText: r'$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}
