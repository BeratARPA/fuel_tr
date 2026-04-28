import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/fiyatlar/domain/usecases/fiyat_tahmin.dart';

void main() {
  group('FiyatTahmin', () {
    test('3 veri noktasından az ise null dönmeli', () {
      final history = [
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 95.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 96.0},
        },
      ];
      final tahmin = FiyatTahmin.hesapla(history, 'benzin');
      expect(tahmin, isNull);
    });

    test('artan fiyat trendi artış olarak tespit edilmeli', () {
      final history = [
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 90.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 93.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 96.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 99.0},
        },
      ];
      final tahmin = FiyatTahmin.hesapla(history, 'benzin');
      expect(tahmin, isNotNull);
      expect(tahmin!.yon, TahminYonu.artis);
      expect(tahmin.tahminiDegisimYuzde, greaterThan(0));
    });

    test('azalan fiyat trendi düşüş olarak tespit edilmeli', () {
      final history = [
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 99.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 96.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 93.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 90.0},
        },
      ];
      final tahmin = FiyatTahmin.hesapla(history, 'benzin');
      expect(tahmin, isNotNull);
      expect(tahmin!.yon, TahminYonu.dusus);
      expect(tahmin.tahminiDegisimYuzde, lessThan(0));
    });

    test('sabit fiyat trendi sabit olarak tespit edilmeli', () {
      final history = [
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 95.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 95.0},
        },
        {
          'fiyatlar': {'Kursunsuz_95(Excellium95)_TL/lt': 95.0},
        },
      ];
      final tahmin = FiyatTahmin.hesapla(history, 'benzin');
      expect(tahmin, isNotNull);
      expect(tahmin!.yon, TahminYonu.sabit);
    });

    test('motorin yakıt tipi eşleşmeli', () {
      final history = [
        {
          'fiyatlar': {'Motorin(Eurodiesel)_TL/lt': 70.0},
        },
        {
          'fiyatlar': {'Motorin(Eurodiesel)_TL/lt': 72.0},
        },
        {
          'fiyatlar': {'Motorin(Eurodiesel)_TL/lt': 74.0},
        },
      ];
      final tahmin = FiyatTahmin.hesapla(history, 'motorin');
      expect(tahmin, isNotNull);
      expect(tahmin!.yon, TahminYonu.artis);
    });
  });
}
