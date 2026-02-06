import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../models/loan.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openApplySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _LoanApplicationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loans = context.watch<BankingProvider>().loans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'My Loans'),
            Tab(text: 'Apply'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Loans Tab
          loans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance,
                          size: 60, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No active loans',
                        style:
                            TextStyle(fontSize: 18, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _tabController.animateTo(1),
                        icon: const Icon(Icons.add),
                        label: const Text('Apply for a Loan'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: loans.length,
                  itemBuilder: (context, index) =>
                      _buildLoanCard(loans[index]),
                ),

          // Apply Tab
          const _LoanApplicationSheet(isInline: true),
        ],
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final remaining = loan.remainingBalance;
    final progress = loan.totalAmount > 0
        ? (loan.totalAmount - remaining) / loan.totalAmount
        : 0.0;

    Color statusColor;
    switch (loan.status) {
      case 'active':
        statusColor = AppColors.success;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        break;
      case 'paid':
        statusColor = AppColors.primary;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _loanIcon(loan.type),
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.loanTypeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '${loan.interestRate}% APR · ${loan.termMonths} months',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loan.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loanStat('Principal', Formatters.formatCurrency(loan.amount)),
              _loanStat(
                  'Monthly', Formatters.formatCurrency(loan.monthlyPayment)),
              _loanStat(
                  'Remaining', Formatters.formatCurrency(remaining)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repayment Progress',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  IconData _loanIcon(String type) {
    switch (type) {
      case 'personal':
        return Icons.person;
      case 'auto':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      default:
        return Icons.account_balance;
    }
  }
}

class _LoanApplicationSheet extends StatefulWidget {
  final bool isInline;
  const _LoanApplicationSheet({this.isInline = false});

  @override
  State<_LoanApplicationSheet> createState() => _LoanApplicationSheetState();
}

class _LoanApplicationSheetState extends State<_LoanApplicationSheet> {
  String _selectedType = 'personal';
  double _amount = 5000;
  int _termMonths = 12;
  bool _isLoading = false;

  Map<String, dynamic> get _selectedLoanOption {
    return AppConstants.loanOptions[_selectedType]!;
  }

  double get _interestRate =>
      (_selectedLoanOption['interestRate'] as num).toDouble();

  double get _maxAmount =>
      (_selectedLoanOption['maxAmount'] as num).toDouble();

  double get _monthlyPayment =>
      Loan.calculateMonthlyPayment(_amount, _interestRate, _termMonths);

  double get _totalPayment => _monthlyPayment * _termMonths;

  double get _totalInterest => _totalPayment - _amount;

  Future<void> _apply() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final result = await context.read<BankingProvider>().applyForLoan(
          userId: userId,
          loanType: _selectedType,
          amount: _amount,
          termMonths: _termMonths,
          interestRate: _interestRate,
        );

    setState(() => _isLoading = false);

    if (mounted && result['success']) {
      if (!widget.isInline) Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Loan Approved!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${Formatters.formatCurrency(_amount)} has been deposited to your account',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isInline) ...[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Apply for a Loan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Loan Type Selection
          Text(
            'Loan Type',
            style: TextStyle(
                color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            children: AppConstants.loanOptions.entries.map((entry) {
              final key = entry.key;
              final opt = entry.value;
              final isSelected = key == _selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = key;
                    if (_amount > _maxAmount) _amount = _maxAmount;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    height: 72,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _loanTypeIcon(key),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate: ${_interestRate}% APR · Max: ${Formatters.formatCurrency(_maxAmount)}',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),

          const SizedBox(height: 24),

          // Amount Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loan Amount',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500)),
              Text(
                Formatters.formatCurrency(_amount),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Slider(
            value: _amount,
            min: 500,
            max: _maxAmount,
            divisions: ((_maxAmount - 500) / 500).round(),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) => setState(() => _amount = val),
          ),

          const SizedBox(height: 16),

          // Term Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loan Term',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500)),
              Text(
                '$_termMonths months',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Slider(
            value: _termMonths.toDouble(),
            min: 6,
            max: 60,
            divisions: 9,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) =>
                setState(() => _termMonths = val.round()),
          ),

          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _summaryRow('Monthly Payment',
                    Formatters.formatCurrency(_monthlyPayment)),
                Divider(color: AppColors.border, height: 20),
                _summaryRow(
                    'Total Payment', Formatters.formatCurrency(_totalPayment)),
                Divider(color: AppColors.border, height: 20),
                _summaryRow(
                  'Total Interest',
                  Formatters.formatCurrency(_totalInterest),
                  valueColor: AppColors.warning,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Apply Button
          CustomButton(
            text: 'Apply for Loan',
            onPressed: _apply,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (widget.isInline) return content;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) => content,
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMuted)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  IconData _loanTypeIcon(String type) {
    switch (type) {
      case 'personal':
        return Icons.person;
      case 'auto':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      default:
        return Icons.account_balance;
    }
  }
}
