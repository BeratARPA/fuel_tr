import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/bildirimler/domain/entities/bildirim_ayari.dart';
import '../../features/fiyatlar/data/models/akaryakit_fiyat_model.dart';
import '../../features/fiyatlar/domain/entities/akaryakit_fiyat.dart';

class PriceChangeDetector {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  PriceChangeDetector(this._prefs, this._notificationsPlugin);

  Future<void> checkAndNotify({
    required String ilKodu,
    required List<AkaryakitFiyat> yeniFiyatlar,
    required BildirimAyari ayarlar,
  }) async {
    if (!ayarlar.aktif) return;

    final prevKey = 'prev_fiyat_$ilKodu';
    final prevJson = _prefs.getString(prevKey);

    if (prevJson == null) {
      _savePrevious(prevKey, yeniFiyatlar);
      return;
    }

    final oncekiFiyatlar = (jsonDecode(prevJson) as List)
        .map((e) => AkaryakitFiyatModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final yeni in yeniFiyatlar) {
      final onceki = oncekiFiyatlar
          .where((f) => f.yakitTipi == yeni.yakitTipi)
          .firstOrNull;
      if (onceki == null) continue;

      final degisimYuzdesi = ((yeni.fiyat - onceki.fiyat) / onceki.fiyat) * 100;

      if (degisimYuzdesi >= ayarlar.zamEsigi &&
          _isZamTuruAktif(yeni.yakitTipi, ayarlar)) {
        await _sendNotification(
          id: yeni.yakitTipi.hashCode,
          title: '${yeni.yakitTipi} Zamlandı!',
          body:
              '${yeni.fiyat.toStringAsFixed(2)} ₺ (+%${degisimYuzdesi.toStringAsFixed(1)})',
          payload: 'il:$ilKodu',
        );
      } else if (degisimYuzdesi <= -ayarlar.dusmeEsigi && ayarlar.dusmeAktif) {
        await _sendNotification(
          id: yeni.yakitTipi.hashCode + 1000,
          title: '${yeni.yakitTipi} Fiyatı Düştü',
          body:
              '${yeni.fiyat.toStringAsFixed(2)} ₺ (%${degisimYuzdesi.toStringAsFixed(1)})',
          payload: 'il:$ilKodu',
        );
      }
    }

    _savePrevious(prevKey, yeniFiyatlar);
  }

  bool _isZamTuruAktif(String yakitTipi, BildirimAyari ayarlar) {
    final tip = yakitTipi.toLowerCase();
    if (tip.contains('benzin') ||
        tip.contains('95') ||
        tip.contains('kurşunsuz')) {
      return ayarlar.benzinZam;
    }
    if (tip.contains('motorin')) return ayarlar.motorinZam;
    if (tip.contains('lpg') || tip.contains('otogaz')) return ayarlar.lpgZam;
    return true;
  }

  Future<void> _sendNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'yakit_fiyat',
      'Yakıt Fiyat Bildirimleri',
      channelDescription: 'Yakıt fiyat değişim bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  void _savePrevious(String key, List<AkaryakitFiyat> fiyatlar) {
    final models = fiyatlar
        .map(
          (f) => AkaryakitFiyatModel(
            yakitTipi: f.yakitTipi,
            birim: f.birim,
            fiyat: f.fiyat,
            firma: f.firma,
            guncellemeTarihi: f.guncellemeTarihi,
          ),
        )
        .toList();
    _prefs.setString(key, jsonEncode(models.map((m) => m.toJson()).toList()));
  }
}
