class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.label,
  });

  final String id;
  final double amount;
  final String label;
}
