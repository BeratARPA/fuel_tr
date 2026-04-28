import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class CacheManager {
  final SharedPreferences _prefs;

  CacheManager(this._prefs);

  Future<void> saveJson(String key, Object data) async {
    await _prefs.setString(key, jsonEncode(data));
    await _prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  T? getJson<T>(String key, T Function(dynamic) fromJson, {Duration? ttl}) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    final ts = _prefs.getInt('${key}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final maxAge = (ttl ?? AppConstants.defaultCacheTtl).inMilliseconds;

    if (age > maxAge) return null;

    return fromJson(jsonDecode(raw));
  }

  String? getRawJson(String key, {Duration? ttl}) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    if (ttl != null) {
      final ts = _prefs.getInt('${key}_ts') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > ttl.inMilliseconds) return null;
    }

    return raw;
  }

  /// Stale-while-revalidate: veriyi TTL geçse bile döndürür, isStale bilgisi ile
  ({String data, bool isStale})? getWithStaleCheck(
    String key, {
    Duration? ttl,
  }) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    final ts = _prefs.getInt('${key}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final maxAge = (ttl ?? AppConstants.defaultCacheTtl).inMilliseconds;

    return (data: raw, isStale: age > maxAge);
  }

  Future<void> savePreviousPrice(String ilKodu, String jsonData) async {
    await _prefs.setString('prev_fiyat_$ilKodu', jsonData);
    await _prefs.setInt(
      'prev_fiyat_${ilKodu}_ts',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  String? getPreviousPrice(String ilKodu) {
    final ts = _prefs.getInt('prev_fiyat_${ilKodu}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > AppConstants.previousPriceTtl.inMilliseconds) return null;
    return _prefs.getString('prev_fiyat_$ilKodu');
  }

  /// Günlük fiyat tarihçesi kaydet (7 gün)
  Future<void> savePriceHistory(
    String ilKodu,
    Map<String, double> fiyatlar,
  ) async {
    final key = 'history_$ilKodu';
    final raw = _prefs.getString(key);
    List<Map<String, dynamic>> history = [];
    if (raw != null) {
      history = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    }

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Bugün zaten kaydedilmiş mi kontrol et
    if (history.any((h) => h['tarih'] == todayStr)) return;

    history.add({'tarih': todayStr, 'fiyatlar': fiyatlar});

    // Son 7 gün tut
    if (history.length > 7) {
      history = history.sublist(history.length - 7);
    }

    await _prefs.setString(key, jsonEncode(history));
  }

  /// Fiyat tarihçesini oku
  List<Map<String, dynamic>> getPriceHistory(String ilKodu) {
    final key = 'history_$ilKodu';
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// Tüm cache key'lerini döndür (cache_, prev_fiyat_, history_)
  List<String> getCachedKeys() {
    return _prefs
        .getKeys()
        .where(
          (k) =>
              k.startsWith('cache_') ||
              k.startsWith('prev_fiyat_') ||
              k.startsWith('history_'),
        )
        .toList();
  }

  /// Tüm cache verilerini sil — fiyat, haber, karşılaştırma ve tarihçe dahil
  Future<void> clear() async {
    final keys = getCachedKeys();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Cache istatistikleri
  ({int keyCount, List<String> categories}) getCacheStats() {
    final keys = getCachedKeys();
    final categories = <String>{};
    for (final k in keys) {
      if (k.startsWith('cache_fiyat_')) {
        categories.add('fiyat');
      } else if (k.startsWith('cache_top8')) {
        categories.add('top8');
      } else if (k.startsWith('cache_haberler')) {
        categories.add('haberler');
      } else if (k.startsWith('prev_fiyat_')) {
        categories.add('onceki_fiyat');
      } else if (k.startsWith('history_')) {
        categories.add('tarihce');
      }
    }
    return (keyCount: keys.length, categories: categories.toList());
  }
}
