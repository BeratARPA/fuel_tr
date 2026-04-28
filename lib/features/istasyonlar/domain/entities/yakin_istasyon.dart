import 'package:latlong2/latlong.dart';

class YakinIstasyon {
  final String ad;
  final String? marka;
  final String? operator_;
  final LatLng konum;
  final double mesafeKm;
  final String? adres;
  final String? telefon;
  final String? acikSaatler;

  // Fiyat bilgileri
  final double? benzinFiyati;
  final double? motorinFiyati;
  final double? lpgFiyati;

  // Değişim bilgileri (indirim/zam miktarı)
  final double? benzinDegisim;
  final double? motorinDegisim;
  final double? lpgDegisim;

  const YakinIstasyon({
    required this.ad,
    this.marka,
    this.operator_,
    required this.konum,
    required this.mesafeKm,
    this.adres,
    this.telefon,
    this.acikSaatler,
    this.benzinFiyati,
    this.motorinFiyati,
    this.lpgFiyati,
    this.benzinDegisim,
    this.motorinDegisim,
    this.lpgDegisim,
  });

  /// Marka logosu için kısa ad
  String get markaKisa {
    final m = (marka ?? operator_ ?? ad).toLowerCase();
    if (m.contains('shell')) return 'Shell';
    if (m.contains('bp')) return 'BP';
    if (m.contains('opet')) return 'Opet';
    if (m.contains('petrol ofisi') || m.contains('po ')) return 'Petrol Ofisi';
    if (m.contains('total')) return 'Total';
    if (m.contains('alpet')) return 'Alpet';
    if (m.contains('aytemiz')) return 'Aytemiz';
    if (m.contains('kadoil')) return 'Kadoil';
    if (m.contains('moil')) return 'Moil';
    if (m.contains('milangaz')) return 'Milangaz';
    if (m.contains('turkuaz')) return 'Turkuaz';
    if (m.contains('go')) return 'GO';
    return marka ?? operator_ ?? 'İstasyon';
  }
}
