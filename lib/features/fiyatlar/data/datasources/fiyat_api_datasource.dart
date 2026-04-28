import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/akaryakit_fiyat_model.dart';

/// API tabanlı akaryakıt fiyat kaynağı (hasanadiguzel.com.tr)
/// EPDK verilerini JSON olarak sunar
class FiyatApiDatasource {
  final http.Client _client;

  FiyatApiDatasource(this._client);

  /// İl adına göre akaryakıt fiyatlarını getirir
  Future<List<AkaryakitFiyatModel>> getIlFiyatlari(String sehirAdi) async {
    final url =
        '${ApiConstants.fiyatApiBaseUrl}/sehir=${Uri.encodeComponent(sehirAdi)}';

    for (int attempt = 0; attempt < AppConstants.maxRetry; attempt++) {
      try {
        final response = await _client
            .get(Uri.parse(url))
            .timeout(AppConstants.soapTimeout);

        if (response.statusCode == 200) {
          return _parseResponse(response.body);
        }

        if (attempt == AppConstants.maxRetry - 1) {
          throw NetworkException(
            'API hatası: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      } on NetworkException {
        rethrow;
      } catch (e) {
        if (attempt == AppConstants.maxRetry - 1) {
          throw NetworkException('Bağlantı hatası: $e');
        }
      }
    }
    throw NetworkException('İstek başarısız oldu');
  }

  List<AkaryakitFiyatModel> _parseResponse(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        throw ParseException(
          json['error']?['text']?.toString() ?? 'API hatası',
        );
      }

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null || data.isEmpty) {
        throw ParseException('Fiyat verisi bulunamadı');
      }

      // Tüm entry'lerden fiyat listesi topla, medyan al
      // (Bazı entry'ler anomali içeriyor: 7₺, 22₺ gibi)
      final entries = data.values.cast<Map<String, dynamic>>().toList();

      final results = <AkaryakitFiyatModel>[];
      final now = DateTime.now();

      // Her yakıt tipi için medyan hesapla
      final benzin = _medyanFiyat(entries, 'Kursunsuz_95(Excellium95)_TL/lt');
      if (benzin != null) {
        results.add(
          AkaryakitFiyatModel(
            yakitTipi: 'Kurşunsuz 95',
            birim: 'Litre',
            fiyat: benzin,
            guncellemeTarihi: now,
          ),
        );
      }

      final motorin = _medyanFiyat(entries, 'Motorin(Eurodiesel)_TL/lt');
      if (motorin != null) {
        results.add(
          AkaryakitFiyatModel(
            yakitTipi: 'Motorin',
            birim: 'Litre',
            fiyat: motorin,
            guncellemeTarihi: now,
          ),
        );
      }

      final lpg = _medyanFiyat(entries, 'Otogaz_TL/lt');
      if (lpg != null) {
        results.add(
          AkaryakitFiyatModel(
            yakitTipi: 'LPG (Otogaz)',
            birim: 'Litre',
            fiyat: lpg,
            guncellemeTarihi: now,
          ),
        );
      }

      final motorinPremium = _medyanFiyat(
        entries,
        'Motorin(Excellium_Eurodiesel)_TL/lt',
      );
      if (motorinPremium != null) {
        results.add(
          AkaryakitFiyatModel(
            yakitTipi: 'Motorin (Premium)',
            birim: 'Litre',
            fiyat: motorinPremium,
            guncellemeTarihi: now,
          ),
        );
      }

      if (results.isEmpty) {
        throw ParseException('Geçerli fiyat bulunamadı');
      }

      return results;
    } catch (e) {
      if (e is ParseException || e is NetworkException) rethrow;
      throw ParseException('Veri parse hatası: $e');
    }
  }

  /// Birden fazla entry'den medyan fiyat hesapla (anomalileri filtrele)
  double? _medyanFiyat(List<Map<String, dynamic>> entries, String field) {
    final filtered = _filteredPrices(entries, field);
    if (filtered.isEmpty) return null;

    filtered.sort();
    final mid = filtered.length ~/ 2;
    if (filtered.length % 2 == 0) {
      return double.parse(
        ((filtered[mid - 1] + filtered[mid]) / 2).toStringAsFixed(2),
      );
    }
    return filtered[mid];
  }

  List<double> _filteredPrices(
    List<Map<String, dynamic>> entries,
    String field,
  ) {
    final prices = <double>[];
    for (final entry in entries) {
      final val = _parseFiyatValue(entry[field]?.toString());
      if (val != null && val > 0) prices.add(val);
    }
    final minPrice = field.contains('Otogaz') ? 10.0 : 30.0;
    return prices.where((p) => p >= minPrice && p <= 200).toList();
  }

  /// Min-max fiyat aralığını döndürür (il detay ekranında göstermek için)
  static ({double min, double max})? priceRange(List<double> prices) {
    if (prices.length < 2) return null;
    prices.sort();
    if ((prices.last - prices.first).abs() < 0.01) return null;
    return (min: prices.first, max: prices.last);
  }

  double? _parseFiyatValue(String? raw) {
    if (raw == null || raw.isEmpty || raw == '-' || raw == '""') return null;
    // Türkçe format: virgülü noktaya çevir
    final cleaned = raw.replaceAll(',', '.').replaceAll('"', '').trim();
    return double.tryParse(cleaned);
  }
}
