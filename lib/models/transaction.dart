class Transaction {
  final int id;
  final String type;
  final double amount;
  final double fee;
  final double balanceAfter;
  final String description;
  final String createdAt;
  final String counterpartyPhone;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fee,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
    required this.counterpartyPhone,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      counterpartyPhone: json['counterpartyPhone'] ?? '',
    );
  }

  bool get isPositive => type == 'DEPOSIT' || type == 'TRANSFER_IN';
}