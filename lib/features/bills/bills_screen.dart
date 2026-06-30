import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/facture.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  List<Facture> _factures = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;
  bool _paying = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  Future<void> _loadFactures() async {
    setState(() => _loading = true);
    try {
      final walletCode = (await _storage.read(key: 'walletCode')) ?? '';
      final data = await _apiClient.get('/external/factures/$walletCode/current');
      final list = (data as List?) ?? [];
      setState(() {
        _factures = list.map((f) => Facture.fromJson(f)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _paySelected() async {
    if (_selectedIds.isEmpty) return;
    setState(() { _paying = true; _error = null; _success = null; });

    try {
      final phone = (await _storage.read(key: 'phone')) ?? '';
      final references = _factures.where((f) => _selectedIds.contains(f.id)).map((f) => f.reference).toList();
      await _apiClient.post('/wallets/pay-factures', body: {
        'phoneNumber': phone,
        'serviceName': _factures.first.serviceName,
        'factureReferences': references,
      });
      setState(() {
        _success = '${_selectedIds.length} facture(s) payée(s) !';
        _selectedIds.clear();
      });
      _loadFactures();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Erreur de connexion');
    } finally {
      setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = (double v) => NumberFormat.currency(locale: 'fr_SN', symbol: 'XOF', decimalDigits: 0).format(v);

    return Scaffold(
      appBar: AppBar(title: const Text('Factures')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (_factures.isEmpty)
                const Expanded(child: Center(child: Text('🎉 Aucune facture impayée !')))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _factures.length,
                    itemBuilder: (context, index) {
                      final facture = _factures[index];
                      final isSelected = _selectedIds.contains(facture.id);
                      return Card(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(facture.id);
                              } else {
                                _selectedIds.add(facture.id);
                              }
                            });
                          },
                          title: Text('${facture.serviceName} - ${facture.unite}'),
                          subtitle: Text('${facture.reference}\nÉchéance: ${facture.dueDate}'),
                          secondary: Text(formatCurrency(facture.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                      onPressed: _paying ? null : _paySelected,
                      child: _paying
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Payer ${_selectedIds.length} facture(s)'),
                    ),
                  ),
                ),
              if (_error != null) Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
              if (_success != null) Text(_success!, style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
            ],
          ),
    );
  }
} 