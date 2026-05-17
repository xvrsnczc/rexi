import 'package:flutter/material.dart';

import 'transactions_screen.dart';
import 'wallet_screen.dart';
import 'withdraw_screen.dart';

/// Resumen Cash (enlaza a billetera / movimientos / retiros).
class CashScreen extends StatelessWidget {
  const CashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'REXI Cash',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Consulta saldo, movimientos y retiros.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WalletScreen()),
          ),
          child: const Text('Billetera'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
          ),
          child: const Text('Movimientos'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WithdrawScreen()),
          ),
          child: const Text('Retirar'),
        ),
      ],
    );
  }
}
