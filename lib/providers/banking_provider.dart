import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/loan.dart';
import '../services/bank_service.dart';
import '../services/crypto_service.dart';
import '../services/api_service.dart';

class BankingProvider extends ChangeNotifier {
  final BankService _bankService = BankService();

  User? _accountDetails;
  List<Transaction> _transactions = [];
  List<Transaction> _recentTransactions = [];
  List<VirtualCard> _cards = [];
  List<Loan> _loans = [];
  Map<String, double> _cryptoPrices = {'BTC': 50000.0, 'ETH': 3000.0};
  Map<String, double> _currencyRates = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get accountDetails => _accountDetails;
  List<Transaction> get transactions => _transactions;
  List<Transaction> get recentTransactions => _recentTransactions;
  List<VirtualCard> get cards => _cards;
  List<Loan> get loans => _loans;
  Map<String, double> get cryptoPrices => _cryptoPrices;
  Map<String, double> get currencyRates => _currencyRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get balance => _accountDetails?.balance ?? 0.0;
  Map<String, double> get cryptoHoldings => _accountDetails?.crypto ?? {};

  /// Load all account data
  Future<void> loadAccountData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _accountDetails = _bankService.getAccountDetails(userId);
      _recentTransactions = _bankService.getUserTransactions(userId, limit: 5);
      _transactions = _bankService.getUserTransactions(userId);
      _cards = _bankService.getUserCards(userId);
      _loans = _bankService.getUserLoans(userId);

      // Fetch external data (non-blocking)
      _loadExternalData();

      _error = null;
    } catch (e) {
      _error = 'Failed to load account data';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh(String userId) async {
    await loadAccountData(userId);
  }

  /// Load crypto prices and currency rates
  Future<void> _loadExternalData() async {
    try {
      final prices = await CryptoService.getCryptoPrices();
      _cryptoPrices = prices;

      final rates = await ApiService.getCurrencyRates();
      _currencyRates = rates;

      // Schedule notification after the current frame to avoid
      // calling notifyListeners during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      // Use fallback values
    }
  }

  /// Transfer money
  Future<Map<String, dynamic>> transfer({
    required String fromUserId,
    required String recipientAccount,
    required double amount,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bankService.transferMoney(
      fromUserId: fromUserId,
      recipientAccount: recipientAccount,
      amount: amount,
      description: description,
    );

    if (result['success']) {
      await loadAccountData(fromUserId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Top up / Deposit
  Future<Map<String, dynamic>> topUp({
    required String userId,
    required double amount,
    String description = 'Top Up',
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bankService.depositMoney(
      userId: userId,
      amount: amount,
      description: description,
    );

    if (result['success']) {
      await loadAccountData(userId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Pay bill
  Future<Map<String, dynamic>> payBill({
    required String userId,
    required String providerId,
    required String providerName,
    required double amount,
    required String accountNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bankService.payBill(
      userId: userId,
      providerId: providerId,
      providerName: providerName,
      amount: amount,
      accountNumber: accountNumber,
    );

    if (result['success']) {
      await loadAccountData(userId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Create virtual card
  Future<Map<String, dynamic>> createCard({
    required String userId,
    required String type,
    double spendingLimit = 5000.0,
  }) async {
    final result = await _bankService.createCard(
      userId: userId,
      type: type,
      spendingLimit: spendingLimit,
    );

    if (result['success']) {
      _cards = _bankService.getUserCards(userId);
      notifyListeners();
    }

    return result;
  }

  /// Freeze card
  Future<Map<String, dynamic>> freezeCard(
      String userId, String cardId) async {
    final result = await _bankService.freezeCard(userId, cardId);
    if (result['success']) {
      _cards = _bankService.getUserCards(userId);
      notifyListeners();
    }
    return result;
  }

  /// Unfreeze card
  Future<Map<String, dynamic>> unfreezeCard(
      String userId, String cardId) async {
    final result = await _bankService.unfreezeCard(userId, cardId);
    if (result['success']) {
      _cards = _bankService.getUserCards(userId);
      notifyListeners();
    }
    return result;
  }

  /// Block card
  Future<Map<String, dynamic>> blockCard(
      String userId, String cardId) async {
    final result = await _bankService.blockCard(userId, cardId);
    if (result['success']) {
      _cards = _bankService.getUserCards(userId);
      notifyListeners();
    }
    return result;
  }

  /// Delete card
  Future<Map<String, dynamic>> deleteCard(
      String userId, String cardId) async {
    final result = await _bankService.deleteCard(userId, cardId);
    if (result['success']) {
      _cards = _bankService.getUserCards(userId);
      notifyListeners();
    }
    return result;
  }

  /// Get card PIN
  String? getCardPIN(String userId, String cardId) {
    return _bankService.getCardPIN(userId, cardId);
  }

  /// Apply for loan
  Future<Map<String, dynamic>> applyForLoan({
    required String userId,
    required String loanType,
    required double amount,
    required int termMonths,
    required double interestRate,
    String? purpose,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bankService.applyForLoan(
      userId: userId,
      loanType: loanType,
      amount: amount,
      termMonths: termMonths,
      interestRate: interestRate,
      purpose: purpose,
    );

    if (result['success']) {
      await loadAccountData(userId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Search users for transfer
  List<User> searchUsers(String query) {
    return _bankService.searchUsers(query);
  }

  /// Search transactions
  List<Transaction> searchTransactions(
    String userId, {
    String? query,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _bankService.searchTransactions(
      userId,
      query: query,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Export transactions as CSV data
  List<List<String>> exportCSV(String userId) {
    return _bankService.exportTransactionsCSV(userId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
