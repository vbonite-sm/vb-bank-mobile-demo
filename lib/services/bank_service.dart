import 'package:uuid/uuid.dart';
import 'dart:math';
import 'storage_service.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/loan.dart';
import '../models/bill_payment.dart';

class BankService {
  final StorageService _storage = StorageService.instance;
  static const _uuid = Uuid();

  // ============ CARD DELETE ============

  Future<Map<String, dynamic>> deleteCard(String userId, String cardId) async {
    final card = _storage.getCardById(cardId);
    if (card == null) {
      return {'success': false, 'error': 'Card not found'};
    }
    if (card.userId != userId) {
      return {'success': false, 'error': 'Unauthorized'};
    }
    await _storage.deleteCard(cardId);
    return {'success': true, 'message': 'Card deleted successfully'};
  }

  // ============ BALANCE & ACCOUNT ============

  double getBalance(String userId) {
    final user = _storage.getUserById(userId);
    return user?.balance ?? 0.0;
  }

  User? getAccountDetails(String userId) {
    return _storage.getUserById(userId);
  }

  // ============ TRANSACTIONS ============

  List<Transaction> getUserTransactions(String userId, {int? limit}) {
    return _storage.getUserTransactions(userId, limit: limit);
  }

  List<Transaction> searchTransactions(
    String userId, {
    String? query,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var transactions = _storage.getUserTransactions(userId);

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      transactions = transactions.where((t) {
        return t.description.toLowerCase().contains(q) ||
            (t.recipientName?.toLowerCase().contains(q) ?? false) ||
            (t.senderName?.toLowerCase().contains(q) ?? false) ||
            (t.category?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (type != null && type.isNotEmpty && type != 'all') {
      transactions = transactions.where((t) => t.type == type).toList();
    }

    if (startDate != null) {
      transactions = transactions.where((t) => t.date.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      transactions =
          transactions.where((t) => t.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return transactions;
  }

  // ============ TRANSFERS ============

  Future<Map<String, dynamic>> transferMoney({
    required String fromUserId,
    required String recipientAccount,
    required double amount,
    required String description,
  }) async {
    try {
      final sender = _storage.getUserById(fromUserId);
      if (sender == null) {
        return {'success': false, 'error': 'Sender not found'};
      }

      if (sender.balance < amount) {
        return {'success': false, 'error': 'Insufficient balance'};
      }

      if (amount <= 0) {
        return {'success': false, 'error': 'Invalid amount'};
      }

      final recipient = _storage.getUserByAccountNumber(recipientAccount);
      if (recipient == null) {
        return {'success': false, 'error': 'Recipient account not found'};
      }

      if (sender.accountNumber == recipientAccount) {
        return {'success': false, 'error': 'Cannot transfer to your own account'};
      }

      // Debit sender
      sender.balance -= amount;
      await _storage.saveUser(sender);

      // Credit recipient
      recipient.balance += amount;
      await _storage.saveUser(recipient);

      final txId = _uuid.v4();
      final now = DateTime.now();

      // Sender's transaction record
      final senderTx = Transaction(
        id: 'tx_${txId}_s',
        userId: fromUserId,
        type: 'transfer',
        amount: amount,
        description: description,
        date: now,
        status: 'completed',
        recipientId: recipient.id,
        recipientName: recipient.fullName,
        recipientAccount: recipient.accountNumber,
        senderId: sender.id,
        senderName: sender.fullName,
        senderAccount: sender.accountNumber,
        reference: txId,
      );

      // Recipient's transaction record
      final recipientTx = Transaction(
        id: 'tx_${txId}_r',
        userId: recipient.id,
        type: 'transfer',
        amount: amount,
        description: description,
        date: now,
        status: 'completed',
        recipientId: recipient.id,
        recipientName: recipient.fullName,
        recipientAccount: recipient.accountNumber,
        senderId: sender.id,
        senderName: sender.fullName,
        senderAccount: sender.accountNumber,
        reference: txId,
      );

      await _storage.saveTransaction(senderTx);
      await _storage.saveTransaction(recipientTx);

      return {
        'success': true,
        'message': 'Transfer successful',
        'transaction': senderTx,
        'newBalance': sender.balance,
      };
    } catch (e) {
      return {'success': false, 'error': 'Transfer failed: ${e.toString()}'};
    }
  }

  // ============ DEPOSIT / TOP UP ============

  Future<Map<String, dynamic>> depositMoney({
    required String userId,
    required double amount,
    required String description,
  }) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      if (amount <= 0) {
        return {'success': false, 'error': 'Invalid amount'};
      }

      user.balance += amount;
      await _storage.saveUser(user);

      final tx = Transaction(
        id: 'tx_${_uuid.v4()}',
        userId: userId,
        type: 'topup',
        amount: amount,
        description: description.isNotEmpty ? description : 'Top Up',
        date: DateTime.now(),
        status: 'completed',
      );

      await _storage.saveTransaction(tx);

      return {
        'success': true,
        'message': 'Top up successful',
        'newBalance': user.balance,
      };
    } catch (e) {
      return {'success': false, 'error': 'Top up failed: ${e.toString()}'};
    }
  }

  // ============ BILL PAYMENTS ============

  Future<Map<String, dynamic>> payBill({
    required String userId,
    required String providerId,
    required String providerName,
    required double amount,
    required String accountNumber,
  }) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      if (user.balance < amount) {
        return {'success': false, 'error': 'Insufficient balance'};
      }

      if (amount <= 0) {
        return {'success': false, 'error': 'Invalid amount'};
      }

      user.balance -= amount;
      await _storage.saveUser(user);

      // Save bill payment record
      final payment = BillPayment(
        id: 'bill_${_uuid.v4()}',
        userId: userId,
        providerId: providerId,
        providerName: providerName,
        amount: amount,
        accountNumber: accountNumber,
        status: 'completed',
        reference: _uuid.v4().substring(0, 8).toUpperCase(),
      );

      await _storage.saveBillPayment(payment);

      // Save transaction record
      final tx = Transaction(
        id: 'tx_${_uuid.v4()}',
        userId: userId,
        type: 'bill_payment',
        amount: amount,
        description: '$providerName payment',
        date: DateTime.now(),
        status: 'completed',
        category: providerId,
        reference: payment.reference,
      );

      await _storage.saveTransaction(tx);

      return {
        'success': true,
        'message': 'Bill payment successful',
        'reference': payment.reference,
        'newBalance': user.balance,
      };
    } catch (e) {
      return {'success': false, 'error': 'Payment failed: ${e.toString()}'};
    }
  }

  // ============ VIRTUAL CARDS ============

  List<VirtualCard> getUserCards(String userId) {
    return _storage.getUserCards(userId);
  }

  Future<Map<String, dynamic>> createCard({
    required String userId,
    required String type,
    double spendingLimit = 5000.0,
  }) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      final random = Random();
      final cardNumber = List.generate(16, (_) => random.nextInt(10)).join();
      final cvv = List.generate(3, (_) => random.nextInt(10)).join();
      final pin = List.generate(4, (_) => random.nextInt(10)).join();
      final expMonth = (DateTime.now().month).toString().padLeft(2, '0');
      final expYear = (DateTime.now().year + 3).toString().substring(2);

      final colors = ['#6366f1', '#22d3ee', '#10b981', '#f59e0b', '#ec4899', '#3b82f6'];
      final cardColor = colors[random.nextInt(colors.length)];

      final card = VirtualCard(
        id: 'card_${_uuid.v4()}',
        userId: userId,
        cardNumber: cardNumber,
        cardHolder: user.fullName.toUpperCase(),
        expiryDate: '$expMonth/$expYear',
        cvv: cvv,
        pin: pin,
        type: type,
        status: 'active',
        spendingLimit: spendingLimit,
        currentSpending: 0.0,
        cardColor: cardColor,
      );

      await _storage.saveCard(card);

      return {
        'success': true,
        'message': 'Card created successfully',
        'card': card,
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to create card'};
    }
  }

  Future<Map<String, dynamic>> freezeCard(String userId, String cardId) async {
    try {
      final card = _storage.getCardById(cardId);
      if (card == null || card.userId != userId) {
        return {'success': false, 'error': 'Card not found'};
      }

      card.status = 'frozen';
      await _storage.saveCard(card);

      return {'success': true, 'message': 'Card frozen successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to freeze card'};
    }
  }

  Future<Map<String, dynamic>> unfreezeCard(String userId, String cardId) async {
    try {
      final card = _storage.getCardById(cardId);
      if (card == null || card.userId != userId) {
        return {'success': false, 'error': 'Card not found'};
      }

      card.status = 'active';
      await _storage.saveCard(card);

      return {'success': true, 'message': 'Card unfrozen successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to unfreeze card'};
    }
  }

  Future<Map<String, dynamic>> blockCard(String userId, String cardId) async {
    try {
      final card = _storage.getCardById(cardId);
      if (card == null || card.userId != userId) {
        return {'success': false, 'error': 'Card not found'};
      }

      card.status = 'blocked';
      await _storage.saveCard(card);

      return {'success': true, 'message': 'Card blocked successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to block card'};
    }
  }

  String? getCardPIN(String userId, String cardId) {
    final card = _storage.getCardById(cardId);
    if (card == null || card.userId != userId) return null;
    return card.pin;
  }

  // ============ LOANS ============

  List<Loan> getUserLoans(String userId) {
    return _storage.getUserLoans(userId);
  }

  Future<Map<String, dynamic>> applyForLoan({
    required String userId,
    required String loanType,
    required double amount,
    required int termMonths,
    required double interestRate,
    String? purpose,
  }) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      final monthlyPayment =
          Loan.calculateMonthlyPayment(amount, interestRate, termMonths);
      final totalRepayment = monthlyPayment * termMonths;

      final loan = Loan(
        id: 'loan_${_uuid.v4()}',
        userId: userId,
        loanType: loanType,
        amount: amount,
        termMonths: termMonths,
        interestRate: interestRate,
        monthlyPayment: monthlyPayment,
        status: 'approved', // Auto-approve for mock
        applicationDate: DateTime.now(),
        approvalDate: DateTime.now(),
        purpose: purpose,
        totalRepayment: totalRepayment,
      );

      await _storage.saveLoan(loan);

      // Disburse loan amount to user
      user.balance += amount;
      await _storage.saveUser(user);

      // Record transaction
      final tx = Transaction(
        id: 'tx_${_uuid.v4()}',
        userId: userId,
        type: 'loan',
        amount: amount,
        description: '${loan.loanTypeName} disbursement',
        date: DateTime.now(),
        status: 'completed',
        reference: loan.id,
      );

      await _storage.saveTransaction(tx);

      return {
        'success': true,
        'message': 'Loan approved and disbursed',
        'loan': loan,
        'newBalance': user.balance,
      };
    } catch (e) {
      return {'success': false, 'error': 'Loan application failed: ${e.toString()}'};
    }
  }

  // ============ USER SEARCH ============

  List<User> searchUsers(String query) {
    if (query.length < 3) return [];

    final q = query.toLowerCase();
    return _storage.getUsers().where((user) {
      return user.fullName.toLowerCase().contains(q) ||
          user.accountNumber.contains(q) ||
          user.username.toLowerCase().contains(q);
    }).toList();
  }

  // ============ EXPORT ============

  List<List<String>> exportTransactionsCSV(String userId) {
    final transactions = getUserTransactions(userId);
    final rows = <List<String>>[
      ['Date', 'Type', 'Description', 'Amount', 'Status', 'Reference'],
    ];

    for (final tx in transactions) {
      rows.add([
        tx.date.toIso8601String(),
        tx.type,
        tx.description,
        tx.amount.toStringAsFixed(2),
        tx.status,
        tx.reference ?? '',
      ]);
    }

    return rows;
  }
}
