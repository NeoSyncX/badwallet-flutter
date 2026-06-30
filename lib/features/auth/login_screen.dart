import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Veuillez entrer un numéro');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final data = await _apiClient.get('/wallets/$phone');
      final wallet = data as Map<String, dynamic>;
      await _storage.write(key: 'phone', value: phone);
      await _storage.write(key: 'walletCode', value: wallet['code'] ?? '');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 16),
                    Text('BadWallet', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Connectez-vous à votre compte'),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: '+221770000001',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Se connecter'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}