import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../../fiyatlar/data/datasources/marka_fiyat_datasource.dart';
import '../../../ayarlar/presentation/providers/ayarlar_provider.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../data/datasources/overpass_datasource.dart';
import '../../domain/entities/yakin_istasyon.dart';

/// Overpass datasource provider
final overpassDatasourceProvider = Provider<OverpassDatasource>((ref) {
  return OverpassDatasource(ref.watch(httpClientProvider));
});

/// Seçili yarıçap (metre)
final yaricapProvider = StateProvider<int>((ref) => 3000);

/// Kullanıcı konumu
final konumProvider = FutureProvider<LatLng>((ref) async {
  // İzin kontrolü
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Konum servisi kapalı. Lütfen açın.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Konum izni reddedildi.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
  }

  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    ),
  );
  return LatLng(pos.latitude, pos.longitude);
});

/// Yakın istasyonlar
final yakinIstasyonlarProvider = FutureProvider<List<YakinIstasyon>>((
  ref,
) async {
  final konum = await ref.watch(konumProvider.future);
  final yaricap = ref.watch(yaricapProvider);
  final ds = ref.watch(overpassDatasourceProvider);

  final istasyonlar = await ds.getYakinIstasyonlar(
    konum,
    yaricapMetre: yaricap,
  );

  try {
    final ilKodu = ref.read(varsayilanIlProvider) ?? '06';
    final ilAdi = IlKodlari.getIlAdi(ilKodu);

    final markaFiyatlari = await ref
        .read(markaFiyatDatasourceProvider)
        .getMarkaFiyatlari(ilAdi);
    final ilFiyatlari = await ref.read(ilFiyatlariProvider(ilKodu).future);

    double? benzinDegisim;
    double? motorinDegisim;
    double? lpgDegisim;

    for (final f in ilFiyatlari) {
      if (f.oncekiFiyat != null && f.oncekiFiyat! > 0) {
        final tip = f.yakitTipi.toLowerCase();
        final fark = f.fiyat - f.oncekiFiyat!;
        if (fark.abs() < 0.01) continue; // no change

        if (tip.contains('95') ||
            tip.contains('kurşunsuz') ||
            tip.contains('benzin')) {
          if (!tip.contains('premium')) benzinDegisim = fark;
        } else if (tip.contains('motorin')) {
          if (!tip.contains('premium')) motorinDegisim = fark;
        } else if (tip.contains('lpg') || tip.contains('otogaz')) {
          lpgDegisim = fark;
        }
      }
    }

    return istasyonlar.map((ist) {
      final markaAd = ist.markaKisa.toLowerCase();
      final markaFiyat = markaFiyatlari.firstWhere(
        (m) =>
            m.firma.toLowerCase().contains(markaAd) ||
            markaAd.contains(m.firma.toLowerCase()),
        orElse: () => const MarkaFiyat(firma: ''),
      );

      return YakinIstasyon(
        ad: ist.ad,
        marka: ist.marka,
        operator_: ist.operator_,
        konum: ist.konum,
        mesafeKm: ist.mesafeKm,
        adres: ist.adres,
        telefon: ist.telefon,
        acikSaatler: ist.acikSaatler,
        benzinFiyati: markaFiyat.benzin,
        motorinFiyati: markaFiyat.motorin,
        lpgFiyati: markaFiyat.lpg,
        benzinDegisim: benzinDegisim,
        motorinDegisim: motorinDegisim,
        lpgDegisim: lpgDegisim,
      );
    }).toList();
  } catch (e) {
    return istasyonlar;
  }
});
