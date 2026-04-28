import '../../domain/entities/akaryakit_fiyat.dart';

class AkaryakitFiyatModel {
  final String yakitTipi;
  final String birim;
  final double fiyat;
  final String? firma;
  final DateTime guncellemeTarihi;

  const AkaryakitFiyatModel({
    required this.yakitTipi,
    required this.birim,
    required this.fiyat,
    this.firma,
    required this.guncellemeTarihi,
  });

  factory AkaryakitFiyatModel.fromJson(Map<String, dynamic> json) {
    return AkaryakitFiyatModel(
      yakitTipi: json['yakitTipi'] as String,
      birim: json['birim'] as String,
      fiyat: (json['fiyat'] as num).toDouble(),
      firma: json['firma'] as String?,
      guncellemeTarihi: DateTime.fromMillisecondsSinceEpoch(
        json['guncellemeTarihi'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'yakitTipi': yakitTipi,
    'birim': birim,
    'fiyat': fiyat,
    'firma': firma,
    'guncellemeTarihi': guncellemeTarihi.millisecondsSinceEpoch,
  };

  AkaryakitFiyat toEntity({double? oncekiFiyat}) {
    return AkaryakitFiyat(
      yakitTipi: yakitTipi,
      birim: birim,
      fiyat: fiyat,
      firma: firma,
      guncellemeTarihi: guncellemeTarihi,
      oncekiFiyat: oncekiFiyat,
    );
  }
}
