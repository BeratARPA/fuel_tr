import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../data/datasources/rss_remote_datasource.dart';
import '../../data/repositories/haber_repository_impl.dart';
import '../../domain/entities/haber.dart';
import '../../domain/repositories/haber_repository.dart';

final rssDatasourceProvider = Provider<RssRemoteDatasource>((ref) {
  return RssRemoteDatasource(ref.watch(httpClientProvider));
});

final haberRepositoryProvider = Provider<HaberRepository>((ref) {
  return HaberRepositoryImpl(
    ref.watch(rssDatasourceProvider),
    ref.watch(cacheManagerProvider),
  );
});

final zamHaberleriProvider = FutureProvider<List<Haber>>((ref) async {
  final repo = ref.watch(haberRepositoryProvider);
  return repo.getZamHaberleri();
});

// ─── Zaman Filtresi ────────────────────────────────────────
enum HaberFiltresi { tumu, son24Saat, buHafta }

final haberFiltresiProvider = StateProvider<HaberFiltresi>(
  (ref) => HaberFiltresi.tumu,
);

// ─── Kategori Filtresi ─────────────────────────────────────
enum KategoriFiltresi { tumu, zam, indirim, fiyat, petrolDoviz }

final kategoriFiltresiProvider = StateProvider<KategoriFiltresi>(
  (ref) => KategoriFiltresi.tumu,
);

// ─── Kombine filtreleme ────────────────────────────────────
final filtrelenmisHaberlerProvider = Provider<AsyncValue<List<Haber>>>((ref) {
  final haberleri = ref.watch(zamHaberleriProvider);
  final zamanFiltre = ref.watch(haberFiltresiProvider);
  final kategoriFiltre = ref.watch(kategoriFiltresiProvider);

  return haberleri.whenData((list) {
    final now = DateTime.now();

    // 1. Zaman filtresi
    var filtered = list;
    switch (zamanFiltre) {
      case HaberFiltresi.son24Saat:
        filtered = filtered
            .where((h) => now.difference(h.yayinTarihi).inHours < 24)
            .toList();
      case HaberFiltresi.buHafta:
        filtered = filtered
            .where((h) => now.difference(h.yayinTarihi).inDays < 7)
            .toList();
      case HaberFiltresi.tumu:
        break;
    }

    // 2. Kategori filtresi
    switch (kategoriFiltre) {
      case KategoriFiltresi.zam:
        filtered = filtered
            .where(
              (h) =>
                  h.etiket == HaberEtiketi.zamKesin ||
                  h.etiket == HaberEtiketi.zamBeklentisi,
            )
            .toList();
      case KategoriFiltresi.indirim:
        filtered = filtered
            .where(
              (h) =>
                  h.etiket == HaberEtiketi.indirimKesin ||
                  h.etiket == HaberEtiketi.indirimBeklentisi,
            )
            .toList();
      case KategoriFiltresi.fiyat:
        filtered = filtered
            .where((h) => h.etiket == HaberEtiketi.fiyatDegisimi)
            .toList();
      case KategoriFiltresi.petrolDoviz:
        filtered = filtered
            .where((h) => h.etiket == HaberEtiketi.spiDegisimi)
            .toList();
      case KategoriFiltresi.tumu:
        break;
    }

    return filtered;
  });
});

// ─── İstatistikler ─────────────────────────────────────────
final haberIstatistikleriProvider = Provider<AsyncValue<Map<String, int>>>((
  ref,
) {
  return ref.watch(zamHaberleriProvider).whenData((list) {
    int zam = 0, indirim = 0, fiyat = 0, spi = 0, bilgi = 0;
    for (final h in list) {
      switch (h.etiket) {
        case HaberEtiketi.zamKesin:
        case HaberEtiketi.zamBeklentisi:
          zam++;
        case HaberEtiketi.indirimKesin:
        case HaberEtiketi.indirimBeklentisi:
          indirim++;
        case HaberEtiketi.fiyatDegisimi:
          fiyat++;
        case HaberEtiketi.spiDegisimi:
          spi++;
        case HaberEtiketi.bilgilendirme:
          bilgi++;
      }
    }
    return {
      'zam': zam,
      'indirim': indirim,
      'fiyat': fiyat,
      'spi': spi,
      'bilgi': bilgi,
      'toplam': list.length,
    };
  });
});
