import 'package:flutter/material.dart';

import '../data/cash_repository.dart';
import 'transactions_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<double> _future;

  @override
  void initState() {
    super.initState();
    _future = CashRepository.instance.balance();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = CashRepository.instance.balance();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billetera'),
        actions: [
          IconButton(
            tooltip: 'Movimientos',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<double>(
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
            final bal = snap.data ?? 0.0;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Saldo estimado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${bal.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const TransactionsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text('Ver movimientos'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
