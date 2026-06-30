import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  double _balance = 0;
  List<Transaction> _recentTransactions = [];
  bool _loading = true;
  bool _hideBalance = false;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _phone = (await _storage.read(key: 'phone')) ?? '';
    try {
      final balanceData = await _apiClient.get('/wallets/$_phone/balance');
      final transactionsData = await _apiClient.get('/wallets/$_phone/transactions');
      setState(() {
        _balance = (balanceData['balance'] ?? 0).toDouble();
        final list = (transactionsData as List?) ?? [];
        _recentTransactions = list.take(5).map((t) => Transaction.fromJson(t)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_SN', symbol: 'XOF', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BadWallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _storage.deleteAll();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF3949AB)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('SOLDE DISPONIBLE', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _hideBalance = !_hideBalance),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _hideBalance ? '*****' : _formatCurrency(_balance),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(_hideBalance ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(icon: Icons.send, label: 'Transférer', onTap: () => Navigator.pushNamed(context, '/transfer')),
                    _ActionButton(icon: Icons.receipt, label: 'Factures', onTap: () => Navigator.pushNamed(context, '/bills')),
                    _ActionButton(icon: Icons.history, label: 'Historique', onTap: () => Navigator.pushNamed(context, '/history')),
                  ],
                ),
                const SizedBox(height: 24),
                // Recent transactions
                const Text('Transactions récentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._recentTransactions.map((tx) => _TransactionTile(transaction: tx, formatCurrency: _formatCurrency)),
              ],
            ),
          ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String Function(double) formatCurrency;

  const _TransactionTile({required this.transaction, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.isPositive ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
        child: Icon(
          transaction.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
          color: transaction.isPositive ? AppTheme.successColor : AppTheme.errorColor,
        ),
      ),
      title: Text(transaction.description.isNotEmpty ? transaction.description : transaction.type),
      subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(transaction.createdAt))),
      trailing: Text(
        '${transaction.isPositive ? "+" : "-"}${formatCurrency(transaction.amount)}',
        style: TextStyle(
          color: transaction.isPositive ? AppTheme.successColor : AppTheme.errorColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}