import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../utils/formatters.dart';
import '../../utils/constants.dart';

class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key});

  @override
  State<BillPayScreen> createState() => _BillPayScreenState();
}

class _BillPayScreenState extends State<BillPayScreen> {
  Map<String, String>? _selectedProvider;
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  IconData _getProviderIcon(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'local_fire_department':
        return Icons.local_fire_department_outlined;
      case 'phone_android':
        return Icons.phone_android;
      case 'tv':
        return Icons.tv;
      case 'shield':
        return Icons.shield_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      default:
        return Icons.receipt;
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedProvider == null) {
      setState(() => _errorMessage = 'Please select a provider');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }

    if (_accountController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your account number');
      return;
    }

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    if (amount > currentUser.balance) {
      setState(() => _errorMessage = 'Insufficient balance');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await context.read<BankingProvider>().payBill(
          userId: currentUser.id,
          providerId: _selectedProvider!['id']!,
          providerName: _selectedProvider!['name']!,
          amount: amount,
          accountNumber: _accountController.text,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success']) {
      context.read<AuthProvider>().refreshUser();
      _showSuccessDialog(amount, result['reference'] ?? '');
    } else {
      setState(() => _errorMessage = result['error']);
    }
  }

  void _showSuccessDialog(double amount, String reference) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.currency(amount),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedProvider!['name']!,
              style: TextStyle(color: AppColors.textMuted),
            ),
            if (reference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ref: $reference',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: 'Done',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Pay Bills')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance
            if (currentUser != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available Balance',
                        style: TextStyle(color: AppColors.textMuted)),
                    Text(
                      Formatters.currency(currentUser.balance),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),

            // Provider Selection
            Text(
              'Select Provider',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: AppConstants.utilityProviders.length,
              itemBuilder: (context, index) {
                final provider = AppConstants.utilityProviders[index];
                final isSelected =
                    _selectedProvider?['id'] == provider['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedProvider = provider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getProviderIcon(provider['icon']!),
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          provider['name']!.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.text,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Account Number
            CustomInput(
              label: 'Account Number',
              hint: 'Enter your bill account number',
              controller: _accountController,
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Amount
            CustomInput(
              label: 'Amount',
              hint: '0.00',
              controller: _amountController,
              prefixIcon: Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),

            // Pay Button
            CustomButton(
              text: 'Pay Bill',
              onPressed: _handlePayment,
              isLoading: _isLoading,
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }
}
