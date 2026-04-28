import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

/// Marka bazlı akaryakıt fiyatları (akaryakit.org scraping)
class MarkaFiyatDatasource {
  final http.Client _client;

  /// Bellekte cache
  Map<String, List<MarkaFiyat>>? _cache;
  DateTime? _cacheTime;
  String? _cachedSlug;

  MarkaFiyatDatasource(this._client);

  /// İl adına göre tüm markaların fiyatlarını getirir
  Future<List<MarkaFiyat>> getMarkaFiyatlari(String ilAdi) async {
    final slug = _toSlug(ilAdi);

    // Cache kontrolü
    if (_cachedSlug == slug &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < const Duration(hours: 1)) {
      return _cache![slug] ?? [];
    }

    final url = 'https://akaryakit.org/$slug-akaryakit-fiyatlari';

    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(AppConstants.soapTimeout);

      if (response.statusCode != 200) return [];

      final result = _parseHtml(response.body);
      _cache = {slug: result};
      _cachedSlug = slug;
      _cacheTime = DateTime.now();
      return result;
    } catch (_) {
      return [];
    }
  }

  List<MarkaFiyat> _parseHtml(String html) {
    final tbodyMatch = RegExp(
      r'<tbody>(.*?)(?:</tbody>|</table>)',
      dotAll: true,
    ).firstMatch(html);
    if (tbodyMatch == null) return [];

    final content = tbodyMatch.group(1)!;
    final rows = content.split('<tr>');
    final results = <MarkaFiyat>[];

    // Sütunlar: FİRMA | BENZİN | OTOGAZ | MOTORİN | GAZYAĞı | FUELOIL | KALYAK | TARİH
    for (final row in rows) {
      if (row.trim().isEmpty) continue;
      final cells = row.split(RegExp(r'<td[^>]*>'));
      if (cells.length < 5) continue;

      final firma = _cleanCell(cells.length > 1 ? cells[1] : '');
      final benzin = _parsePrice(cells.length > 2 ? cells[2] : '');
      final lpg = _parsePrice(cells.length > 3 ? cells[3] : '');
      final motorin = _parsePrice(cells.length > 4 ? cells[4] : '');
      final tarih = _cleanCell(cells.length > 8 ? cells[8] : cells.last);

      if (firma.isEmpty) continue;

      results.add(
        MarkaFiyat(
          firma: firma,
          benzin: benzin,
          motorin: motorin,
          lpg: lpg,
          tarih: tarih,
        ),
      );
    }

    // Benzin fiyatına göre sırala
    results.sort((a, b) {
      final aPrice = a.benzin ?? double.infinity;
      final bPrice = b.benzin ?? double.infinity;
      return aPrice.compareTo(bPrice);
    });

    return results;
  }

  String _cleanCell(String cell) {
    return cell
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&#x20BA;', '')
        .replaceAll('\u20BA', '')
        .replaceAll('&#x130;', 'İ')
        .replaceAll('&#x15E;', 'Ş')
        .replaceAll('&#xDC;', 'Ü')
        .replaceAll('&#xC7;', 'Ç')
        .replaceAll('&#xD6;', 'Ö')
        .replaceAll('&#xC9;', 'É')
        .trim();
  }

  double? _parsePrice(String cell) {
    final cleaned = _cleanCell(cell).replaceAll(',', '.').trim();
    if (cleaned.isEmpty || cleaned == '-') return null;
    return double.tryParse(cleaned);
  }

  String _toSlug(String ilAdi) {
    var s = ilAdi.toLowerCase().trim();
    if (s.contains('istanbul')) return 'istanbul';
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
}

class MarkaFiyat {
  final String firma;
  final double? benzin;
  final double? motorin;
  final double? lpg;
  final String tarih;

  const MarkaFiyat({
    required this.firma,
    this.benzin,
    this.motorin,
    this.lpg,
    this.tarih = '',
  });
}
