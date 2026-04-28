import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmDatasource {
  final http.Client _client;

  OsrmDatasource(this._client);

  /// OSRM ile çoklu nokta arası rota hesapla
  /// [noktalar] en az 2 eleman içermeli (başlangıç + varış)
  /// Ara noktalar varsa sırasıyla eklenir
  Future<RotaSonuc> getRoute(
    LatLng baslangic,
    LatLng varis, {
    List<LatLng> araNoktalar = const [],
  }) async {
    // Tüm noktaları sırala: başlangıç → ara noktalar → varış
    final tumNoktalar = [baslangic, ...araNoktalar, varis];

    final coordStr = tumNoktalar
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '$coordStr'
        '?overview=full&geometries=geojson';

    final response = await _client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('OSRM hatası: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('Rota bulunamadı');
    }

    final route = routes[0] as Map<String, dynamic>;
    final distance = (route['distance'] as num).toDouble();
    final duration = (route['duration'] as num).toDouble();

    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List;
    final polylinePoints = coords.map((c) {
      final point = c as List;
      return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
    }).toList();

    return RotaSonuc(
      mesafeKm: distance / 1000,
      sureSaniye: duration,
      rotaNoktlari: polylinePoints,
    );
  }

  /// Reverse geocoding — koordinat → adres
  Future<String> reverseGeocode(LatLng point) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}'
        '&format=json&accept-language=tr&zoom=10';

    try {
      debugPrint(
        '[Nominatim] Reverse geocode: ${point.latitude}, ${point.longitude}',
      );
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'YakitCep/1.0 (Flutter; Android)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return '';

      final body = response.body.trim();
      if (!body.startsWith('{')) return '';

      final json = jsonDecode(body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>?;
      if (address == null) return json['display_name'] as String? ?? '';

      // İlçe, il formatında döndür
      final city =
          address['city'] ?? address['town'] ?? address['county'] ?? '';
      final state = address['state'] ?? address['province'] ?? '';
      final district = address['suburb'] ?? address['neighbourhood'] ?? '';

      final parts = <String>[];
      if (district.toString().isNotEmpty) parts.add(district.toString());
      if (city.toString().isNotEmpty) parts.add(city.toString());
      if (state.toString().isNotEmpty && state != city)
        parts.add(state.toString());

      return parts.isNotEmpty
          ? parts.join(', ')
          : (json['display_name'] as String? ?? '');
    } catch (e) {
      debugPrint('[Nominatim] Reverse hata: $e');
      return '';
    }
  }

  /// 81 il merkezi koordinatları (offline, her zaman çalışır)
  static const turkiyeIlleri = [
    {'ad': 'Adana', 'lat': '37.0000', 'lon': '35.3213'},
    {'ad': 'Adıyaman', 'lat': '37.7648', 'lon': '38.2786'},
    {'ad': 'Afyonkarahisar', 'lat': '38.7507', 'lon': '30.5567'},
    {'ad': 'Ağrı', 'lat': '39.7191', 'lon': '43.0503'},
    {'ad': 'Aksaray', 'lat': '38.3687', 'lon': '34.0370'},
    {'ad': 'Amasya', 'lat': '40.6499', 'lon': '35.8353'},
    {'ad': 'Ankara', 'lat': '39.9334', 'lon': '32.8597'},
    {'ad': 'Antalya', 'lat': '36.8969', 'lon': '30.7133'},
    {'ad': 'Ardahan', 'lat': '41.1105', 'lon': '42.7022'},
    {'ad': 'Artvin', 'lat': '41.1828', 'lon': '41.8183'},
    {'ad': 'Aydın', 'lat': '37.8560', 'lon': '27.8416'},
    {'ad': 'Balıkesir', 'lat': '39.6484', 'lon': '27.8826'},
    {'ad': 'Bartın', 'lat': '41.6344', 'lon': '32.3375'},
    {'ad': 'Batman', 'lat': '37.8812', 'lon': '41.1351'},
    {'ad': 'Bayburt', 'lat': '40.2552', 'lon': '40.2249'},
    {'ad': 'Bilecik', 'lat': '40.0567', 'lon': '30.0665'},
    {'ad': 'Bingöl', 'lat': '38.8854', 'lon': '40.4966'},
    {'ad': 'Bitlis', 'lat': '38.4000', 'lon': '42.1095'},
    {'ad': 'Bolu', 'lat': '40.7314', 'lon': '31.6061'},
    {'ad': 'Burdur', 'lat': '37.7203', 'lon': '30.2908'},
    {'ad': 'Bursa', 'lat': '40.1885', 'lon': '29.0610'},
    {'ad': 'Çanakkale', 'lat': '40.1553', 'lon': '26.4142'},
    {'ad': 'Çankırı', 'lat': '40.6013', 'lon': '33.6134'},
    {'ad': 'Çorum', 'lat': '40.5506', 'lon': '34.9556'},
    {'ad': 'Denizli', 'lat': '37.7765', 'lon': '29.0864'},
    {'ad': 'Diyarbakır', 'lat': '37.9144', 'lon': '40.2306'},
    {'ad': 'Düzce', 'lat': '40.8438', 'lon': '31.1565'},
    {'ad': 'Edirne', 'lat': '41.6818', 'lon': '26.5623'},
    {'ad': 'Elazığ', 'lat': '38.6810', 'lon': '39.2264'},
    {'ad': 'Erzincan', 'lat': '39.7500', 'lon': '39.5000'},
    {'ad': 'Erzurum', 'lat': '39.9000', 'lon': '41.2700'},
    {'ad': 'Eskişehir', 'lat': '39.7767', 'lon': '30.5206'},
    {'ad': 'Gaziantep', 'lat': '37.0662', 'lon': '37.3833'},
    {'ad': 'Giresun', 'lat': '40.9128', 'lon': '38.3895'},
    {'ad': 'Gümüşhane', 'lat': '40.4386', 'lon': '39.5086'},
    {'ad': 'Hakkari', 'lat': '37.5833', 'lon': '43.7333'},
    {'ad': 'Hatay', 'lat': '36.4018', 'lon': '36.3498'},
    {'ad': 'Iğdır', 'lat': '39.9167', 'lon': '44.0500'},
    {'ad': 'Isparta', 'lat': '37.7648', 'lon': '30.5566'},
    {'ad': 'İstanbul', 'lat': '41.0082', 'lon': '28.9784'},
    {'ad': 'İzmir', 'lat': '38.4189', 'lon': '27.1287'},
    {'ad': 'Kahramanmaraş', 'lat': '37.5858', 'lon': '36.9371'},
    {'ad': 'Karabük', 'lat': '41.2061', 'lon': '32.6204'},
    {'ad': 'Karaman', 'lat': '37.1759', 'lon': '33.2287'},
    {'ad': 'Kars', 'lat': '40.6167', 'lon': '43.1000'},
    {'ad': 'Kastamonu', 'lat': '41.3887', 'lon': '33.7827'},
    {'ad': 'Kayseri', 'lat': '38.7312', 'lon': '35.4787'},
    {'ad': 'Kırıkkale', 'lat': '39.8468', 'lon': '33.5153'},
    {'ad': 'Kırklareli', 'lat': '41.7333', 'lon': '27.2167'},
    {'ad': 'Kırşehir', 'lat': '39.1425', 'lon': '34.1709'},
    {'ad': 'Kilis', 'lat': '36.7184', 'lon': '37.1212'},
    {'ad': 'Kocaeli', 'lat': '40.8533', 'lon': '29.8815'},
    {'ad': 'Konya', 'lat': '37.8667', 'lon': '32.4833'},
    {'ad': 'Kütahya', 'lat': '39.4167', 'lon': '29.9833'},
    {'ad': 'Malatya', 'lat': '38.3552', 'lon': '38.3095'},
    {'ad': 'Manisa', 'lat': '38.6191', 'lon': '27.4289'},
    {'ad': 'Mardin', 'lat': '37.3212', 'lon': '40.7245'},
    {'ad': 'Mersin', 'lat': '36.8121', 'lon': '34.6415'},
    {'ad': 'Muğla', 'lat': '37.2153', 'lon': '28.3636'},
    {'ad': 'Muş', 'lat': '38.9462', 'lon': '41.7539'},
    {'ad': 'Nevşehir', 'lat': '38.6939', 'lon': '34.6857'},
    {'ad': 'Niğde', 'lat': '37.9667', 'lon': '34.6833'},
    {'ad': 'Ordu', 'lat': '40.9839', 'lon': '37.8764'},
    {'ad': 'Osmaniye', 'lat': '37.0742', 'lon': '36.2464'},
    {'ad': 'Rize', 'lat': '41.0201', 'lon': '40.5234'},
    {'ad': 'Sakarya', 'lat': '40.6940', 'lon': '30.4358'},
    {'ad': 'Samsun', 'lat': '41.2928', 'lon': '36.3313'},
    {'ad': 'Şanlıurfa', 'lat': '37.1591', 'lon': '38.7969'},
    {'ad': 'Siirt', 'lat': '37.9333', 'lon': '41.9500'},
    {'ad': 'Sinop', 'lat': '42.0231', 'lon': '35.1531'},
    {'ad': 'Şırnak', 'lat': '37.4187', 'lon': '42.4918'},
    {'ad': 'Sivas', 'lat': '39.7477', 'lon': '37.0179'},
    {'ad': 'Tekirdağ', 'lat': '41.0027', 'lon': '27.5127'},
    {'ad': 'Tokat', 'lat': '40.3167', 'lon': '36.5500'},
    {'ad': 'Trabzon', 'lat': '41.0015', 'lon': '39.7178'},
    {'ad': 'Tunceli', 'lat': '39.1079', 'lon': '39.5401'},
    {'ad': 'Uşak', 'lat': '38.6823', 'lon': '29.4082'},
    {'ad': 'Van', 'lat': '38.4891', 'lon': '43.4089'},
    {'ad': 'Yalova', 'lat': '40.6500', 'lon': '29.2667'},
    {'ad': 'Yozgat', 'lat': '39.8181', 'lon': '34.8147'},
    {'ad': 'Zonguldak', 'lat': '41.4564', 'lon': '31.7987'},
  ];
}

class RotaSonuc {
  final double mesafeKm;
  final double sureSaniye;
  final List<LatLng> rotaNoktlari;

  const RotaSonuc({
    required this.mesafeKm,
    required this.sureSaniye,
    required this.rotaNoktlari,
  });

  String get sureText {
    final saat = (sureSaniye / 3600).floor();
    final dakika = ((sureSaniye % 3600) / 60).floor();
    if (saat > 0) return '$saat sa $dakika dk';
    return '$dakika dk';
  }
}

class GeocodeSonuc {
  final String ad;
  final String tamAd;
  final LatLng konum;

  const GeocodeSonuc({required this.ad, this.tamAd = '', required this.konum});
}
