import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_tables.dart';
import '../../../core/data/supabase_json.dart';
import '../domain/transaction_model.dart';

/// `ledger_entries`: `Cantidad`, `user_id` (texto en tu BD), `transaction_type`, `balance_after_amount`, …
/// Saldo: último `balance_after_amount` del libro, o proyección de billetera.
class CashRepository {
  CashRepository._();

  static final CashRepository instance = CashRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<double> balance() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 0;

    final ledgerRows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.ledgerEntries)
          .select('balance_after_amount')
          .eq('user_id', uid)
          .order('id', ascending: false)
          .limit(1),
    );
    if (ledgerRows.isNotEmpty) {
      final v = ledgerRows.first['balance_after_amount'];
      if (v != null) return asDouble(v);
    }

    try {
      final rows = supabaseAsMapList(
        await _client
            .from(SupabaseTables.walletProjections)
            .select('*')
            .eq('user_id', uid)
            .limit(1),
      );
      if (rows.isEmpty) return 0;
      final r = rows.first;
      return asDouble(
        r['balance'] ?? r['saldo'] ?? r['available'] ?? r['balance_after_amount'],
      );
    } catch (_) {
      return 0;
    }
  }

  Future<List<TransactionModel>> transactions() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final rows = supabaseAsMapList(
      await _client
          .from(SupabaseTables.ledgerEntries)
          .select('*')
          .eq('user_id', uid)
          .order('id', ascending: false)
          .limit(100),
    );

    return rows
        .map(
          (r) {
            final amt = asDouble(
              r['Cantidad'] ?? r['cantidad'] ?? r['amount'] ?? r['monto'] ?? r['importe'],
            );
            final label = pickStr(r, [
                  'transaction_type',
                  'reason_type',
                  'description',
                  'descripcion',
                  'tipo',
                  'concepto',
                  'Moneda',
                ]) ??
                'Movimiento';
            return TransactionModel(
              id: pickStr(r, ['id']) ?? '',
              amount: amt,
              label: label,
            );
          },
        )
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  /// Solicitud en [SupabaseTables.withdrawalRequests]. Ajusta columnas si tu tabla difiere.
  Future<String?> submitWithdrawal(double amount) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 'Inicia sesión.';
    if (amount <= 0) return 'Indica un importe mayor que cero.';
    try {
      await _client.from(SupabaseTables.withdrawalRequests).insert({
        'user_id': uid,
        'amount': amount,
        'Estado': 'pendiente',
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
