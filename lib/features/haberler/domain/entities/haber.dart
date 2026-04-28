enum ZamTuru { benzin, motorin, lpg, otv, genel }

enum HaberEtiketi {
  zamKesin, // "zamlandı", "zam geldi" gibi kesin ifadeler
  zamBeklentisi, // "zam bekleniyor", "artabilir" gibi belirsiz
  indirimKesin, // "indirim geldi", "düştü" kesin
  indirimBeklentisi, // "indirim bekleniyor", "düşebilir"
  fiyatDegisimi, // genel fiyat değişimi haberi
  spiDegisimi, // petrol/döviz/ÖTV haberi (dolaylı etki)
  bilgilendirme, // akaryakıtla ilgili ama zam/indirim yok
}

class Haber {
  final String baslik;
  final String ozet;
  final String icerik;
  final String url;
  final DateTime yayinTarihi;
  final String kaynak;
  final bool zamIceriyor;
  final ZamTuru? zamTuru;
  final HaberEtiketi etiket;
  final double alaka; // 0.0-1.0 arası alaka skoru

  const Haber({
    required this.baslik,
    required this.ozet,
    this.icerik = '',
    required this.url,
    required this.yayinTarihi,
    required this.kaynak,
    this.zamIceriyor = false,
    this.zamTuru,
    this.etiket = HaberEtiketi.bilgilendirme,
    this.alaka = 0.5,
  });
}

