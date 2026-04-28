class HesaplamaSonuc {
  final double mesafeKm;
  final String sureText;
  final double yakitFiyati; // ₺/L
  final String yakitTipi;
  final double tuketim; // L/100km
  final double depoKapasitesi; // L

  const HesaplamaSonuc({
    required this.mesafeKm,
    required this.sureText,
    required this.yakitFiyati,
    required this.yakitTipi,
    required this.tuketim,
    required this.depoKapasitesi,
  });

  /// Toplam yakıt tüketimi (Litre)
  double get toplamTuketim => (mesafeKm * tuketim) / 100;

  /// Toplam maliyet (₺)
  double get toplamMaliyet => toplamTuketim * yakitFiyati;

  /// Km başına maliyet (₺/km)
  double get kmBasinaMaliyet => mesafeKm > 0 ? toplamMaliyet / mesafeKm : 0;

  /// Depo ile gidilebilecek mesafe (km)
  double get depoIleKm => tuketim > 0 ? (depoKapasitesi / tuketim) * 100 : 0;

  /// Yolculuk için kaç depo gerekli
  double get gerekliDepo =>
      depoKapasitesi > 0 ? toplamTuketim / depoKapasitesi : 0;

  /// Gidiş-dönüş toplam maliyet
  double get gidisDonusMaliyet => toplamMaliyet * 2;

  /// Gidiş-dönüş toplam yakıt
  double get gidisDonusYakit => toplamTuketim * 2;

  /// Kişi başı maliyet (1-4 kişi)
  double kisiBasiMaliyet(int kisiSayisi) =>
      kisiSayisi > 0 ? toplamMaliyet / kisiSayisi : toplamMaliyet;
}

/// Popüler araç presetleri
class AracPreset {
  final String ad;
  final String yakitTipi; // benzin, motorin, lpg
  final double tuketim;
  final double depo;

  const AracPreset({
    required this.ad,
    required this.yakitTipi,
    required this.tuketim,
    required this.depo,
  });

  /// Preset key — presentation layer'da localize edilir
  static const List<AracPreset> presetler = [
    AracPreset(ad: 'compact', yakitTipi: 'benzin', tuketim: 6.0, depo: 45),
    AracPreset(ad: 'sedan_benzin', yakitTipi: 'benzin', tuketim: 7.5, depo: 50),
    AracPreset(ad: 'sedan_dizel', yakitTipi: 'motorin', tuketim: 5.5, depo: 50),
    AracPreset(ad: 'suv_benzin', yakitTipi: 'benzin', tuketim: 9.0, depo: 60),
    AracPreset(ad: 'suv_dizel', yakitTipi: 'motorin', tuketim: 7.0, depo: 60),
    AracPreset(ad: 'lpg_sedan', yakitTipi: 'lpg', tuketim: 9.5, depo: 50),
    AracPreset(ad: 'ticari', yakitTipi: 'motorin', tuketim: 8.5, depo: 70),
    AracPreset(ad: 'motosiklet', yakitTipi: 'benzin', tuketim: 3.5, depo: 15),
  ];
}
