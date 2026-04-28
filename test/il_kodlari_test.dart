import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/core/constants/il_kodlari.dart';

void main() {
  group('IlKodlari', () {
    test('81+1 il mevcut (İstanbul 2 bölge)', () {
      // 81 il - 1 (İstanbul tek) + 2 (Anadolu/Avrupa) = 82
      expect(IlKodlari.iller.length, greaterThanOrEqualTo(82));
    });

    test('getIlAdi — mevcut il', () {
      expect(IlKodlari.getIlAdi('06'), 'Ankara');
      expect(IlKodlari.getIlAdi('341'), 'İstanbul (Anadolu)');
      expect(IlKodlari.getIlAdi('35'), 'İzmir');
    });

    test('getIlAdi — bilinmeyen', () {
      expect(IlKodlari.getIlAdi('99'), 'Bilinmeyen');
    });

    test('getApiSehirAdi', () {
      expect(IlKodlari.getApiSehirAdi('06'), 'ANKARA');
      expect(IlKodlari.getApiSehirAdi('341'), 'ISTANBUL');
      expect(IlKodlari.getApiSehirAdi('33'), 'İÇEL');
    });

    test('sortedByName — alfabetik sıralı', () {
      final sorted = IlKodlari.sortedByName;
      expect(sorted.length, greaterThanOrEqualTo(81));
      expect(sorted.first.value, 'Adana');
    });
  });
}
