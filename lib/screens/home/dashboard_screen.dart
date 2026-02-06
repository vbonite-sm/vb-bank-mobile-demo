import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/crypto_widget.dart';
import '../../widgets/transaction_item.dart';
import '../../widgets/loading_spinner.dart';
import '../../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer data loading to avoid notifyListeners() during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context
          .read<BankingProvider>()
          .loadAccountData(authProvider.currentUser!.id);
    }
  }

  Future<void> _onRefresh() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context
          .read<BankingProvider>()
          .refresh(authProvider.currentUser!.id);
      authProvider.refreshUser();
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break; // Already on dashboard
      case 1:
        Navigator.pushNamed(context, '/transfer');
        break;
      case 2:
        Navigator.pushNamed(context, '/history');
        break;
      case 3:
        _showMoreMenu();
        break;
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _menuItem(Icons.add_circle_outline, 'Top Up', '/topup'),
            _menuItem(Icons.receipt_long, 'Pay Bills', '/bills'),
            _menuItem(Icons.credit_card, 'My Cards', '/cards'),
            _menuItem(Icons.account_balance, 'Loans', '/loans'),
            _menuItem(Icons.settings, 'Settings', '/settings'),
            const SizedBox(height: 8),
            _menuItem(Icons.logout, 'Logout', 'logout',
                color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, String route,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.text),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        if (route == 'logout') {
          _handleLogout();
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bankingProvider = context.watch<BankingProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: LoadingSpinner());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authProvider.isReturningUser ? 'Welcome back,' : 'Welcome,',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: bankingProvider.isLoading && bankingProvider.accountDetails == null
          ? const LoadingSpinner(message: 'Loading your account...')
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    BalanceCard(
                      balance: bankingProvider.balance,
                      accountNumber: user.accountNumber,
                      currency: user.currency,
                      userName: user.fullName,
                    ),
                    const SizedBox(height: 16),

                    // Dashboard Stats
                    _buildStatCards(bankingProvider, user.id),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 24),

                    // Crypto Portfolio
                    if (user.crypto.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: CryptoWidget(
                          holdings: user.crypto,
                          prices: bankingProvider.cryptoPrices,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Recent Transactions
                    _buildRecentTransactions(bankingProvider, user.id),
                    const SizedBox(height: 24),

                    // Currency Rates
                    if (bankingProvider.currencyRates.isNotEmpty)
                      _buildCurrencyRates(bankingProvider.currencyRates),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Transfer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildStatCards(BankingProvider provider, String userId) {
    final allTxns = provider.transactions;
    final deposits = allTxns.where((t) => t.type == 'deposit' || t.type == 'topup').toList();
    final transfers = allTxns.where((t) => t.type == 'transfer').toList();
    final totalDeposits = deposits.fold<double>(0, (sum, t) => sum + t.amount);
    final totalTransfers = transfers.fold<double>(0, (sum, t) => sum + t.amount);

    return Row(
      children: [
        _statCard('Deposits', Formatters.currency(totalDeposits), Icons.arrow_downward, AppColors.success),
        const SizedBox(width: 8),
        _statCard('Transfers', Formatters.currency(totalTransfers), Icons.arrow_upward, AppColors.primary),
        const SizedBox(width: 8),
        _statCard('Total Txns', '${allTxns.length}', Icons.receipt_long, AppColors.accent),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionButton(Icons.swap_horiz, 'Transfer', '/transfer',
            AppColors.gradientPurple),
        const SizedBox(width: 12),
        _actionButton(Icons.receipt_long, 'Pay Bills', '/bills',
            AppColors.gradientCyan),
        const SizedBox(width: 12),
        _actionButton(Icons.add_circle_outline, 'Top Up', '/topup',
            AppColors.gradientGreen),
        const SizedBox(width: 12),
        _actionButton(Icons.credit_card, 'Cards', '/cards',
            AppColors.gradientOrange),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, String route, List<Color> gradient) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
      BankingProvider provider, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/history'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (provider.recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, color: AppColors.textMuted, size: 40),
                const SizedBox(height: 8),
                Text(
                  'No transactions yet',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: provider.recentTransactions
                  .map((tx) => TransactionItem(
                        transaction: tx,
                        currentUserId: userId,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrencyRates(Map<String, double> rates) {
    final displayCurrencies = ['EUR', 'GBP', 'JPY', 'CAD'];
    final filteredRates = Map.fromEntries(
      rates.entries.where((e) => displayCurrencies.contains(e.key)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Currency Rates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
              onPressed: _onRefresh,
              tooltip: 'Refresh rates',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: filteredRates.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1 USD',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(2)} ${entry.key}',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
