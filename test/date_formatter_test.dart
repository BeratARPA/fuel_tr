import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('zamanFarki — şimdi', () {
      final now = DateTime.now();
      final result = DateFormatter.zamanFarki(now);
      expect(result, contains('önce'));
    });

    test('zamanFarki — 1 saat önce', () {
      final birSaatOnce = DateTime.now().subtract(const Duration(hours: 1));
      final result = DateFormatter.zamanFarki(birSaatOnce);
      expect(result, contains('saat'));
    });

    test('toEpdkFormat', () {
      final date = DateTime(2026, 3, 21);
      final result = DateFormatter.toEpdkFormat(date);
      expect(result, '21/03/2026');
    });
  });
}
