import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/loan.dart';
import '../models/bill_payment.dart';
import '../utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  late Box<User> _usersBox;
  late Box<Transaction> _transactionsBox;
  late Box<VirtualCard> _cardsBox;
  late Box<Loan> _loansBox;
  late Box<BillPayment> _billPaymentsBox;
  late SharedPreferences _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(VirtualCardAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(LoanAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(BillPaymentAdapter());

    // Open boxes
    _usersBox = await Hive.openBox<User>(AppConstants.usersBox);
    _transactionsBox = await Hive.openBox<Transaction>(AppConstants.transactionsBox);
    _cardsBox = await Hive.openBox<VirtualCard>(AppConstants.cardsBox);
    _loansBox = await Hive.openBox<Loan>(AppConstants.loansBox);
    _billPaymentsBox = await Hive.openBox<BillPayment>(AppConstants.billPaymentsBox);

    // Init SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ USER OPERATIONS ============

  List<User> getUsers() => _usersBox.values.toList();

  User? getUserById(String id) {
    try {
      return _usersBox.values.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  User? getUserByUsername(String username) {
    try {
      return _usersBox.values.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  User? getUserByAccountNumber(String accountNumber) {
    try {
      return _usersBox.values.firstWhere((u) => u.accountNumber == accountNumber);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    await _usersBox.put(user.id, user);
  }

  Future<void> deleteUser(String id) async {
    await _usersBox.delete(id);
  }

  // ============ TRANSACTION OPERATIONS ============

  List<Transaction> getTransactions() => _transactionsBox.values.toList();

  List<Transaction> getUserTransactions(String userId, {int? limit}) {
    var transactions = _transactionsBox.values
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && transactions.length > limit) {
      transactions = transactions.sublist(0, limit);
    }
    return transactions;
  }

  Future<void> saveTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // ============ CARD OPERATIONS ============

  List<VirtualCard> getCards() => _cardsBox.values.toList();

  List<VirtualCard> getUserCards(String userId) {
    return _cardsBox.values.where((c) => c.userId == userId).toList();
  }

  VirtualCard? getCardById(String cardId) {
    try {
      return _cardsBox.values.firstWhere((c) => c.id == cardId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCard(VirtualCard card) async {
    await _cardsBox.put(card.id, card);
  }

  Future<void> deleteCard(String cardId) async {
    await _cardsBox.delete(cardId);
  }

  // ============ LOAN OPERATIONS ============

  List<Loan> getLoans() => _loansBox.values.toList();

  List<Loan> getUserLoans(String userId) {
    return _loansBox.values.where((l) => l.userId == userId).toList();
  }

  Future<void> saveLoan(Loan loan) async {
    await _loansBox.put(loan.id, loan);
  }

  // ============ BILL PAYMENT OPERATIONS ============

  List<BillPayment> getBillPayments() => _billPaymentsBox.values.toList();

  List<BillPayment> getUserBillPayments(String userId) {
    return _billPaymentsBox.values.where((b) => b.userId == userId).toList();
  }

  Future<void> saveBillPayment(BillPayment payment) async {
    await _billPaymentsBox.put(payment.id, payment);
  }

  // ============ SESSION OPERATIONS ============

  Future<void> saveSession(Map<String, dynamic> session) async {
    await _prefs.setString(AppConstants.sessionKey, json.encode(session));
  }

  Map<String, dynamic>? getSession() {
    final sessionStr = _prefs.getString(AppConstants.sessionKey);
    if (sessionStr == null) return null;
    return json.decode(sessionStr) as Map<String, dynamic>;
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.sessionKey);
  }

  // ============ PREFERENCES ============

  bool get isDarkTheme => _prefs.getBool(AppConstants.themeKey) ?? true;

  Future<void> setTheme(bool isDark) async {
    await _prefs.setBool(AppConstants.themeKey, isDark);
  }

  bool get isBiometricEnabled =>
      _prefs.getBool(AppConstants.biometricKey) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.biometricKey, enabled);
  }

  String? get savedUsername => _prefs.getString(AppConstants.savedUsernameKey);

  Future<void> setSavedUsername(String? username) async {
    if (username != null) {
      await _prefs.setString(AppConstants.savedUsernameKey, username);
    } else {
      await _prefs.remove(AppConstants.savedUsernameKey);
    }
  }

  /// Check if a specific user has logged in before (for smart greeting)
  bool hasLoggedInBefore(String username) {
    final loggedUsers = _prefs.getStringList('logged_users') ?? [];
    return loggedUsers.contains(username);
  }

  /// Mark user as having logged in
  Future<void> setHasLoggedIn(String username) async {
    final loggedUsers = _prefs.getStringList('logged_users') ?? [];
    if (!loggedUsers.contains(username)) {
      loggedUsers.add(username);
      await _prefs.setStringList('logged_users', loggedUsers);
    }
  }

  // ============ RESET ============

  Future<void> clearAll() async {
    await _usersBox.clear();
    await _transactionsBox.clear();
    await _cardsBox.clear();
    await _loansBox.clear();
    await _billPaymentsBox.clear();
    await _prefs.clear();
  }

  bool get isSeeded => _usersBox.isNotEmpty;
}
