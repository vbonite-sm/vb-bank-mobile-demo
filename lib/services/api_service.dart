import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static Map<String, double>? _cachedRates;
  static DateTime? _lastFetch;

  /// Fetch currency exchange rates
  static Future<Map<String, double>> getCurrencyRates() async {
    // Cache for 5 minutes
    if (_cachedRates != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 5) {
      return _cachedRates!;
    }

    try {
      final response = await http
          .get(Uri.parse(AppConstants.currencyApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        _cachedRates = rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
        _lastFetch = DateTime.now();
        return _cachedRates!;
      }
    } catch (e) {
      print('Failed to fetch currency rates: $e');
    }

    // Fallback rates
    return {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.50,
      'CAD': 1.36,
      'AUD': 1.54,
      'CHF': 0.88,
      'CNY': 7.24,
    };
  }

  /// Convert amount between currencies
  static Future<double> convertCurrency(
    double amount,
    String from,
    String to,
  ) async {
    final rates = await getCurrencyRates();
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return amount / fromRate * toRate;
  }
}
