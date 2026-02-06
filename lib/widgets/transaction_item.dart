import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String currentUserId;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = _isCredit();
    final icon = _getIcon();
    final iconColor = _getIconColor();
    final title = _getTitle();
    final subtitle = _getSubtitle();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${Formatters.currency(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isCredit ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.relativeTime(transaction.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isCredit() {
    if (transaction.type == 'deposit' || transaction.type == 'topup') {
      return true;
    }
    if (transaction.type == 'transfer') {
      return transaction.recipientId == currentUserId ||
          transaction.recipientAccount == currentUserId;
    }
    return false;
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case 'transfer':
        return _isCredit() ? Icons.arrow_downward : Icons.arrow_upward;
      case 'deposit':
        return Icons.account_balance_wallet;
      case 'topup':
        return Icons.add_circle_outline;
      case 'bill_payment':
        return Icons.receipt_long;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'loan':
        return Icons.account_balance;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getIconColor() {
    switch (transaction.type) {
      case 'transfer':
        return _isCredit() ? AppColors.success : AppColors.primary;
      case 'deposit':
      case 'topup':
        return AppColors.success;
      case 'bill_payment':
        return AppColors.warning;
      case 'withdrawal':
        return AppColors.error;
      case 'loan':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  String _getTitle() {
    switch (transaction.type) {
      case 'transfer':
        if (_isCredit()) {
          return 'From ${transaction.senderName ?? 'Unknown'}';
        }
        return 'To ${transaction.recipientName ?? 'Unknown'}';
      case 'deposit':
        return 'Deposit';
      case 'topup':
        return 'Top Up';
      case 'bill_payment':
        return transaction.category != null
            ? 'Bill: ${Formatters.capitalize(transaction.category!)}'
            : 'Bill Payment';
      case 'withdrawal':
        return 'Withdrawal';
      case 'loan':
        return 'Loan Disbursement';
      default:
        return Formatters.transactionType(transaction.type);
    }
  }

  String _getSubtitle() {
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }
    return Formatters.transactionType(transaction.type);
  }
}
