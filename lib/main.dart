import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/transfers/transfer_screen.dart';
import 'features/bills/bills_screen.dart';
import 'features/history/history_screen.dart';

void main() {
  runApp(const BadWalletApp());
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BadWallet',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/transfer': (context) => const TransferScreen(),
        '/bills': (context) => const BillsScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}