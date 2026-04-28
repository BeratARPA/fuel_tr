import 'dart:convert';
import 'package:fuel_tr/core/config/app_secrets.dart';
import 'package:http/http.dart' as http;

class DovizVerisi {
  final double usdTry;
  final double eurTry;
  final DateTime tarih;

  const DovizVerisi({
    required this.usdTry,
    required this.eurTry,
    required this.tarih,
  });
}

class BrentVerisi {
  final double fiyatUsd; // Varil başına USD
  final DateTime tarih;
  const BrentVerisi({required this.fiyatUsd, required this.tarih});
}

class DovizDatasource {
  final http.Client _client;

  DovizDatasource(this._client);

  /// Güncel USD/TRY ve EUR/TRY kurları
  Future<DovizVerisi> getGuncelKur() async {
    final response = await _client
        .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Döviz API hatası: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final rates = data['rates'] as Map<String, dynamic>;

    return DovizVerisi(
      usdTry: (rates['TRY'] as num).toDouble(),
      eurTry: (rates['EUR'] as num).toDouble() > 0
          ? (rates['TRY'] as num).toDouble() / (rates['EUR'] as num).toDouble()
          : 0,
      tarih: DateTime.now(),
    );
  }

  /// Brent petrol fiyatı (basit scrape veya mock)
  /// Not: Ücretsiz güvenilir Brent API sınırlı, burada yaklaşık değer kullanıyoruz
  Future<BrentVerisi> getBrentFiyat() async {
    try {
      // Basit yaklaşım: doviz.com'dan Brent bilgisi çekmeye çalış
      final response = await _client
          .get(
            Uri.parse('https://api.collectapi.com/economy/goldPrices'),
            headers: {
              'content-type': 'application/json',
              'authorization': AppSecrets.collectApiKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final result = data['result'] as List;
          for (final item in result) {
            if ((item['name'] as String?)?.toLowerCase().contains('brent') ==
                true) {
              final buying =
                  double.tryParse(item['buying']?.toString() ?? '') ?? 0;
              if (buying > 0) {
                return BrentVerisi(fiyatUsd: buying, tarih: DateTime.now());
              }
            }
          }
        }
      }
    } catch (_) {}

    // Fallback: Yaklaşık güncel Brent fiyatı (Mart 2026)
    return BrentVerisi(fiyatUsd: 72.0, tarih: DateTime.now());
  }
}
