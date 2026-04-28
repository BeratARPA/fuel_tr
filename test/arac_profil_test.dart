import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/arac_profili/domain/entities/arac_profil.dart';

void main() {
  group('AracProfil', () {
    test('JSON serialize/deserialize doğru çalışmalı', () {
      final profil = AracProfil(
        id: 'arac1',
        ad: 'Aile Arabası',
        yakitTipi: 'benzin',
        tuketim: 7.5,
        depo: 50,
        plaka: '06 ABC 123',
        marka: 'Toyota',
        model: 'Corolla',
      );

      final json = profil.toJson();
      final restored = AracProfil.fromJson(json);

      expect(restored.id, 'arac1');
      expect(restored.ad, 'Aile Arabası');
      expect(restored.yakitTipi, 'benzin');
      expect(restored.tuketim, 7.5);
      expect(restored.depo, 50);
      expect(restored.plaka, '06 ABC 123');
      expect(restored.marka, 'Toyota');
      expect(restored.model, 'Corolla');
    });

    test('nullable alanlar olmadan çalışmalı', () {
      final profil = AracProfil(
        id: 'arac2',
        ad: 'İş Arabası',
        yakitTipi: 'motorin',
        tuketim: 6.0,
        depo: 55,
      );

      final json = profil.toJson();
      final restored = AracProfil.fromJson(json);

      expect(restored.plaka, isNull);
      expect(restored.marka, isNull);
      expect(restored.model, isNull);
    });
  });
}
