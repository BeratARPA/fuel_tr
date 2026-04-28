import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../../../core/utils/cache_manager.dart';
import '../../domain/entities/akaryakit_fiyat.dart';
import '../../domain/entities/il_fiyat_ozet.dart';
import '../../domain/repositories/fiyat_repository.dart';
import '../datasources/fiyat_api_datasource.dart';
import '../datasources/lpg_scraper_datasource.dart';
import '../models/akaryakit_fiyat_model.dart';

class FiyatRepositoryImpl implements FiyatRepository {
  final FiyatApiDatasource _apiDatasource;
  final LpgScraperDatasource _lpgDatasource;
  final CacheManager _cacheManager;
  Duration _cacheTtl;

  FiyatRepositoryImpl(
    this._apiDatasource,
    this._lpgDatasource,
    this._cacheManager, {
    Duration? cacheTtl,
  }) : _cacheTtl = cacheTtl ?? AppConstants.defaultCacheTtl;

  /// Kullanıcı ayarlarından TTL güncelle
  void updateCacheTtl(Duration ttl) => _cacheTtl = ttl;

  @override
  Future<List<AkaryakitFiyat>> getIlFiyatlari(String ilKodu) async {
    final cacheKey = 'cache_fiyat_$ilKodu';

    // Stale-while-revalidate — kullanıcının TTL ayarını kullan
    final cached = _cacheManager.getWithStaleCheck(cacheKey, ttl: _cacheTtl);
    List<AkaryakitFiyatModel>? cachedModels;
    if (cached != null) {
      cachedModels = (jsonDecode(cached.data) as List)
          .map((e) => AkaryakitFiyatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!cached.isStale) {
        return _withPreviousPrices(cachedModels, ilKodu);
      }
    }

    try {
      final sehirAdi = IlKodlari.getApiSehirAdi(ilKodu);
      final models = await _apiDatasource.getIlFiyatlari(sehirAdi);

      // API'den LPG gelmezse akaryakit.org'dan scrape et
      final hasLpg = models.any(
        (m) =>
            m.yakitTipi.toLowerCase().contains('lpg') ||
            m.yakitTipi.toLowerCase().contains('otogaz'),
      );
      if (!hasLpg) {
        final ilAdi = IlKodlari.getIlAdi(ilKodu);
        final lpgModel = await _lpgDatasource.getLpgFiyat(ilAdi);
        if (lpgModel != null) models.add(lpgModel);
      }

      // Mevcut fiyatları önceki fiyat olarak kaydet
      if (cachedModels != null) {
        await _cacheManager.savePreviousPrice(
          ilKodu,
          jsonEncode(cachedModels.map((m) => m.toJson()).toList()),
        );
      } else {
        // İlk yükleme — mevcut fiyatları "önceki" olarak kaydet
        // Sonraki yüklemede karşılaştırma yapılabilsin
        await _cacheManager.savePreviousPrice(
          ilKodu,
          jsonEncode(models.map((m) => m.toJson()).toList()),
        );
      }

      await _cacheManager.saveJson(
        cacheKey,
        models.map((m) => m.toJson()).toList(),
      );

      // Günlük fiyat tarihçesi kaydet
      final historyMap = <String, double>{};
      for (final m in models) {
        historyMap[m.yakitTipi] = m.fiyat;
      }
      await _cacheManager.savePriceHistory(ilKodu, historyMap);

      return _withPreviousPrices(models, ilKodu);
    } catch (e) {
      if (cachedModels != null) {
        return _withPreviousPrices(cachedModels, ilKodu);
      }
      // API'de olmayan iller (Ardahan, Artvin vb.) — sadece LPG dene
      try {
        final ilAdi = IlKodlari.getIlAdi(ilKodu);
        final lpgModel = await _lpgDatasource.getLpgFiyat(ilAdi);
        if (lpgModel != null) {
          final models = [lpgModel];
          await _cacheManager.saveJson(
            cacheKey,
            models.map((m) => m.toJson()).toList(),
          );
          return models.map((m) => m.toEntity()).toList();
        }
      } catch (_) {
        // LPG de başarısız olursa boş liste dön
      }
      return [];
    }
  }

  @override
  Future<List<AkaryakitFiyat>> getTop8FirmaFiyatlari() async {
    // API'de firma bazında veri yok, Ankara verilerini ulusal ortalama olarak kullan
    const cacheKey = 'cache_top8';
    final cached = _cacheManager.getWithStaleCheck(cacheKey, ttl: _cacheTtl);

    if (cached != null && !cached.isStale) {
      final models = (jsonDecode(cached.data) as List)
          .map((e) => AkaryakitFiyatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return models.map((m) => m.toEntity()).toList();
    }

    try {
      final models = await _apiDatasource.getIlFiyatlari('ANKARA');

      // LPG fallback
      final hasLpg = models.any(
        (m) =>
            m.yakitTipi.toLowerCase().contains('lpg') ||
            m.yakitTipi.toLowerCase().contains('otogaz'),
      );
      if (!hasLpg) {
        final lpgModel = await _lpgDatasource.getLpgFiyat('Ankara');
        if (lpgModel != null) models.add(lpgModel);
      }

      await _cacheManager.saveJson(
        cacheKey,
        models.map((m) => m.toJson()).toList(),
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      if (cached != null) {
        final models = (jsonDecode(cached.data) as List)
            .map((e) => AkaryakitFiyatModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return models.map((m) => m.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<AkaryakitFiyat>> getLpgFiyatlari(String ilKodu) async {
    // API'den LPG verisi zaten getIlFiyatlari ile geliyor
    final fiyatlar = await getIlFiyatlari(ilKodu);
    return fiyatlar
        .where(
          (f) =>
              f.yakitTipi.toLowerCase().contains('lpg') ||
              f.yakitTipi.toLowerCase().contains('otogaz'),
        )
        .toList();
  }

  @override
  Future<IlFiyatOzet> getIlOzet(String ilKodu, String ilAdi) async {
    double benzin = 0, motorin = 0;
    double? lpg;

    try {
      final fiyatlar = await getIlFiyatlari(ilKodu);
      for (final f in fiyatlar) {
        final tip = f.yakitTipi.toLowerCase();
        if (tip.contains('95') ||
            tip.contains('kurşunsuz') ||
            tip.contains('benzin')) {
          if (!tip.contains('premium')) benzin = f.fiyat;
        } else if (tip.contains('motorin')) {
          if (!tip.contains('premium')) motorin = f.fiyat;
        } else if (tip.contains('lpg') || tip.contains('otogaz')) {
          lpg = f.fiyat;
        }
      }
    } catch (_) {
      // API'de olmayan iller için (Ardahan, Artvin vb.) sadece LPG dene
      final lpgModel = await _lpgDatasource.getLpgFiyat(ilAdi);
      if (lpgModel != null) lpg = lpgModel.fiyat;
    }

    return IlFiyatOzet(
      ilAdi: ilAdi,
      ilKodu: ilKodu,
      benzin95: benzin,
      motorin: motorin,
      lpg: lpg,
      sonGuncelleme: DateTime.now(),
    );
  }

  List<AkaryakitFiyat> _withPreviousPrices(
    List<AkaryakitFiyatModel> models,
    String ilKodu,
  ) {
    final prevJson = _cacheManager.getPreviousPrice(ilKodu);
    Map<String, double>? prevPrices;
    if (prevJson != null) {
      final prevList = (jsonDecode(prevJson) as List)
          .map((e) => AkaryakitFiyatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      prevPrices = {for (final p in prevList) p.yakitTipi: p.fiyat};
    }

    return models.map((m) {
      return m.toEntity(oncekiFiyat: prevPrices?[m.yakitTipi]);
    }).toList();
  }
}
