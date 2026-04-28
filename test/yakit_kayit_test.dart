import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/yakit_defteri/domain/entities/yakit_kayit.dart';

void main() {
  group('YakitKayit', () {
    test('litreFiyat hesaplanmalı', () {
      final kayit = YakitKayit(
        id: '1',
        tarih: DateTime(2026, 3, 1),
        litre: 40,
        tutar: 3800,
        yakitTipi: 'benzin',
      );
      expect(kayit.litreFiyat, 95.0);
    });

    test('litre 0 ise litreFiyat 0 olmalı', () {
      final kayit = YakitKayit(
        id: '2',
        tarih: DateTime(2026, 3, 1),
        litre: 0,
        tutar: 100,
        yakitTipi: 'benzin',
      );
      expect(kayit.litreFiyat, 0);
    });

    test('JSON serialize/deserialize doğru çalışmalı', () {
      final kayit = YakitKayit(
        id: 'test123',
        tarih: DateTime(2026, 3, 15, 10, 30),
        litre: 45.5,
        tutar: 4200.50,
        kmSayaci: 52300,
        yakitTipi: 'motorin',
        not: 'Uzun yol',
        aracId: 'arac1',
      );

      final json = kayit.toJson();
      final restored = YakitKayit.fromJson(json);

      expect(restored.id, 'test123');
      expect(restored.litre, 45.5);
      expect(restored.tutar, 4200.50);
      expect(restored.kmSayaci, 52300);
      expect(restored.yakitTipi, 'motorin');
      expect(restored.not, 'Uzun yol');
      expect(restored.aracId, 'arac1');
    });
  });

  group('YakitIstatistik', () {
    test('boş liste için sıfır değerler dönmeli', () {
      final stat = YakitIstatistik.hesapla([]);
      expect(stat.toplamHarcama, 0);
      expect(stat.toplamLitre, 0);
      expect(stat.kayitSayisi, 0);
      expect(stat.ortalamaLitreFiyat, 0);
      expect(stat.ortalamaKmTuketim, isNull);
    });

    test('toplam harcama ve litre doğru hesaplanmalı', () {
      final kayitlar = [
        YakitKayit(
          id: '1',
          tarih: DateTime(2026, 3, 1),
          litre: 40,
          tutar: 3800,
          yakitTipi: 'benzin',
        ),
        YakitKayit(
          id: '2',
          tarih: DateTime(2026, 3, 10),
          litre: 35,
          tutar: 3325,
          yakitTipi: 'benzin',
        ),
      ];

      final stat = YakitIstatistik.hesapla(kayitlar);
      expect(stat.toplamHarcama, 7125);
      expect(stat.toplamLitre, 75);
      expect(stat.kayitSayisi, 2);
      expect(stat.ortalamaLitreFiyat, 95.0);
    });

    test('km tüketimi 2+ km kayıttan hesaplanmalı', () {
      final kayitlar = [
        YakitKayit(
          id: '1',
          tarih: DateTime(2026, 3, 1),
          litre: 40,
          tutar: 3800,
          kmSayaci: 50000,
          yakitTipi: 'benzin',
        ),
        YakitKayit(
          id: '2',
          tarih: DateTime(2026, 3, 10),
          litre: 35,
          tutar: 3325,
          kmSayaci: 50500,
          yakitTipi: 'benzin',
        ),
      ];

      final stat = YakitIstatistik.hesapla(kayitlar);
      expect(stat.toplamKm, 500);
      // 35L / 500km * 100 = 7.0 L/100km
      expect(stat.ortalamaKmTuketim, closeTo(7.0, 0.01));
    });

    test('tek km kayıt varsa tüketim hesaplanmamalı', () {
      final kayitlar = [
        YakitKayit(
          id: '1',
          tarih: DateTime(2026, 3, 1),
          litre: 40,
          tutar: 3800,
          kmSayaci: 50000,
          yakitTipi: 'benzin',
        ),
      ];

      final stat = YakitIstatistik.hesapla(kayitlar);
      expect(stat.ortalamaKmTuketim, isNull);
    });
  });
}
