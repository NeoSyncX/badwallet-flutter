import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  List<Transaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    try {
      final phone = (await _storage.read(key: 'phone')) ?? '';
      final data = await _apiClient.get('/wallets/$phone/transactions');
      final list = (data as List?) ?? [];
      setState(() {
        _transactions = list.map((t) => Transaction.fromJson(t)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = (double v) => NumberFormat.currency(locale: 'fr_SN', symbol: 'XOF', decimalDigits: 0).format(v);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _transactions.isEmpty
          ? const Center(child: Text('Aucune transaction'))
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tx.isPositive ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                        child: Icon(
                          tx.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx.isPositive ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                      title: Text(tx.type),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tx.description.isNotEmpty) Text(tx.description),
                          Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(tx.createdAt))),
                        ],
                      ),
                      trailing: Text(
                        '${tx.isPositive ? "+" : "-"}${formatCurrency(tx.amount)}',
                        style: TextStyle(
                          color: tx.isPositive ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}