import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/cache_manager.dart';
import '../../domain/entities/haber.dart';
import '../../domain/repositories/haber_repository.dart';
import '../datasources/rss_remote_datasource.dart';
import '../models/haber_model.dart';

class HaberRepositoryImpl implements HaberRepository {
  final RssRemoteDatasource _remoteDatasource;
  final CacheManager _cacheManager;

  HaberRepositoryImpl(this._remoteDatasource, this._cacheManager);

  @override
  Future<List<Haber>> getZamHaberleri() async {
    const cacheKey = 'cache_haberler';

    // Cache kontrolü
    final cached = _cacheManager.getRawJson(
      cacheKey,
      ttl: AppConstants.haberCacheTtl,
    );
    if (cached != null) {
      final models = (jsonDecode(cached) as List)
          .map((e) => HaberModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return models.map((m) => m.toEntity()).toList();
    }

    try {
      final models = await _remoteDatasource.fetchZamHaberleri();
      await _cacheManager.saveJson(
        cacheKey,
        models.map((m) => m.toJson()).toList(),
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Cache'den stale veri dön
      final stale = _cacheManager.getWithStaleCheck(cacheKey);
      if (stale != null) {
        final models = (jsonDecode(stale.data) as List)
            .map((e) => HaberModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return models.map((m) => m.toEntity()).toList();
      }
      rethrow;
    }
  }
}
