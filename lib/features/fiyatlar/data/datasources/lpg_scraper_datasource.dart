import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/akaryakit_fiyat_model.dart';

/// akaryakit.org'dan LPG fiyatlarını scrape eder
/// Toplu çekim yapıp bellekte cache'ler — 81 ilin her biri için ayrı istek atmaz
class LpgScraperDatasource {
  final http.Client _client;

  /// Bellekte cache: il slug → fiyat
  Map<String, double>? _bulkCache;
  DateTime? _bulkCacheTime;
  static const _bulkCacheTtl = Duration(hours: 3);

  LpgScraperDatasource(this._client);

  /// İl adına göre LPG ortalama fiyatını getirir
  Future<AkaryakitFiyatModel?> getLpgFiyat(String ilAdi) async {
    // Önce toplu cache'e bak
    if (_isBulkCacheValid) {
      final slug = _toSlug(ilAdi);
      final price = _bulkCache![slug] ?? _bulkCache![_normalizeSlug(slug)];
      if (price != null) {
        return AkaryakitFiyatModel(
          yakitTipi: 'LPG (Otogaz)',
          birim: 'Litre',
          fiyat: price,
          guncellemeTarihi: _bulkCacheTime!,
        );
      }
    }

    // Cache yoksa veya il bulunamadıysa toplu çek
    await _fetchBulkLpg();

    final slug = _toSlug(ilAdi);
    final price = _bulkCache?[slug] ?? _bulkCache?[_normalizeSlug(slug)];
    if (price == null) return null;

    return AkaryakitFiyatModel(
      yakitTipi: 'LPG (Otogaz)',
      birim: 'Litre',
      fiyat: price,
      guncellemeTarihi: DateTime.now(),
    );
  }

  /// Tüm illerin LPG fiyatlarını döndürür (toplu)
  Future<Map<String, double>> getAllLpgFiyatlari() async {
    if (_isBulkCacheValid) return _bulkCache!;
    await _fetchBulkLpg();
    return _bulkCache ?? {};
  }

  bool get _isBulkCacheValid {
    if (_bulkCache == null || _bulkCacheTime == null) return false;
    return DateTime.now().difference(_bulkCacheTime!) < _bulkCacheTtl;
  }

  /// Popüler illerin LPG fiyatlarını paralel çekerek toplu cache oluşturur
  Future<void> _fetchBulkLpg() async {
    const cities = [
      'adana',
      'adiyaman',
      'afyonkarahisar',
      'agri',
      'aksaray',
      'amasya',
      'ankara',
      'antalya',
      'ardahan',
      'artvin',
      'aydin',
      'balikesir',
      'bartin',
      'batman',
      'bayburt',
      'bilecik',
      'bingol',
      'bitlis',
      'bolu',
      'burdur',
      'bursa',
      'canakkale',
      'cankiri',
      'corum',
      'denizli',
      'diyarbakir',
      'duzce',
      'edirne',
      'elazig',
      'erzincan',
      'erzurum',
      'eskisehir',
      'gaziantep',
      'giresun',
      'gumushane',
      'hakkari',
      'hatay',
      'igdir',
      'isparta',
      'istanbul',
      'izmir',
      'kahramanmaras',
      'karabuk',
      'karaman',
      'kars',
      'kastamonu',
      'kayseri',
      'kilis',
      'kirikkale',
      'kirklareli',
      'kirsehir',
      'kocaeli',
      'konya',
      'kutahya',
      'malatya',
      'manisa',
      'mardin',
      'mersin',
      'mugla',
      'mus',
      'nevsehir',
      'nigde',
      'ordu',
      'osmaniye',
      'rize',
      'sakarya',
      'samsun',
      'siirt',
      'sinop',
      'sirnak',
      'sivas',
      'sanliurfa',
      'tekirdag',
      'tokat',
      'trabzon',
      'tunceli',
      'usak',
      'van',
      'yalova',
      'yozgat',
      'zonguldak',
    ];

    final cache = <String, double>{};

    // 10'arlı batch'ler halinde çek (rate limit koruması)
    for (var i = 0; i < cities.length; i += 10) {
      final batch = cities.skip(i).take(10);
      final futures = batch.map((city) async {
        try {
          final url = 'https://akaryakit.org/$city-lpg-fiyatlari';
          final response = await _client
              .get(Uri.parse(url))
              .timeout(AppConstants.soapTimeout);
          if (response.statusCode == 200) {
            final price = _parseAveragePrice(response.body);
            if (price != null) {
              cache[city] = price;
            }
          }
        } catch (_) {
          // Tek bir il hata verirse diğerlerini etkilemesin
        }
      });
      await Future.wait(futures);
    }

    if (cache.isNotEmpty) {
      _bulkCache = cache;
      _bulkCacheTime = DateTime.now();
    }
  }

  double? _parseAveragePrice(String html) {
    final tbodyMatch = RegExp(
      r'<tbody>(.*?)(?:</tbody>|</table>)',
      dotAll: true,
    ).firstMatch(html);
    if (tbodyMatch == null) return null;

    final content = tbodyMatch.group(1)!;
    final rows = content.split('<tr>');

    final prices = <double>[];
    for (final row in rows) {
      if (row.trim().isEmpty) continue;
      final cells = row.split(RegExp(r'<td[^>]*>'));
      if (cells.length < 3) continue;

      final priceCell = cells[2];
      final cleaned = priceCell
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .replaceAll('&#x20BA;', '')
          .replaceAll('\u20BA', '')
          .replaceAll(',', '.')
          .trim();

      final price = double.tryParse(cleaned);
      if (price != null && price > 0 && price < 200) {
        prices.add(price);
      }
    }

    if (prices.isEmpty) return null;
    final average = prices.reduce((a, b) => a + b) / prices.length;
    return double.parse(average.toStringAsFixed(2));
  }

  /// Türkçe il adını URL slug'a çevir
  String _toSlug(String ilAdi) {
    var s = ilAdi.toLowerCase().trim();
    if (s.contains('istanbul')) return 'istanbul';
    if (s.contains('İstanbul')) return 'istanbul';
    const replacements = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'İ': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'Ç': 'c',
      'Ğ': 'g',
      'Ö': 'o',
      'Ş': 's',
      'Ü': 'u',
    };
    for (final entry in replacements.entries) {
      s = s.replaceAll(entry.key, entry.value);
    }
    s = s.replaceAll(RegExp(r'\s*\(.*?\)\s*'), '');
    s = s.replaceAll(RegExp(r'[^a-z0-9]'), '-');
    s = s.replaceAll(RegExp(r'-+'), '-');
    s = s.replaceAll(RegExp(r'^-|-$'), '');
    return s;
  }

  /// Slug normalizasyonu — farklı yazımları eşleştir
  String _normalizeSlug(String slug) {
    const aliases = {
      'mersin': 'icel',
      'icel': 'mersin',
      'kahramanmaras': 'k-maras',
      'k-maras': 'kahramanmaras',
      'sanliurfa': 'urfa',
      'urfa': 'sanliurfa',
    };
    return aliases[slug] ?? slug;
  }
}
