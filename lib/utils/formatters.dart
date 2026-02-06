import 'package:intl/intl.dart';

class Formatters {
  /// Format amount as currency string
  static String currency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount)}';
  }

  /// Alias for currency
  static String formatCurrency(double amount, {String symbol = '\$'}) =>
      currency(amount, symbol: symbol);

  /// Format amount with sign (+/-)
  static String currencyWithSign(double amount, {bool isCredit = false}) {
    final formatted = currency(amount.abs());
    return isCredit ? '+$formatted' : '-$formatted';
  }

  /// Format compact currency (e.g., $1.5K, $2.3M)
  static String compactCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compact();
    return '$symbol${formatter.format(amount)}';
  }

  /// Format date as "MMM dd, yyyy"
  static String date(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date as "MMM dd, yyyy HH:mm"
  static String dateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Format date as "HH:mm"
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "Yesterday")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  /// Format account number with spaces
  static String accountNumber(String number) {
    if (number.length != 10) return number;
    return '${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
  }

  /// Mask account number (show last 4 digits)
  static String maskedAccountNumber(String number) {
    if (number.length < 4) return number;
    final masked = '*' * (number.length - 4);
    return '$masked${number.substring(number.length - 4)}';
  }

  /// Format card number with spaces
  static String cardNumber(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.length != 16) return number;
    return '${clean.substring(0, 4)} ${clean.substring(4, 8)} ${clean.substring(8, 12)} ${clean.substring(12)}';
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format crypto amount
  static String crypto(double amount, String symbol) {
    if (amount < 0.001) {
      return '${amount.toStringAsFixed(8)} $symbol';
    } else if (amount < 1) {
      return '${amount.toStringAsFixed(4)} $symbol';
    } else {
      return '${amount.toStringAsFixed(2)} $symbol';
    }
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Format transaction type for display
  static String transactionType(String type) {
    switch (type) {
      case 'transfer':
        return 'Transfer';
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'bill_payment':
        return 'Bill Payment';
      case 'topup':
        return 'Top Up';
      case 'loan':
        return 'Loan';
      default:
        return capitalize(type);
    }
  }
}
