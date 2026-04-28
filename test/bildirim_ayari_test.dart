import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tr/features/bildirimler/domain/entities/bildirim_ayari.dart';

void main() {
  group('BildirimAyari', () {
    test('varsayılan değerler', () {
      const ayar = BildirimAyari();
      expect(ayar.aktif, true);
      expect(ayar.benzinZam, true);
      expect(ayar.motorinZam, true);
      expect(ayar.lpgZam, true);
      expect(ayar.haberBildirim, true);
      expect(ayar.haftalikOzet, true);
      expect(ayar.zamEsigi, 1.5);
      expect(ayar.dusmeEsigi, 1.0);
      expect(ayar.dusmeAktif, true);
    });

    test('fromJson/toJson round-trip', () {
      const original = BildirimAyari(
        aktif: false,
        benzinZam: false,
        zamEsigi: 3.0,
      );

      final json = original.toJson();
      final restored = BildirimAyari.fromJson(json);

      expect(restored.aktif, false);
      expect(restored.benzinZam, false);
      expect(restored.zamEsigi, 3.0);
      expect(restored.motorinZam, true); // varsayılan
    });

    test('copyWith', () {
      const original = BildirimAyari();
      final modified = original.copyWith(aktif: false, zamEsigi: 5.0);

      expect(modified.aktif, false);
      expect(modified.zamEsigi, 5.0);
      expect(modified.benzinZam, true); // değişmedi
    });
  });
}
