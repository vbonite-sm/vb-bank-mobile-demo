class AppConstants {
  // App Info
  static const String appName = 'VB Bank';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Digital Banking Partner';

  // Storage Keys
  static const String sessionKey = 'user_session';
  static const String themeKey = 'app_theme';
  static const String biometricKey = 'biometric_enabled';
  static const String savedUsernameKey = 'saved_username';
  static const String onboardingKey = 'onboarding_completed';

  // Hive Box Names
  static const String usersBox = 'users';
  static const String transactionsBox = 'transactions';
  static const String cardsBox = 'cards';
  static const String loansBox = 'loans';
  static const String billPaymentsBox = 'bill_payments';

  // API URLs
  static const String cryptoApiUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd';
  static const String currencyApiUrl =
      'https://open.er-api.com/v6/latest/USD';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const double minTransferAmount = 0.01;
  static const double maxTransferAmount = 1000000.0;

  // Loan Options
  static const Map<String, Map<String, dynamic>> loanOptions = {
    'personal': {
      'name': 'Personal Loan',
      'minAmount': 1000.0,
      'maxAmount': 50000.0,
      'minTerm': 6,
      'maxTerm': 60,
      'interestRate': 8.5,
      'icon': 'person',
    },
    'auto': {
      'name': 'Auto Loan',
      'minAmount': 5000.0,
      'maxAmount': 100000.0,
      'minTerm': 12,
      'maxTerm': 84,
      'interestRate': 5.9,
      'icon': 'directions_car',
    },
    'home': {
      'name': 'Home Loan',
      'minAmount': 50000.0,
      'maxAmount': 1000000.0,
      'minTerm': 60,
      'maxTerm': 360,
      'interestRate': 3.5,
      'icon': 'home',
    },
    'education': {
      'name': 'Education Loan',
      'minAmount': 2000.0,
      'maxAmount': 200000.0,
      'minTerm': 12,
      'maxTerm': 120,
      'interestRate': 4.5,
      'icon': 'school',
    },
  };

  // Utility Providers
  static const List<Map<String, String>> utilityProviders = [
    {'id': 'electric', 'name': 'City Electric', 'icon': 'lightbulb'},
    {'id': 'water', 'name': 'Water Utilities', 'icon': 'water_drop'},
    {'id': 'internet', 'name': 'FastNet Internet', 'icon': 'wifi'},
    {'id': 'gas', 'name': 'Metro Gas', 'icon': 'local_fire_department'},
    {'id': 'phone', 'name': 'TeleCom Mobile', 'icon': 'phone_android'},
    {'id': 'tv', 'name': 'StreamTV Cable', 'icon': 'tv'},
    {'id': 'insurance', 'name': 'SafeGuard Insurance', 'icon': 'shield'},
    {'id': 'tax', 'name': 'City Tax Office', 'icon': 'account_balance'},
  ];

  // Quick Top-Up Amounts
  static const List<double> quickTopUpAmounts = [
    50.0,
    100.0,
    200.0,
    500.0,
    1000.0,
    2000.0,
  ];

  // Transaction Types
  static const String typeTransfer = 'transfer';
  static const String typeDeposit = 'deposit';
  static const String typeWithdrawal = 'withdrawal';
  static const String typeBillPayment = 'bill_payment';
  static const String typeTopUp = 'topup';
  static const String typeLoan = 'loan';
}
