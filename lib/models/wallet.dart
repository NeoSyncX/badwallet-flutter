class Wallet {
  final int id;
  final String phoneNumber;
  final double balance;
  final String currency;
  final String code;
  final String email;

  Wallet({
    required this.id,
    required this.phoneNumber,
    required this.balance,
    required this.currency,
    required this.code,
    required this.email,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      code: json['code'] ?? '',
      email: json['email'] ?? '',
    );
  }
}