class Facture {
  final int id;
  final String walletCode;
  final String reference;
  final String serviceName;
  final String unite;
  final double amount;
  final String dueDate;
  final bool paid;

  Facture({
    required this.id,
    required this.walletCode,
    required this.reference,
    required this.serviceName,
    required this.unite,
    required this.amount,
    required this.dueDate,
    required this.paid,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      walletCode: json['walletCode'] ?? '',
      reference: json['reference'] ?? '',
      serviceName: json['serviceName'] ?? '',
      unite: json['unite'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
      paid: json['paid'] ?? false,
    );
  }
}