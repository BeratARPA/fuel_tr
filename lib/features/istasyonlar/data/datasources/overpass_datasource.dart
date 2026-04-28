import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../domain/entities/yakin_istasyon.dart';

class OverpassDatasource {
  final http.Client _client;

  OverpassDatasource(this._client);

  // Birden fazla Overpass endpoint — birisi hata verirse diğerini dene
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Belirtilen konumun çevresindeki benzin istasyonlarını getirir
  Future<List<YakinIstasyon>> getYakinIstasyonlar(
    LatLng konum, {
    int yaricapMetre = 3000,
  }) async {
    final query =
        '[out:json][timeout:10];'
        'node["amenity"="fuel"]'
        '(around:$yaricapMetre,${konum.latitude},${konum.longitude});'
        'out body;';

    http.Response? response;

    for (final endpoint in _endpoints) {
      try {
        // GET ile URL encoding — POST'tan daha güvenilir
        final url = Uri.parse(
          endpoint,
        ).replace(queryParameters: {'data': query});
        response = await _client
            .get(
              url,
              headers: {
                'User-Agent': 'YakitCep/1.0 Flutter',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) break;
        response = null;
      } catch (_) {
        response = null;
      }
    }

    if (response == null || response.statusCode != 200) {
      throw Exception('İstasyon verisi alınamadı. Lütfen tekrar deneyin.');
    }

    final data = jsonDecode(response.body);
    final elements = (data['elements'] as List?) ?? [];

    final istasyonlar = <YakinIstasyon>[];
    for (final e in elements) {
      final tags = e['tags'] as Map<String, dynamic>? ?? {};

      double? lat, lon;
      if (e['type'] == 'node') {
        lat = (e['lat'] as num?)?.toDouble();
        lon = (e['lon'] as num?)?.toDouble();
      } else if (e['center'] != null) {
        lat = (e['center']['lat'] as num?)?.toDouble();
        lon = (e['center']['lon'] as num?)?.toDouble();
      }
      if (lat == null || lon == null) continue;

      final istasyonKonum = LatLng(lat, lon);
      final mesafe = _hesaplaMesafe(konum, istasyonKonum);

      istasyonlar.add(
        YakinIstasyon(
          ad:
              tags['name'] as String? ??
              tags['brand'] as String? ??
              tags['operator'] as String? ??
              'Benzin İstasyonu',
          marka: tags['brand'] as String?,
          operator_: tags['operator'] as String?,
          konum: istasyonKonum,
          mesafeKm: mesafe,
          adres: _buildAdres(tags),
          telefon: tags['phone'] as String? ?? tags['contact:phone'] as String?,
          acikSaatler: tags['opening_hours'] as String?,
        ),
      );
    }

    istasyonlar.sort((a, b) => a.mesafeKm.compareTo(b.mesafeKm));
    return istasyonlar;
  }

  /// Haversine formülü ile mesafe hesapla (km)
  double _hesaplaMesafe(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLon = _toRad(b.longitude - a.longitude);
    final sinLat = sin(dLat / 2);
    final sinLon = sin(dLon / 2);
    final h =
        sinLat * sinLat +
        cos(_toRad(a.latitude)) * cos(_toRad(b.latitude)) * sinLon * sinLon;
    return 2 * R * asin(sqrt(h));
  }

  double _toRad(double deg) => deg * pi / 180;

  String? _buildAdres(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:housenumber'] != null) {
      parts.add('No:${tags['addr:housenumber']}');
    }
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    return parts.isEmpty ? null : parts.join(', ');
  }
}
