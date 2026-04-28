/// Basit lineer regresyon ile fiyat tahmini
class FiyatTahmin {
  final TahminYonu yon;
  final double tahminiDegisimYuzde;
  final double guvenSeviyesi; // 0.0 - 1.0
  final int gunSayisi; // kaç günlük veri

  const FiyatTahmin({
    required this.yon,
    required this.tahminiDegisimYuzde,
    required this.guvenSeviyesi,
    required this.gunSayisi,
  });

  /// Price history'den tahmin hesapla
  /// [history]: [{tarih, fiyatlar: {yakitTipi: fiyat}}]
  static FiyatTahmin? hesapla(
    List<Map<String, dynamic>> history,
    String yakitTipi,
  ) {
    if (history.length < 3) return null; // En az 3 veri noktası gerek

    final fiyatlar = <double>[];
    for (final entry in history) {
      final fiyatMap = (entry['fiyatlar'] as Map<String, dynamic>?) ?? {};
      for (final kv in fiyatMap.entries) {
        final tip = kv.key.toLowerCase();
        if (_tipEslesiyor(tip, yakitTipi)) {
          fiyatlar.add((kv.value as num).toDouble());
          break;
        }
      }
    }

    if (fiyatlar.length < 3) return null;

    // Lineer regresyon: y = mx + b
    final n = fiyatlar.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += fiyatlar[i];
      sumXY += i * fiyatlar[i];
      sumX2 += i * i;
    }

    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final sonFiyat = fiyatlar.last;

    // 7 gün sonraki tahmin
    final tahminFiyat = sonFiyat + m * 7;
    final degisimYuzde = sonFiyat > 0
        ? ((tahminFiyat - sonFiyat) / sonFiyat) * 100
        : 0.0;

    // R² hesapla (güven seviyesi)
    final avgY = sumY / n;
    double ssRes = 0, ssTot = 0;
    final b = (sumY - m * sumX) / n;
    for (int i = 0; i < n; i++) {
      final predicted = m * i + b;
      ssRes += (fiyatlar[i] - predicted) * (fiyatlar[i] - predicted);
      ssTot += (fiyatlar[i] - avgY) * (fiyatlar[i] - avgY);
    }
    final r2 = ssTot > 0 ? 1 - (ssRes / ssTot) : 0.0;

    TahminYonu yon;
    if (degisimYuzde.abs() < 0.5) {
      yon = TahminYonu.sabit;
    } else if (degisimYuzde > 0) {
      yon = TahminYonu.artis;
    } else {
      yon = TahminYonu.dusus;
    }

    return FiyatTahmin(
      yon: yon,
      tahminiDegisimYuzde: degisimYuzde,
      guvenSeviyesi: r2.clamp(0.0, 1.0),
      gunSayisi: n,
    );
  }

  static bool _tipEslesiyor(String tip, String aranan) {
    switch (aranan) {
      case 'benzin':
        return tip.contains('95') || tip.contains('kurşunsuz');
      case 'motorin':
        return tip.contains('motorin') && !tip.contains('premium');
      default:
        return false;
    }
  }
}

enum TahminYonu { artis, dusus, sabit }
