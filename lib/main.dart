import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';
import 'app/app.dart';
import 'app/router.dart';
import 'core/utils/widget_updater.dart';
import 'core/constants/il_kodlari.dart';
import 'core/utils/price_change_detector.dart';
import 'features/bildirimler/domain/entities/bildirim_ayari.dart';
import 'features/fiyatlar/data/datasources/fiyat_api_datasource.dart';
import 'features/fiyatlar/data/datasources/lpg_scraper_datasource.dart';
import 'features/fiyatlar/presentation/providers/fiyat_provider.dart';
import 'features/haberler/data/datasources/rss_remote_datasource.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─── Bildirim Kanalları ────────────────────────────────────
const _fiyatChannel = AndroidNotificationChannel(
  'yakit_fiyat',
  'Yakıt Fiyat Bildirimleri',
  description: 'Fiyat değişim bildirimleri',
  importance: Importance.high,
);

const _haberChannel = AndroidNotificationChannel(
  'yakit_haber',
  'Yakıt Haberleri',
  description: 'Zam ve indirim haberleri',
  importance: Importance.defaultImportance,
);

const _haftalikChannel = AndroidNotificationChannel(
  'yakit_haftalik',
  'Haftalık Özet',
  description: 'Haftalık fiyat özeti',
  importance: Importance.defaultImportance,
);

const _testChannel = AndroidNotificationChannel(
  'yakit_test',
  'Test Bildirimleri',
  description: 'Test bildirimleri',
  importance: Importance.high,
);

// ─── Arka Plan Bildirim Plugin Init ────────────────────────
Future<FlutterLocalNotificationsPlugin> _initNotifPlugin() async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await plugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  // Android bildirim kanallarını oluştur
  final androidPlugin = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(_fiyatChannel);
    await androidPlugin.createNotificationChannel(_haberChannel);
    await androidPlugin.createNotificationChannel(_haftalikChannel);
    await androidPlugin.createNotificationChannel(_testChannel);
  }

  return plugin;
}

// ─── WorkManager Callback ──────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (kDebugMode) print('[WorkManager] Task başladı: $taskName');

      final prefs = await SharedPreferences.getInstance();

      // Bildirim ayarlarını yükle
      final ayarJson = prefs.getString('bildirim_ayarlari');
      final ayarlar = ayarJson != null
          ? BildirimAyari.fromJson(jsonDecode(ayarJson))
          : const BildirimAyari();
      if (!ayarlar.aktif) {
        if (kDebugMode) print('[WorkManager] Bildirimler kapalı, çıkılıyor');
        return true;
      }

      final notifPlugin = await _initNotifPlugin();
      final client = http.Client();

      try {
        // ── Fiyat kontrol görevi ──
        if (taskName == 'fiyat_kontrol_gorevi' ||
            taskName == 'Workmanager.iOSBackgroundTask') {
          await _fiyatKontrol(prefs, notifPlugin, client, ayarlar);
        }

        // ── Haftalık özet görevi ──
        if (taskName == 'haftalik_ozet_gorevi') {
          await _haftalikOzet(prefs, notifPlugin, client, ayarlar);
        }

        // ── RSS haber bildirimi (her iki görevde de) ──
        if (ayarlar.haberBildirim) {
          await _haberKontrol(notifPlugin, client, prefs);
        }
      } finally {
        client.close();
      }

      if (kDebugMode) print('[WorkManager] Task tamamlandı: $taskName');
    } catch (e) {
      if (kDebugMode) print('[WorkManager] HATA: $e');
    }
    return true;
  });
}

/// Favori illerin fiyatlarını kontrol et, değişim varsa bildir
Future<void> _fiyatKontrol(
  SharedPreferences prefs,
  FlutterLocalNotificationsPlugin notifPlugin,
  http.Client client,
  BildirimAyari ayarlar,
) async {
  final detector = PriceChangeDetector(prefs, notifPlugin);
  final favoriIller = prefs.getStringList('favori_iller') ?? ['06'];
  final iller = favoriIller.isEmpty ? ['06'] : favoriIller;

  final apiDs = FiyatApiDatasource(client);
  final lpgDs = LpgScraperDatasource(client);

  for (final ilKodu in iller) {
    try {
      final sehirAdi = IlKodlari.getApiSehirAdi(ilKodu);
      final models = await apiDs.getIlFiyatlari(sehirAdi);

      // LPG fallback
      final hasLpg = models.any(
        (m) =>
            m.yakitTipi.toLowerCase().contains('lpg') ||
            m.yakitTipi.toLowerCase().contains('otogaz'),
      );
      if (!hasLpg) {
        final ilAdi = IlKodlari.getIlAdi(ilKodu);
        try {
          final lpg = await lpgDs.getLpgFiyat(ilAdi);
          if (lpg != null) models.add(lpg);
        } catch (_) {}
      }

      final entities = models.map((m) => m.toEntity()).toList();
      await detector.checkAndNotify(
        ilKodu: ilKodu,
        yeniFiyatlar: entities,
        ayarlar: ayarlar,
      );
      if (kDebugMode) print('[WorkManager] $ilKodu kontrol edildi');
    } catch (e) {
      if (kDebugMode) print('[WorkManager] $ilKodu hata: $e');
    }
  }

  // Fiyatlar güncellendiğine göre ana ekran widget'ını da arka planda tazeleyelim
  await WidgetUpdater.fetchAndUpdateDataFromBackground();
}

/// Haftalık fiyat özeti bildirimi gönder
Future<void> _haftalikOzet(
  SharedPreferences prefs,
  FlutterLocalNotificationsPlugin notifPlugin,
  http.Client client,
  BildirimAyari ayarlar,
) async {
  if (!ayarlar.haftalikOzet) return;

  try {
    final favoriIller = prefs.getStringList('favori_iller') ?? ['06'];
    final ilKodu = favoriIller.first;
    final sehirAdi = IlKodlari.getApiSehirAdi(ilKodu);
    final ilAdi = IlKodlari.getIlAdi(ilKodu);
    final apiDs = FiyatApiDatasource(client);
    final models = await apiDs.getIlFiyatlari(sehirAdi);

    String benzinStr = '-', motorinStr = '-', lpgStr = '-';
    for (final m in models) {
      final tip = m.yakitTipi.toLowerCase();
      if (tip.contains('95') || tip.contains('kurşunsuz')) {
        benzinStr = '${m.fiyat.toStringAsFixed(2)}₺';
      } else if (tip.contains('motorin') && !tip.contains('premium')) {
        motorinStr = '${m.fiyat.toStringAsFixed(2)}₺';
      }
    }

    await notifPlugin.show(
      8888,
      'Haftalık Fiyat Özeti',
      '$ilAdi — Benzin: $benzinStr | Motorin: $motorinStr',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _haftalikChannel.id,
          _haftalikChannel.name,
          channelDescription: _haftalikChannel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(
            '$ilAdi\n'
            'Benzin 95: $benzinStr\n'
            'Motorin: $motorinStr\n'
            'LPG: $lpgStr',
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: 'il:$ilKodu',
    );
    if (kDebugMode) print('[WorkManager] Haftalık özet gönderildi');
  } catch (e) {
    if (kDebugMode) print('[WorkManager] Haftalık özet hata: $e');
  }
}

/// RSS'den zam haberi kontrol et
Future<void> _haberKontrol(
  FlutterLocalNotificationsPlugin notifPlugin,
  http.Client client,
  SharedPreferences prefs,
) async {
  try {
    final rssDs = RssRemoteDatasource(client);
    final haberler = await rssDs.fetchZamHaberleri();

    if (haberler.isNotEmpty) {
      final topHaber = haberler.first;
      final sonHaberUrl = prefs.getString('son_bildirim_haber_url');

      if (topHaber.url != sonHaberUrl) {
        await notifPlugin.show(
          9999,
          'Akaryakıt Haberi',
          topHaber.baslik,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _haberChannel.id,
              _haberChannel.name,
              channelDescription: _haberChannel.description,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              styleInformation: BigTextStyleInformation(topHaber.baslik),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: 'haberler',
        );
        // Zaman kilidi kaldırıldı, sadece haberi gördüğümüzden emin olmak için URL'yi kaydediyoruz
        await prefs.setString('son_bildirim_haber_url', topHaber.url);
        if (kDebugMode)
          print('[WorkManager] Haber bildirimi gönderildi: ${topHaber.baslik}');
      }
    }
  } catch (e) {
    if (kDebugMode) print('[WorkManager] Haber kontrol hata: $e');
  }
}

// ─── Main ──────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri?.host == 'refresh') {
    await WidgetUpdater.fetchAndUpdateDataFromBackground();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);

  final prefs = await SharedPreferences.getInstance();

  // Local Notifications — ön plan init
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) async {
      final payload = response.payload;
      if (payload == null) return;
      if (payload.startsWith('il:')) {
        final ilKodu = payload.substring(3);
        router.go(
          '/fiyatlar/il/$ilKodu?ilAdi=${Uri.encodeComponent(IlKodlari.getIlAdi(ilKodu))}',
        );
      } else if (payload == 'haberler') {
        router.go('/haberler');
      }
    },
  );

  // Android bildirim kanallarını oluştur
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(_fiyatChannel);
    await androidPlugin.createNotificationChannel(_haberChannel);
    await androidPlugin.createNotificationChannel(_haftalikChannel);
    await androidPlugin.createNotificationChannel(_testChannel);
    // Android 13+ izin iste
    await androidPlugin.requestNotificationsPermission();
  }

  // WorkManager — arka plan görev planlayıcı
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode:
        false, // true ise ekranda teknik bildirim gösterir, kapalı tutuyoruz
  );

  // Mevcut görevleri iptal edip yeniden kaydet (güncelleme sonrası temiz başlat)
  await Workmanager().cancelAll();

  // 15 dakikada bir fiyat ve haber kontrolü (Android'in izin verdiği en sık süre)
  await Workmanager().registerPeriodicTask(
    'fiyat_kontrol_v2',
    'fiyat_kontrol_gorevi',
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 2), // İlk çalışma 2dk sonra
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  // Haftalık özet — her 7 günde bir
  await Workmanager().registerPeriodicTask(
    'haftalik_ozet_v2',
    'haftalik_ozet_gorevi',
    frequency: const Duration(hours: 168),
    initialDelay: _initialDelayUntilSunday9am(),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const YakitCepApp(),
    ),
  );
}

/// Pazar 09:00'a kadar olan bekleme süresi
Duration _initialDelayUntilSunday9am() {
  final now = DateTime.now();
  var nextSunday = now;
  while (nextSunday.weekday != DateTime.sunday) {
    nextSunday = nextSunday.add(const Duration(days: 1));
  }
  final target = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 9);
  final delay = target.difference(now);
  return delay.isNegative ? delay + const Duration(days: 7) : delay;
}
