import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final phone = await _storage.read(key: 'phone');
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        phone != null ? '/dashboard' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 100, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text('BadWallet', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}