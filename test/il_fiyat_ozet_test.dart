import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/fiyatlar/domain/entities/il_fiyat_ozet.dart';

void main() {
  group('IlFiyatOzet', () {
    test('tüm alanlarla oluşturulabilmeli', () {
      final ozet = IlFiyatOzet(
        ilAdi: 'Ankara',
        ilKodu: '06',
        benzin95: 96.98,
        motorin: 72.17,
        lpg: 31.15,
        sonGuncelleme: DateTime(2026, 3, 22),
        benzinTrend: FiyatTrend.yukari,
        motorinTrend: FiyatTrend.sabit,
      );

      expect(ozet.ilAdi, 'Ankara');
      expect(ozet.ilKodu, '06');
      expect(ozet.benzin95, 96.98);
      expect(ozet.motorin, 72.17);
      expect(ozet.lpg, 31.15);
      expect(ozet.benzinTrend, FiyatTrend.yukari);
      expect(ozet.motorinTrend, FiyatTrend.sabit);
    });

    test('lpg null olabilmeli', () {
      final ozet = IlFiyatOzet(
        ilAdi: 'Ardahan',
        ilKodu: '75',
        benzin95: 0,
        motorin: 0,
        sonGuncelleme: DateTime.now(),
      );

      expect(ozet.lpg, isNull);
      expect(ozet.benzinTrend, FiyatTrend.sabit); // varsayılan
    });
  });

  group('FiyatTrend', () {
    test('3 değer olmalı', () {
      expect(FiyatTrend.values.length, 3);
      expect(FiyatTrend.values, contains(FiyatTrend.yukari));
      expect(FiyatTrend.values, contains(FiyatTrend.asagi));
      expect(FiyatTrend.values, contains(FiyatTrend.sabit));
    });
  });
}
