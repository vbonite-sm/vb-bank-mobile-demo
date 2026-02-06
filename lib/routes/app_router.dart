import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/biometric_setup_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/transfer/transfer_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/topup/topup_screen.dart';
import '../screens/bills/bill_pay_screen.dart';
import '../screens/cards/cards_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String biometricSetup = '/biometric-setup';
  static const String dashboard = '/dashboard';
  static const String transfer = '/transfer';
  static const String history = '/history';
  static const String topup = '/topup';
  static const String bills = '/bills';
  static const String cards = '/cards';
  static const String loans = '/loans';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return _buildRoute(const LoginScreen(), routeSettings);
      case register:
        return _buildRoute(const RegisterScreen(), routeSettings);
      case biometricSetup:
        return _buildRoute(const BiometricSetupScreen(), routeSettings);
      case dashboard:
        return _buildRoute(const DashboardScreen(), routeSettings);
      case transfer:
        return _buildRoute(const TransferScreen(), routeSettings);
      case history:
        return _buildRoute(const HistoryScreen(), routeSettings);
      case topup:
        return _buildRoute(const TopUpScreen(), routeSettings);
      case bills:
        return _buildRoute(const BillPayScreen(), routeSettings);
      case cards:
        return _buildRoute(const CardsScreen(), routeSettings);
      case loans:
        return _buildRoute(const LoansScreen(), routeSettings);
      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${routeSettings.name}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          routeSettings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(
      Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
