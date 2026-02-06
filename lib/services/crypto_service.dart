import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CryptoService {
  static final Map<String, double> _fallbackPrices = {
    'BTC': 50000.0,
    'ETH': 3000.0,
  };

  static Map<String, double>? _cachedPrices;
  static DateTime? _lastFetch;

  /// Fetch current crypto prices from CoinGecko
  static Future<Map<String, double>> getCryptoPrices() async {
    // Cache for 60 seconds
    if (_cachedPrices != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inSeconds < 60) {
      return _cachedPrices!;
    }

    try {
      final response = await http
          .get(Uri.parse(AppConstants.cryptoApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedPrices = {
          'BTC': (data['bitcoin']?['usd'] ?? 50000).toDouble(),
          'ETH': (data['ethereum']?['usd'] ?? 3000).toDouble(),
        };
        _lastFetch = DateTime.now();
        return _cachedPrices!;
      }
    } catch (e) {
      print('Failed to fetch crypto prices: $e');
    }

    return _fallbackPrices;
  }

  /// Calculate portfolio value
  static Future<double> getPortfolioValue(Map<String, double> holdings) async {
    final prices = await getCryptoPrices();
    double total = 0;
    holdings.forEach((symbol, amount) {
      total += amount * (prices[symbol] ?? 0);
    });
    return total;
  }
}
