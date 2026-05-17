import 'package:flutter/material.dart';

import '../data/cash_repository.dart';
import '../domain/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<TransactionModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = CashRepository.instance.transactions();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = CashRepository.instance.transactions();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<TransactionModel>>(
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
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(child: Text('Error: ${snap.error}')),
                ],
              );
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  Center(child: Text('Sin movimientos en el libro mayor.')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = list[i];
                return ListTile(
                  title: Text(t.label),
                  trailing: Text(
                    '\$${t.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
