class YakitKayit {
  final String id;
  final DateTime tarih;
  final double litre;
  final double tutar; // ₺
  final double? kmSayaci;
  final String yakitTipi; // benzin, motorin, lpg
  final String? not;
  final String? aracId;

  const YakitKayit({
    required this.id,
    required this.tarih,
    required this.litre,
    required this.tutar,
    this.kmSayaci,
    required this.yakitTipi,
    this.not,
    this.aracId,
  });

  /// Litre başına fiyat
  double get litreFiyat => litre > 0 ? tutar / litre : 0;

  factory YakitKayit.fromJson(Map<String, dynamic> json) {
    return YakitKayit(
      id: json['id'] as String,
      tarih: DateTime.fromMillisecondsSinceEpoch(json['tarih'] as int),
      litre: (json['litre'] as num).toDouble(),
      tutar: (json['tutar'] as num).toDouble(),
      kmSayaci: (json['kmSayaci'] as num?)?.toDouble(),
      yakitTipi: json['yakitTipi'] as String? ?? 'benzin',
      not: json['not'] as String?,
      aracId: json['aracId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tarih': tarih.millisecondsSinceEpoch,
    'litre': litre,
    'tutar': tutar,
    'kmSayaci': kmSayaci,
    'yakitTipi': yakitTipi,
    'not': not,
    'aracId': aracId,
  };
}

class YakitIstatistik {
  final double toplamHarcama;
  final double toplamLitre;
  final int kayitSayisi;
  final double ortalamaLitreFiyat;
  final double? ortalamaKmTuketim; // L/100km
  final double? toplamKm;

  const YakitIstatistik({
    required this.toplamHarcama,
    required this.toplamLitre,
    required this.kayitSayisi,
    required this.ortalamaLitreFiyat,
    this.ortalamaKmTuketim,
    this.toplamKm,
  });

  static YakitIstatistik hesapla(List<YakitKayit> kayitlar) {
    if (kayitlar.isEmpty) {
      return const YakitIstatistik(
        toplamHarcama: 0,
        toplamLitre: 0,
        kayitSayisi: 0,
        ortalamaLitreFiyat: 0,
      );
    }

    final toplamHarcama = kayitlar.fold(0.0, (sum, k) => sum + k.tutar);
    final toplamLitre = kayitlar.fold(0.0, (sum, k) => sum + k.litre);
    final ortalamaFiyat = toplamLitre > 0 ? toplamHarcama / toplamLitre : 0.0;

    // Km tüketimi hesapla (km sayacı olan kayıtlardan)
    double? ortalamaKm;
    double? toplamKm;
    final kmKayitlar = kayitlar.where((k) => k.kmSayaci != null).toList()
      ..sort((a, b) => a.tarih.compareTo(b.tarih));

    if (kmKayitlar.length >= 2) {
      final ilk = kmKayitlar.first.kmSayaci!;
      final son = kmKayitlar.last.kmSayaci!;
      toplamKm = son - ilk;
      final araLitre = kmKayitlar
          .skip(1) // İlk kayıt hariç (tüketim ölçülemez)
          .fold(0.0, (sum, k) => sum + k.litre);
      if (toplamKm > 0 && araLitre > 0) {
        ortalamaKm = (araLitre / toplamKm) * 100; // L/100km
      }
    }

    return YakitIstatistik(
      toplamHarcama: toplamHarcama,
      toplamLitre: toplamLitre,
      kayitSayisi: kayitlar.length,
      ortalamaLitreFiyat: ortalamaFiyat,
      ortalamaKmTuketim: ortalamaKm,
      toplamKm: toplamKm,
    );
  }
}
