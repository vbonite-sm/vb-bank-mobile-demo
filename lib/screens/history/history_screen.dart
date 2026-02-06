import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../models/transaction.dart';
import '../../theme/colors.dart';
import '../../widgets/transaction_item.dart';
import '../../widgets/loading_spinner.dart';
import '../../utils/formatters.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'transfer', 'label': 'Transfers'},
    {'key': 'deposit', 'label': 'Deposits'},
    {'key': 'topup', 'label': 'Top Up'},
    {'key': 'bill_payment', 'label': 'Bills'},
    {'key': 'loan', 'label': 'Loans'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _getFilteredTransactions() {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return [];

    return context.read<BankingProvider>().searchTransactions(
          userId,
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          type: _selectedFilter != 'all' ? _selectedFilter : null,
        );
  }

  Future<void> _exportCSV() async {
    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) return;

      final csvData = context.read<BankingProvider>().exportCSV(userId);
      final csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/vb_bank_transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to: ${file.path}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: LoadingSpinner());
    }

    final transactions = _getFilteredTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportCSV,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter['key']!);
                    },
                    backgroundColor: AppColors.cardBg,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} transaction${transactions.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 60, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Column(
                        children: [
                          // Date header
                          if (index == 0 ||
                              !_isSameDay(
                                  tx.date, transactions[index - 1].date))
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Formatters.date(tx.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          TransactionItem(
                            transaction: tx,
                            currentUserId: currentUser.id,
                            onTap: () => _showTransactionDetails(tx),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showTransactionDetails(Transaction tx) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    final isCredit = tx.type == 'deposit' ||
        tx.type == 'topup' ||
        (tx.type == 'transfer' && tx.recipientId == currentUserId);

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
            Text(
              '${isCredit ? '+' : '-'}${Formatters.currency(tx.amount)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isCredit ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.transactionType(tx.type),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            _detailRow('Description', tx.description),
            _detailRow('Date', Formatters.dateTime(tx.date)),
            _detailRow('Status', tx.status.toUpperCase()),
            if (tx.recipientName != null)
              _detailRow('Recipient', tx.recipientName!),
            if (tx.senderName != null)
              _detailRow('Sender', tx.senderName!),
            if (tx.reference != null)
              _detailRow('Reference', tx.reference!),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
