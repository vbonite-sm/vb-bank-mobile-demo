import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/card.dart';
import '../models/loan.dart';
import 'storage_service.dart';

class Seeder {
  static const _uuid = Uuid();

  static Future<void> seed() async {
    final storage = StorageService.instance;

    // Don't seed if already seeded
    if (storage.isSeeded) return;

    // Seed Users
    final users = _createTestUsers();
    for (final user in users) {
      await storage.saveUser(user);
    }

    // Seed Transactions
    final transactions = _createTestTransactions();
    for (final tx in transactions) {
      await storage.saveTransaction(tx);
    }

    // Seed Cards
    final cards = _createTestCards();
    for (final card in cards) {
      await storage.saveCard(card);
    }

    // Seed Loans
    final loans = _createTestLoans();
    for (final loan in loans) {
      await storage.saveLoan(loan);
    }

    print('✅ Database seeded successfully');
  }

  static List<User> _createTestUsers() {
    return [
      User(
        id: 'user_001',
        username: 'john.doe',
        password: 'user123',
        email: 'john@example.com',
        fullName: 'John Doe',
        role: 'user',
        accountNumber: '1234567890',
        balance: 15000.00,
        currency: 'USD',
        crypto: {'BTC': 0.5, 'ETH': 2.0},
        phone: '+1234567890',
        address: '123 Main St, New York, NY 10001',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      User(
        id: 'user_002',
        username: 'jane.smith',
        password: 'user123',
        email: 'jane@example.com',
        fullName: 'Jane Smith',
        role: 'user',
        accountNumber: '2345678901',
        balance: 25000.50,
        currency: 'USD',
        crypto: {'BTC': 1.2, 'ETH': 5.0},
        phone: '+1234567891',
        address: '456 Oak Ave, Los Angeles, CA 90001',
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      User(
        id: 'user_003',
        username: 'mike.wilson',
        password: 'user123',
        email: 'mike@example.com',
        fullName: 'Mike Wilson',
        role: 'user',
        accountNumber: '3456789012',
        balance: 8500.75,
        currency: 'USD',
        crypto: {'BTC': 0.1, 'ETH': 0.5},
        phone: '+1234567892',
        address: '789 Pine Rd, Chicago, IL 60601',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      User(
        id: 'user_004',
        username: 'sarah.jones',
        password: 'user123',
        email: 'sarah@example.com',
        fullName: 'Sarah Jones',
        role: 'user',
        accountNumber: '4567890123',
        balance: 42000.00,
        currency: 'USD',
        crypto: {'BTC': 2.0, 'ETH': 10.0},
        phone: '+1234567893',
        address: '321 Elm St, San Francisco, CA 94102',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      User(
        id: 'admin_001',
        username: 'admin',
        password: 'admin123',
        email: 'admin@vbbank.com',
        fullName: 'Admin User',
        role: 'admin',
        accountNumber: '9999999999',
        balance: 999999.99,
        currency: 'USD',
        crypto: {'BTC': 10.0, 'ETH': 50.0},
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
    ];
  }

  static List<Transaction> _createTestTransactions() {
    final now = DateTime.now();
    return [
      // John's transactions
      Transaction(
        id: 'tx_001',
        userId: 'user_001',
        type: 'transfer',
        amount: 500.00,
        description: 'Payment for dinner',
        date: now.subtract(const Duration(hours: 2)),
        recipientId: 'user_002',
        recipientName: 'Jane Smith',
        recipientAccount: '2345678901',
        senderId: 'user_001',
        senderName: 'John Doe',
        senderAccount: '1234567890',
      ),
      Transaction(
        id: 'tx_002',
        userId: 'user_001',
        type: 'deposit',
        amount: 3000.00,
        description: 'Salary deposit',
        date: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'tx_003',
        userId: 'user_001',
        type: 'bill_payment',
        amount: 120.00,
        description: 'Monthly electricity bill',
        date: now.subtract(const Duration(days: 3)),
        category: 'electric',
      ),
      Transaction(
        id: 'tx_004',
        userId: 'user_001',
        type: 'transfer',
        amount: 200.00,
        description: 'Freelance work payment',
        date: now.subtract(const Duration(days: 5)),
        recipientId: 'user_001',
        recipientName: 'John Doe',
        recipientAccount: '1234567890',
        senderId: 'user_003',
        senderName: 'Mike Wilson',
        senderAccount: '3456789012',
      ),
      Transaction(
        id: 'tx_005',
        userId: 'user_001',
        type: 'topup',
        amount: 1000.00,
        description: 'Top up from card',
        date: now.subtract(const Duration(days: 7)),
      ),
      Transaction(
        id: 'tx_006',
        userId: 'user_001',
        type: 'bill_payment',
        amount: 75.00,
        description: 'Internet bill',
        date: now.subtract(const Duration(days: 10)),
        category: 'internet',
      ),
      Transaction(
        id: 'tx_007',
        userId: 'user_001',
        type: 'transfer',
        amount: 1500.00,
        description: 'Rent payment',
        date: now.subtract(const Duration(days: 15)),
        recipientId: 'user_004',
        recipientName: 'Sarah Jones',
        recipientAccount: '4567890123',
        senderId: 'user_001',
        senderName: 'John Doe',
        senderAccount: '1234567890',
      ),
      Transaction(
        id: 'tx_008',
        userId: 'user_001',
        type: 'deposit',
        amount: 5000.00,
        description: 'Bonus payment',
        date: now.subtract(const Duration(days: 20)),
      ),

      // Jane's received transaction (mirror of tx_001)
      Transaction(
        id: 'tx_009',
        userId: 'user_002',
        type: 'transfer',
        amount: 500.00,
        description: 'Payment for dinner',
        date: now.subtract(const Duration(hours: 2)),
        recipientId: 'user_002',
        recipientName: 'Jane Smith',
        recipientAccount: '2345678901',
        senderId: 'user_001',
        senderName: 'John Doe',
        senderAccount: '1234567890',
      ),
      Transaction(
        id: 'tx_010',
        userId: 'user_002',
        type: 'deposit',
        amount: 4500.00,
        description: 'Salary deposit',
        date: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 'tx_011',
        userId: 'user_002',
        type: 'bill_payment',
        amount: 90.00,
        description: 'Water bill',
        date: now.subtract(const Duration(days: 8)),
        category: 'water',
      ),

      // Mike's sent transaction (mirror of tx_004)
      Transaction(
        id: 'tx_012',
        userId: 'user_003',
        type: 'transfer',
        amount: 200.00,
        description: 'Freelance work payment',
        date: now.subtract(const Duration(days: 5)),
        recipientId: 'user_001',
        recipientName: 'John Doe',
        recipientAccount: '1234567890',
        senderId: 'user_003',
        senderName: 'Mike Wilson',
        senderAccount: '3456789012',
      ),
      Transaction(
        id: 'tx_013',
        userId: 'user_003',
        type: 'deposit',
        amount: 2000.00,
        description: 'Freelance income',
        date: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  static List<VirtualCard> _createTestCards() {
    return [
      VirtualCard(
        id: 'card_001',
        userId: 'user_001',
        cardNumber: '4532015112830366',
        cardHolder: 'JOHN DOE',
        expiryDate: '12/27',
        cvv: '123',
        pin: '1234',
        type: 'visa',
        status: 'active',
        spendingLimit: 5000.0,
        currentSpending: 1250.00,
        cardColor: '#6366f1',
      ),
      VirtualCard(
        id: 'card_002',
        userId: 'user_001',
        cardNumber: '5425233430109903',
        cardHolder: 'JOHN DOE',
        expiryDate: '06/28',
        cvv: '456',
        pin: '5678',
        type: 'mastercard',
        status: 'active',
        spendingLimit: 10000.0,
        currentSpending: 3200.00,
        cardColor: '#22d3ee',
      ),
      VirtualCard(
        id: 'card_003',
        userId: 'user_002',
        cardNumber: '4916338506082832',
        cardHolder: 'JANE SMITH',
        expiryDate: '03/28',
        cvv: '789',
        pin: '9012',
        type: 'visa',
        status: 'active',
        spendingLimit: 8000.0,
        currentSpending: 500.00,
        cardColor: '#10b981',
      ),
    ];
  }

  static List<Loan> _createTestLoans() {
    final monthly = Loan.calculateMonthlyPayment(10000, 8.5, 24);
    return [
      Loan(
        id: 'loan_001',
        userId: 'user_001',
        loanType: 'personal',
        amount: 10000.00,
        termMonths: 24,
        interestRate: 8.5,
        monthlyPayment: monthly,
        status: 'active',
        applicationDate: DateTime.now().subtract(const Duration(days: 180)),
        approvalDate: DateTime.now().subtract(const Duration(days: 177)),
        purpose: 'Home renovation',
        totalRepayment: monthly * 24,
      ),
    ];
  }

  /// Force re-seed (clear and seed again)
  static Future<void> reseed() async {
    await StorageService.instance.clearAll();
    await seed();
  }
}
