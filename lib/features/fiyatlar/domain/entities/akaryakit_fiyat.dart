class AkaryakitFiyat {
  final String yakitTipi;
  final String birim;
  final double fiyat;
  final String? firma;
  final DateTime guncellemeTarihi;
  final double? oncekiFiyat;

  const AkaryakitFiyat({
    required this.yakitTipi,
    required this.birim,
    required this.fiyat,
    this.firma,
    required this.guncellemeTarihi,
    this.oncekiFiyat,
  });

  double? get degisimYuzdesi {
    if (oncekiFiyat == null || oncekiFiyat == 0) return null;
    return ((fiyat - oncekiFiyat!) / oncekiFiyat!) * 100;
  }

  AkaryakitFiyat copyWith({double? oncekiFiyat}) {
    return AkaryakitFiyat(
      yakitTipi: yakitTipi,
      birim: birim,
      fiyat: fiyat,
      firma: firma,
      guncellemeTarihi: guncellemeTarihi,
      oncekiFiyat: oncekiFiyat ?? this.oncekiFiyat,
    );
  }
}
