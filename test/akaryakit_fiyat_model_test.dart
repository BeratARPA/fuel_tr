import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/fiyatlar/data/models/akaryakit_fiyat_model.dart';

void main() {
  group('AkaryakitFiyatModel', () {
    test('fromJson ve toJson round-trip', () {
      final model = AkaryakitFiyatModel(
        yakitTipi: 'Kurşunsuz 95',
        birim: 'Litre',
        fiyat: 96.98,
        firma: 'Shell',
        guncellemeTarihi: DateTime(2026, 3, 21),
      );

      final json = model.toJson();
      final restored = AkaryakitFiyatModel.fromJson(json);

      expect(restored.yakitTipi, 'Kurşunsuz 95');
      expect(restored.birim, 'Litre');
      expect(restored.fiyat, 96.98);
      expect(restored.firma, 'Shell');
    });

    test('toEntity — oncekiFiyat ile', () {
      final model = AkaryakitFiyatModel(
        yakitTipi: 'Motorin',
        birim: 'Litre',
        fiyat: 72.17,
        guncellemeTarihi: DateTime.now(),
      );

      final entity = model.toEntity(oncekiFiyat: 70.0);
      expect(entity.oncekiFiyat, 70.0);
      expect(entity.degisimYuzdesi, closeTo(3.1, 0.1));
    });

    test('toEntity — oncekiFiyat olmadan', () {
      final model = AkaryakitFiyatModel(
        yakitTipi: 'LPG (Otogaz)',
        birim: 'Litre',
        fiyat: 31.15,
        guncellemeTarihi: DateTime.now(),
      );

      final entity = model.toEntity();
      expect(entity.degisimYuzdesi, isNull);
    });
  });
}
