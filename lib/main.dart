import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'models/transaction.dart';
import 'models/card.dart';
import 'models/loan.dart';
import 'models/bill_payment.dart';
import 'services/storage_service.dart';
import 'services/seeder.dart';
import 'providers/auth_provider.dart';
import 'providers/banking_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(VirtualCardAdapter());
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(BillPaymentAdapter());

  // Initialize storage service
  await StorageService.instance.init();

  // Seed initial data if not already seeded
  await Seeder.seed();

  runApp(const VBBankApp());
}

class VBBankApp extends StatelessWidget {
  const VBBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'VB Bank Mobile',
            debugShowCheckedModeBanner: false,
            theme: authProvider.isDarkTheme
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            initialRoute: AppRouter.login,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              // Set system UI overlay style based on theme
              SystemChrome.setSystemUIOverlayStyle(
                authProvider.isDarkTheme
                    ? SystemUiOverlayStyle.light.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: const Color(0xFF0a0e27),
                      )
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.white,
                      ),
              );
              return GestureDetector(
                // Dismiss keyboard/focus when tapping outside input fields
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
