import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/rss_parser.dart';
import '../models/haber_model.dart';

class RssRemoteDatasource {
  final http.Client _client;

  RssRemoteDatasource(this._client);

  Future<List<HaberModel>> fetchZamHaberleri() async {
    final futures = ApiConstants.rssUrls.map(_fetchSingleRss).toList();
    final results = await Future.wait(futures, eagerError: false);

    final allHaberler = results
        .whereType<List<HaberModel>>()
        .expand((list) => list)
        .toList();

    final deduplicated = _deduplicate(allHaberler);

    // İki aşamalı akaryakıt alaka filtresi
    final filtered = deduplicated.where(_akaryakitIlgiliMi).toList();

    filtered.sort((a, b) => b.yayinTarihi.compareTo(a.yayinTarihi));
    return filtered;
  }

  /// İki aşamalı akaryakıt alaka kontrolü:
  /// 1. Kesin akaryakıt ifadesi varsa → KABUL
  /// 2. Kara listedeki kelime varsa → REDDET
  /// 3. Yakıt kelimesi + bağlam kelimesi birlikte varsa → KABUL
  /// 4. Hiçbiri yoksa → REDDET
  static bool _akaryakitIlgiliMi(HaberModel haber) {
    final text = '${haber.baslik} ${haber.ozet}'.toLowerCase();

    // Kara liste kontrolü — bu kelimeler varsa direkt reddet
    for (final kw in ApiConstants.karaListeKelimeleri) {
      if (text.contains(kw.toLowerCase())) return false;
    }

    // Kesin akaryakıt ifadeleri — tek başına yeterli
    for (final ifade in ApiConstants.kesinAkaryakitIfadeleri) {
      if (text.contains(ifade.toLowerCase())) return true;
    }

    // İkili filtre: yakıt kelimesi + bağlam kelimesi
    final yakitVar = ApiConstants.yakitKelimeleri.any(
      (kw) => text.contains(kw.toLowerCase()),
    );
    final baglamVar = ApiConstants.baglamKelimeleri.any(
      (kw) => text.contains(kw.toLowerCase()),
    );

    return yakitVar && baglamVar;
  }

  Future<List<HaberModel>?> _fetchSingleRss(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(AppConstants.rssTimeout);

      if (response.statusCode != 200) return null;

      return RssParser.parse(response.body, url);
    } catch (_) {
      return null;
    }
  }

  List<HaberModel> _deduplicate(List<HaberModel> items) {
    final seen = <String>{};
    return items.where((item) {
      // Daha agresif deduplicate: başlığın ilk 6 kelimesi
      final key = item.baslik
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          .take(6)
          .join(' ');
      return seen.add(key);
    }).toList();
  }
}
