enum FiyatTrend { yukari, asagi, sabit }

class IlFiyatOzet {
  final String ilAdi;
  final String ilKodu;
  final double benzin95;
  final double motorin;
  final double? lpg;
  final DateTime sonGuncelleme;
  final FiyatTrend benzinTrend;
  final FiyatTrend motorinTrend;

  const IlFiyatOzet({
    required this.ilAdi,
    required this.ilKodu,
    required this.benzin95,
    required this.motorin,
    this.lpg,
    required this.sonGuncelleme,
    this.benzinTrend = FiyatTrend.sabit,
    this.motorinTrend = FiyatTrend.sabit,
  });
}
