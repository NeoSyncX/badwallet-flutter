import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _destinationController = TextEditingController();
  final _amountController = TextEditingController();
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _transfer() async {
    final destination = _destinationController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (destination.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Veuillez remplir tous les champs');
      return;
    }

    setState(() { _loading = true; _error = null; _success = null; });

    try {
      final phone = (await _storage.read(key: 'phone')) ?? '';
      await _apiClient.post('/wallets/transfer', body: {
        'senderPhone': phone,
        'receiverPhone': destination,
        'amount': amount,
      });
      setState(() => _success = 'Transfert de ${amount.toInt()} XOF réussi !');
      _destinationController.clear();
      _amountController.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Erreur de connexion');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfert')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.send, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 32),
            TextField(
              controller: _destinationController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro du destinataire',
                hintText: '+221770000002',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Montant (XOF)',
                hintText: '5000',
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
            ),
            if (_success != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_success!, style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _transfer,
                child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}