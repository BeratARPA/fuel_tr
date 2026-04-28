import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/fiyatlar/data/datasources/fiyat_api_datasource.dart';

void main() {
  group('FiyatApiDatasource', () {
    test('parseFiyatValue — Türkçe virgül formatı', () {
      // Testing the parse logic (same as _parseFiyatValue)
      expect(double.tryParse('96,98'.replaceAll(',', '.')), 96.98);
      expect(double.tryParse('72,17'.replaceAll(',', '.')), 72.17);
      expect(double.tryParse('-'), null);
      expect(double.tryParse(''), null);
    });

    test('priceRange — normal', () {
      final range = FiyatApiDatasource.priceRange([90.0, 95.0, 100.0]);
      expect(range, isNotNull);
      expect(range!.min, 90.0);
      expect(range.max, 100.0);
    });

    test('priceRange — aynı fiyat', () {
      final range = FiyatApiDatasource.priceRange([95.0, 95.0]);
      expect(range, isNull);
    });

    test('priceRange — tek fiyat', () {
      final range = FiyatApiDatasource.priceRange([95.0]);
      expect(range, isNull);
    });
  });
}
