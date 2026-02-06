import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';

class CryptoWidget extends StatelessWidget {
  final Map<String, double> holdings; // {'BTC': 0.5, 'ETH': 2.0}
  final Map<String, double> prices; // {'BTC': 50000, 'ETH': 3000}

  const CryptoWidget({
    super.key,
    required this.holdings,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Crypto Portfolio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            Icon(Icons.trending_up, color: AppColors.success, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        ...holdings.entries.map((entry) => _buildCryptoRow(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildCryptoRow(String symbol, double amount) {
    final price = prices[symbol] ?? 0.0;
    final value = amount * price;
    final isPositive = true; // Mock - always positive for display

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: symbol == 'BTC'
                  ? const Color(0xFFF7931A).withOpacity(0.15)
                  : const Color(0xFF627EEA).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                symbol == 'BTC' ? '₿' : 'Ξ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      symbol == 'BTC' ? const Color(0xFFF7931A) : const Color(0xFF627EEA),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol == 'BTC' ? 'Bitcoin' : 'Ethereum',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  Formatters.crypto(amount, symbol),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Value & Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(value),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                Formatters.currency(price),
                style: TextStyle(
                  fontSize: 13,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
