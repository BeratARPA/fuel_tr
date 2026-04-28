import '../../domain/entities/haber.dart';

class HaberModel {
  final String baslik;
  final String ozet;
  final String icerik;
  final String url;
  final DateTime yayinTarihi;
  final String kaynak;

  const HaberModel({
    required this.baslik,
    required this.ozet,
    this.icerik = '',
    required this.url,
    required this.yayinTarihi,
    required this.kaynak,
  });

  factory HaberModel.fromJson(Map<String, dynamic> json) {
    return HaberModel(
      baslik: json['baslik'] as String,
      ozet: json['ozet'] as String,
      icerik: json['icerik'] as String? ?? '',
      url: json['url'] as String,
      yayinTarihi: DateTime.fromMillisecondsSinceEpoch(
        json['yayinTarihi'] as int,
      ),
      kaynak: json['kaynak'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'baslik': baslik,
    'ozet': ozet,
    'icerik': icerik,
    'url': url,
    'yayinTarihi': yayinTarihi.millisecondsSinceEpoch,
    'kaynak': kaynak,
  };

  Haber toEntity() {
    final text = '$baslik $ozet'.toLowerCase();
    final etiket = _etiketBelirle(text);
    final zamTuru = _zamTuruBelirle(text);
    final alaka = _alakaSkoruHesapla(text);

    return Haber(
      baslik: baslik,
      ozet: ozet,
      icerik: icerik,
      url: url,
      yayinTarihi: yayinTarihi,
      kaynak: kaynak,
      zamIceriyor:
          etiket != HaberEtiketi.bilgilendirme &&
          etiket != HaberEtiketi.spiDegisimi,
      zamTuru: zamTuru,
      etiket: etiket,
      alaka: alaka,
    );
  }

  /// AkÄ±llÄ± etiket belirleme â€” keyword aÄŸÄ±rlÄ±klÄ± analiz
  static HaberEtiketi _etiketBelirle(String text) {
    // 1. Kesin ZAM ifadeleri
    if (_containsAny(text, _zamKesinKw)) {
      return HaberEtiketi.zamKesin;
    }
    // 2. Kesin Ä°NDÄ°RÄ°M ifadeleri
    if (_containsAny(text, _indirimKesinKw)) {
      return HaberEtiketi.indirimKesin;
    }
    // 3. Zam BEKLENTÄ°SÄ°
    if (_containsAny(text, _zamBeklentiKw)) {
      return HaberEtiketi.zamBeklentisi;
    }
    // 4. Ä°ndirim BEKLENTÄ°SÄ°
    if (_containsAny(text, _indirimBeklentiKw)) {
      return HaberEtiketi.indirimBeklentisi;
    }
    // 5. Genel fiyat deÄŸiÅŸimi
    if (_containsAny(text, _fiyatDegisimiKw)) {
      return HaberEtiketi.fiyatDegisimi;
    }
    // 6. DolaylÄ± etki (petrol, dÃ¶viz, Ã–TV)
    if (_containsAny(text, _spiKw)) {
      return HaberEtiketi.spiDegisimi;
    }
    // 7. VarsayÄ±lan
    return HaberEtiketi.bilgilendirme;
  }

  /// YakÄ±t tÃ¼rÃ¼ belirleme
  static ZamTuru _zamTuruBelirle(String text) {
    if (text.contains('benzin') ||
        text.contains('kurÅŸunsuz') ||
        text.contains('95 oktan')) {
      return ZamTuru.benzin;
    }
    if (text.contains('motorin') || text.contains('dizel')) {
      return ZamTuru.motorin;
    }
    if (text.contains('lpg') || text.contains('otogaz')) {
      return ZamTuru.lpg;
    }
    if (text.contains('Ã¶tv') || text.contains('vergi')) {
      return ZamTuru.otv;
    }
    return ZamTuru.genel;
  }

  /// Alaka skoru: haberin akaryakÄ±tla ne kadar ilgili olduÄŸu (0.0-1.0)
  static double _alakaSkoruHesapla(String text) {
    double skor = 0;

    // DoÄŸrudan akaryakÄ±t kelimeleri â€” yÃ¼ksek puan
    for (final kw in _yuksekAlakaKw) {
      if (text.contains(kw)) skor += 0.25;
    }
    // DolaylÄ± kelimeler â€” dÃ¼ÅŸÃ¼k puan
    for (final kw in _dusukAlakaKw) {
      if (text.contains(kw)) skor += 0.1;
    }
    // Zam/indirim kelimeleri â€” bonus
    for (final kw in [..._zamKesinKw, ..._indirimKesinKw]) {
      if (text.contains(kw)) skor += 0.15;
    }

    return skor.clamp(0.0, 1.0);
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  // â”€â”€â”€ Keyword Listeleri â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _zamKesinKw = [
    'zamlandÄ±',
    'zam geldi',
    'zam yapÄ±ldÄ±',
    'fiyat artÄ±ÅŸÄ±',
    'fiyatÄ± arttÄ±',
    'fiyatlar arttÄ±',
    'fiyatÄ± yÃ¼kseldi',
    'fiyatlar yÃ¼kseldi',
    'kuruÅŸ zam',
    'lira zam',
    'pahalandÄ±',
    'pompa fiyatÄ± arttÄ±',
  ];

  static const _indirimKesinKw = [
    'indirim geldi',
    'indirim yapÄ±ldÄ±',
    'fiyatÄ± dÃ¼ÅŸtÃ¼',
    'fiyatlar dÃ¼ÅŸtÃ¼',
    'fiyatÄ± azaldÄ±',
    'ucuzladÄ±',
    'kuruÅŸ indirim',
    'lira indirim',
    'fiyat dÃ¼ÅŸÃ¼ÅŸÃ¼',
    'pompa fiyatÄ± dÃ¼ÅŸtÃ¼',
  ];

  static const _zamBeklentiKw = [
    'zam bekleniyor',
    'zam gelebilir',
    'zam kapÄ±da',
    'artÄ±ÅŸ bekleniyor',
    'artabilir',
    'yÃ¼kselebilir',
    'zamlanabilir',
    'zam sinyali',
    'zam hazÄ±rlÄ±ÄŸÄ±',
    'pahalanabilir',
    'artacak',
    'yÃ¼kselecek',
  ];

  static const _indirimBeklentiKw = [
    'indirim bekleniyor',
    'indirim gelebilir',
    'dÃ¼ÅŸebilir',
    'ucuzlayabilir',
    'dÃ¼ÅŸecek',
    'indirim sinyali',
    'indirim mÃ¼jdesi',
    'ucuzlayacak',
    'geriledi',
    'gerileme',
  ];

  static const _fiyatDegisimiKw = [
    'fiyat deÄŸiÅŸti',
    'fiyat gÃ¼ncellendi',
    'yeni fiyat',
    'fiyat belirlendi',
    'pompa fiyatÄ±',
    'litre fiyatÄ±',
    'gÃ¼ncel fiyat',
    'fiyat listesi',
    'fiyat tablosu',
  ];

  static const _spiKw = [
    'brent petrol',
    'ham petrol',
    'petrol fiyat',
    'dolar kur',
    'dÃ¶viz kur',
    'Ã¶tv',
    'Ã¶zel tÃ¼ketim vergisi',
    'rafineri',
    'opec',
  ];

  static const _yuksekAlakaKw = [
    'akaryakÄ±t',
    'benzin',
    'motorin',
    'lpg',
    'otogaz',
    'dizel',
    'kurÅŸunsuz',
    'pompa',
    'yakÄ±t',
  ];

  static const _dusukAlakaKw = [
    'petrol',
    'Ã¶tv',
    'rafineri',
    'enerji',
    'brent',
    'opec',
    'varil',
  ];
}
