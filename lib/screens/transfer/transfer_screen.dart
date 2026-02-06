import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../../models/user.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _searchResults = [];
  User? _selectedRecipient;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _searchRecipient(String query) {
    if (query.length >= 3) {
      final results = context.read<BankingProvider>().searchUsers(query);
      final currentUser = context.read<AuthProvider>().currentUser;
      setState(() {
        _searchResults =
            results.where((u) => u.id != currentUser?.id).toList();
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _selectRecipient(User user) {
    setState(() {
      _selectedRecipient = user;
      _recipientController.text = user.accountNumber;
      _searchResults = [];
    });
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Invalid amount');
      return;
    }

    if (amount > currentUser.balance) {
      setState(() => _errorMessage = 'Insufficient balance');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await context.read<BankingProvider>().transfer(
          fromUserId: currentUser.id,
          recipientAccount: _recipientController.text.trim(),
          amount: amount,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : 'Transfer',
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success']) {
      context.read<AuthProvider>().refreshUser();
      _showSuccessDialog(amount);
    } else {
      setState(() => _errorMessage = result['error']);
    }
  }

  void _showSuccessDialog(double amount) {
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
              'Transfer Successful!',
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
            if (_selectedRecipient != null) ...[
              const SizedBox(height: 8),
              Text(
                'To: ${_selectedRecipient!.fullName}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
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
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance
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
                      Text(
                        'Available Balance',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
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

              // Error
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

              // Recipient
              CustomInput(
                label: 'Recipient Account',
                hint: 'Enter account number or search by name',
                controller: _recipientController,
                prefixIcon: Icons.person_search,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Recipient account is required';
                  }
                  return null;
                },
                onChanged: _searchRecipient,
              ),

              // Search Results
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: _searchResults.map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            user.fullName[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(color: AppColors.text),
                        ),
                        subtitle: Text(
                          Formatters.accountNumber(user.accountNumber),
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        onTap: () => _selectRecipient(user),
                      );
                    }).toList(),
                  ),
                ),

              // Selected recipient
              if (_selectedRecipient != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sending to: ${_selectedRecipient!.fullName}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Amount
              CustomInput(
                label: 'Amount',
                hint: '0.00',
                controller: _amountController,
                prefixIcon: Icons.attach_money,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    Validators.validateAmount(value, maxAmount: currentUser?.balance),
              ),
              const SizedBox(height: 20),

              // Description
              CustomInput(
                label: 'Description (Optional)',
                hint: 'What is this transfer for?',
                controller: _descriptionController,
                prefixIcon: Icons.notes,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Transfer Button
              CustomButton(
                text: 'Transfer',
                onPressed: _handleTransfer,
                isLoading: _isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
