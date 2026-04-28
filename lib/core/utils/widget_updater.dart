import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/il_kodlari.dart';
import '../../features/fiyatlar/data/datasources/fiyat_api_datasource.dart';
import '../../features/fiyatlar/data/datasources/lpg_scraper_datasource.dart';
import '../../features/fiyatlar/data/datasources/marka_fiyat_datasource.dart';
import '../../features/fiyatlar/data/repositories/fiyat_repository_impl.dart';
import 'cache_manager.dart';

/// Android ve iOS ana ekran widget'Ä±nÄ± gÃ¼nceller
class WidgetUpdater {
  static const _androidClassName = 'com.iscgames.fueltr.YakitWidgetProvider';

  /// Arkaplanda (veya refresh butonuna tÄ±klandÄ±ÄŸÄ±nda) tÃ¼m kurguyu toparlayarak widget'Ä± gÃ¼nceller
  static Future<void> fetchAndUpdateDataFromBackground({
    List<String>? overrideIller,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> illerAsList = [];
      if (overrideIller != null && overrideIller.isNotEmpty) {
        illerAsList = overrideIller.take(5).toList();
      } else {
        await prefs.reload();
        final favorilerList = prefs.getStringList('favori_iller');
        final defaultIlKodu = prefs.getString('pref_varsayilan_il') ?? '06';

        if (favorilerList != null && favorilerList.isNotEmpty) {
          illerAsList = favorilerList.take(5).toList();
        } else {
          illerAsList = [defaultIlKodu];
        }
      }

      final client = http.Client();
      final apiDs = FiyatApiDatasource(client);
      final lpgDs = LpgScraperDatasource(client);
      final cache = CacheManager(prefs);
      final repo = FiyatRepositoryImpl(apiDs, lpgDs, cache);
      final markalarDs = MarkaFiyatDatasource(client);

      final tableData = <Map<String, dynamic>>[];
      tableData.add({'is_header': true, 'name': 'Favori Şehirler'});

      MarkaFiyat? globalMinB,
          globalMaxB,
          globalMinM,
          globalMaxM,
          globalMinL,
          globalMaxL;

      for (String ilKodu in illerAsList) {
        final ilAdi = IlKodlari.getIlAdi(ilKodu);
        final ozet = await repo.getIlOzet(ilKodu, ilAdi);

        tableData.add({
          'is_header': false,
          'name': ilAdi,
          'benzin': ozet.benzin95 > 0 ? ozet.benzin95.toStringAsFixed(2) : '-',
          'motorin': ozet.motorin > 0 ? ozet.motorin.toStringAsFixed(2) : '-',
          'lpg': (ozet.lpg != null && ozet.lpg! > 0)
              ? ozet.lpg!.toStringAsFixed(2)
              : '-',
        });

        // Tüm favori iller için markaları çek ve global min/max hesapla
        final markalar = await markalarDs.getMarkaFiyatlari(ilAdi);
        final bigBrandKeywords = [
          'opet',
          'shell',
          'bp',
          'petrol ofisi',
          'aytemiz',
          'total',
        ];
        final bigBrands = markalar.where((m) {
          final nameLow = m.firma.toLowerCase();
          return bigBrandKeywords.any((k) => nameLow.contains(k));
        }).toList();

        for (var m in bigBrands) {
          if (m.benzin != null && m.benzin! > 0) {
            if (globalMinB == null || m.benzin! < globalMinB.benzin!)
              globalMinB = m;
            if (globalMaxB == null || m.benzin! > globalMaxB.benzin!)
              globalMaxB = m;
          }
          if (m.motorin != null && m.motorin! > 0) {
            if (globalMinM == null || m.motorin! < globalMinM.motorin!)
              globalMinM = m;
            if (globalMaxM == null || m.motorin! > globalMaxM.motorin!)
              globalMaxM = m;
          }
          if (m.lpg != null && m.lpg! > 0) {
            if (globalMinL == null || m.lpg! < globalMinL.lpg!) globalMinL = m;
            if (globalMaxL == null || m.lpg! > globalMaxL.lpg!) globalMaxL = m;
          }
        }
      }

      String formatCell(MarkaFiyat? mf, double? fiyat) {
        if (mf == null || fiyat == null || fiyat <= 0) return '-';
        String name = mf.firma;
        if (name.toLowerCase().contains('petrol ofisi')) name = 'PO';
        if (name.toLowerCase().contains('total')) name = 'Total';
        if (name.toLowerCase().contains('aytemiz')) name = 'Aytemiz';
        if (name.toLowerCase().contains('shell')) name = 'Shell';
        if (name.toLowerCase().contains('opet')) name = 'Opet';
        if (name.toLowerCase() == 'bp') name = 'BP';

        return '${fiyat.toStringAsFixed(2)}\n($name)';
      }

      tableData.add({'is_header': true, 'name': 'Piyasa (Favoriler)'});
      tableData.add({
        'is_header': false,
        'name': '🟢 En Ucuz',
        'benzin': formatCell(globalMinB, globalMinB?.benzin),
        'motorin': formatCell(globalMinM, globalMinM?.motorin),
        'lpg': formatCell(globalMinL, globalMinL?.lpg),
      });
      tableData.add({
        'is_header': false,
        'name': '🔴 En Pahalı',
        'benzin': formatCell(globalMaxB, globalMaxB?.benzin),
        'motorin': formatCell(globalMaxM, globalMaxM?.motorin),
        'lpg': formatCell(globalMaxL, globalMaxL?.lpg),
      });

      await guncelle(tableData: tableData);
    } catch (e) {
      await HomeWidget.saveWidgetData('guncelleme', 'Hata!');
      await HomeWidget.updateWidget(androidName: _androidClassName);
      // Background fails gracefully
    }
  }

  /// Widget verilerini güncelle (Yeni dinamik tablo yapısı için)
  static Future<void> guncelle({
    required List<Map<String, dynamic>> tableData,
  }) async {
    try {
      // iOS için App Group ID ayarlaması (Apple Developer hesabınızdaki ile aynı olmalı)
      await HomeWidget.setAppGroupId('group.com.iscgames.fueltr.widget');

      // Android için JSON gönderimi
      final jsonStr = jsonEncode(tableData);
      await HomeWidget.saveWidgetData('table_data', jsonStr);

      // Zaman damgası
      await HomeWidget.saveWidgetData(
        'guncelleme',
        'Son: ${DateFormat('HH:mm').format(DateTime.now())}',
      );

      // Eski formatta tekil atanmış değerler iOS tarafından kullanılabilir,
      // varsa ilk şehri iOS için yedek bırakıyoruz.
      if (tableData.length > 1) {
        final firstRow = tableData.firstWhere(
          (e) => e['is_header'] != true,
          orElse: () => tableData[1],
        );
        await HomeWidget.saveWidgetData(
          'il_adi',
          firstRow['name'] ?? 'Türkiye',
        );
        await HomeWidget.saveWidgetData(
          'benzin_fiyat',
          firstRow['benzin'] ?? '-',
        );
        await HomeWidget.saveWidgetData(
          'motorin_fiyat',
          firstRow['motorin'] ?? '-',
        );
        await HomeWidget.saveWidgetData('lpg_fiyat', firstRow['lpg'] ?? '-');
      }

      await HomeWidget.updateWidget(androidName: _androidClassName);
    } catch (_) {
      // Widget kurulu değilse veya hata olursa
    }
  }
}
