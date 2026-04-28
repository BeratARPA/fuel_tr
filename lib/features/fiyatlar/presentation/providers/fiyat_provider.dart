import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/cache_manager.dart';
import '../../../ayarlar/presentation/providers/ayarlar_provider.dart';
import '../../data/datasources/fiyat_api_datasource.dart';
import '../../data/datasources/lpg_scraper_datasource.dart';
import '../../data/datasources/marka_fiyat_datasource.dart';
import '../../data/repositories/fiyat_repository_impl.dart';
import '../../domain/entities/akaryakit_fiyat.dart';
import '../../domain/entities/il_fiyat_ozet.dart';
import '../../domain/repositories/fiyat_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(ref.watch(sharedPreferencesProvider));
});

final fiyatApiDatasourceProvider = Provider<FiyatApiDatasource>((ref) {
  return FiyatApiDatasource(ref.watch(httpClientProvider));
});

final lpgScraperDatasourceProvider = Provider<LpgScraperDatasource>((ref) {
  return LpgScraperDatasource(ref.watch(httpClientProvider));
});

final fiyatRepositoryProvider = Provider<FiyatRepository>((ref) {
  final cacheTtlSeconds = ref.watch(cacheTtlProvider);
  final ttl = Duration(seconds: cacheTtlSeconds);
  return FiyatRepositoryImpl(
    ref.watch(fiyatApiDatasourceProvider),
    ref.watch(lpgScraperDatasourceProvider),
    ref.watch(cacheManagerProvider),
    cacheTtl: ttl,
  );
});

final ilFiyatlariProvider = FutureProvider.family<List<AkaryakitFiyat>, String>(
  (ref, ilKodu) async {
    final repo = ref.watch(fiyatRepositoryProvider);
    return repo.getIlFiyatlari(ilKodu);
  },
);

final top8FirmaFiyatlariProvider = FutureProvider<List<AkaryakitFiyat>>((
  ref,
) async {
  final repo = ref.watch(fiyatRepositoryProvider);
  return repo.getTop8FirmaFiyatlari();
});

final markaFiyatDatasourceProvider = Provider<MarkaFiyatDatasource>((ref) {
  return MarkaFiyatDatasource(ref.watch(httpClientProvider));
});

final markaFiyatlariProvider = FutureProvider.family<List<MarkaFiyat>, String>((
  ref,
  ilAdi,
) async {
  final ds = ref.watch(markaFiyatDatasourceProvider);
  return ds.getMarkaFiyatlari(ilAdi);
});

final ilOzetProvider =
    FutureProvider.family<IlFiyatOzet, ({String ilKodu, String ilAdi})>((
      ref,
      params,
    ) async {
      final repo = ref.watch(fiyatRepositoryProvider);
      return repo.getIlOzet(params.ilKodu, params.ilAdi);
    });

/// Tüm illerin özetleri (ısı haritası için)
final tumIllerOzetProvider = FutureProvider<List<IlFiyatOzet>>((ref) async {
  final repo = ref.watch(fiyatRepositoryProvider);
  // Basit il listesi — repository'den tüm illeri çek
  final illerMap = {
    '01': 'Adana',
    '02': 'Adıyaman',
    '03': 'Afyonkarahisar',
    '04': 'Ağrı',
    '05': 'Amasya',
    '06': 'Ankara',
    '07': 'Antalya',
    '08': 'Artvin',
    '09': 'Aydın',
    '10': 'Balıkesir',
    '11': 'Bilecik',
    '12': 'Bingöl',
    '13': 'Bitlis',
    '14': 'Bolu',
    '15': 'Burdur',
    '16': 'Bursa',
    '17': 'Çanakkale',
    '18': 'Çankırı',
    '19': 'Çorum',
    '20': 'Denizli',
    '21': 'Diyarbakır',
    '22': 'Edirne',
    '23': 'Elazığ',
    '24': 'Erzincan',
    '25': 'Erzurum',
    '26': 'Eskişehir',
    '27': 'Gaziantep',
    '28': 'Giresun',
    '29': 'Gümüşhane',
    '30': 'Hakkari',
    '31': 'Hatay',
    '32': 'Isparta',
    '33': 'Mersin',
    '34': 'İstanbul',
    '35': 'İzmir',
    '36': 'Kars',
    '37': 'Kastamonu',
    '38': 'Kayseri',
    '39': 'Kırklareli',
    '40': 'Kırşehir',
    '41': 'Kocaeli',
    '42': 'Konya',
    '43': 'Kütahya',
    '44': 'Malatya',
    '45': 'Manisa',
    '46': 'Kahramanmaraş',
    '47': 'Mardin',
    '48': 'Muğla',
    '49': 'Muş',
    '50': 'Nevşehir',
    '51': 'Niğde',
    '52': 'Ordu',
    '53': 'Rize',
    '54': 'Sakarya',
    '55': 'Samsun',
    '56': 'Siirt',
    '57': 'Sinop',
    '58': 'Sivas',
    '59': 'Tekirdağ',
    '60': 'Tokat',
    '61': 'Trabzon',
    '62': 'Tunceli',
    '63': 'Şanlıurfa',
    '64': 'Uşak',
    '65': 'Van',
    '66': 'Yozgat',
    '67': 'Zonguldak',
    '68': 'Aksaray',
    '69': 'Bayburt',
    '70': 'Karaman',
    '71': 'Kırıkkale',
    '72': 'Batman',
    '73': 'Şırnak',
    '74': 'Bartın',
    '75': 'Ardahan',
    '76': 'Iğdır',
    '77': 'Yalova',
    '78': 'Karabük',
    '79': 'Kilis',
    '80': 'Osmaniye',
    '81': 'Düzce',
  };

  final ozetler = <IlFiyatOzet>[];
  // 10'lu batch'ler halinde çek (hızlı ve API-dostu)
  final entries = illerMap.entries.toList();
  for (int i = 0; i < entries.length; i += 10) {
    final batch = entries.skip(i).take(10);
    final futures = batch.map((e) async {
      try {
        return await repo.getIlOzet(e.key, e.value);
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    ozetler.addAll(results.whereType<IlFiyatOzet>());
  }
  return ozetler;
});
