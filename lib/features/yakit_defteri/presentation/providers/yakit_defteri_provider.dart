import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../domain/entities/yakit_kayit.dart';

final yakitDefteriProvider =
    StateNotifierProvider<YakitDefteriNotifier, List<YakitKayit>>(
      (ref) => YakitDefteriNotifier(ref.watch(sharedPreferencesProvider)),
    );

class YakitDefteriNotifier extends StateNotifier<List<YakitKayit>> {
  final SharedPreferences _prefs;
  static const _key = 'yakit_defteri';

  YakitDefteriNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final json = _prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List)
          .map((e) => YakitKayit.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.tarih.compareTo(a.tarih)); // En yeni önce
      state = list;
    }
  }

  Future<void> _save() async {
    await _prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void ekle(YakitKayit kayit) {
    state = [kayit, ...state];
    _save();
  }

  void sil(String id) {
    state = state.where((k) => k.id != id).toList();
    _save();
  }

  void guncelle(YakitKayit kayit) {
    state = state.map((k) => k.id == kayit.id ? kayit : k).toList();
    _save();
  }
}

/// İstatistikler — tüm kayıtlar
final yakitIstatistikProvider = Provider<YakitIstatistik>((ref) {
  final kayitlar = ref.watch(yakitDefteriProvider);
  return YakitIstatistik.hesapla(kayitlar);
});

/// Bu ay istatistikleri
final buAyIstatistikProvider = Provider<YakitIstatistik>((ref) {
  final kayitlar = ref.watch(yakitDefteriProvider);
  final now = DateTime.now();
  final buAy = kayitlar
      .where((k) => k.tarih.year == now.year && k.tarih.month == now.month)
      .toList();
  return YakitIstatistik.hesapla(buAy);
});

/// Geçen ay istatistikleri
final gecenAyIstatistikProvider = Provider<YakitIstatistik>((ref) {
  final kayitlar = ref.watch(yakitDefteriProvider);
  final now = DateTime.now();
  final gecenAy = DateTime(now.year, now.month - 1);
  final gecenAyKayitlar = kayitlar
      .where(
        (k) => k.tarih.year == gecenAy.year && k.tarih.month == gecenAy.month,
      )
      .toList();
  return YakitIstatistik.hesapla(gecenAyKayitlar);
});

/// Aylık harcama grafiği verisi (son 6 ay)
final aylikHarcamaProvider = Provider<List<AylikHarcama>>((ref) {
  final kayitlar = ref.watch(yakitDefteriProvider);
  final now = DateTime.now();
  final sonuc = <AylikHarcama>[];

  for (int i = 5; i >= 0; i--) {
    final ay = DateTime(now.year, now.month - i);
    final ayKayitlar = kayitlar
        .where((k) => k.tarih.year == ay.year && k.tarih.month == ay.month)
        .toList();
    final toplam = ayKayitlar.fold(0.0, (sum, k) => sum + k.tutar);
    sonuc.add(
      AylikHarcama(ay: ay, toplam: toplam, kayitSayisi: ayKayitlar.length),
    );
  }
  return sonuc;
});

class AylikHarcama {
  final DateTime ay;
  final double toplam;
  final int kayitSayisi;
  const AylikHarcama({
    required this.ay,
    required this.toplam,
    required this.kayitSayisi,
  });
}
