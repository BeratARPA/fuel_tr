import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/fiyat_provider.dart';

/// Yakıt tipi filtresi
final _yakitFiltresiProvider = StateProvider<String>((ref) => 'benzin');

class IsiHaritasiScreen extends ConsumerWidget {
  const IsiHaritasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final ilOzetler = ref.watch(tumIllerOzetProvider);
    final yakitFiltre = ref.watch(_yakitFiltresiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.fiyatHaritasi),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tumIllerOzetProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Yakıt tipi filtresi
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'benzin', label: Text(l.benzin)),
                ButtonSegment(value: 'motorin', label: Text(l.motorin)),
                ButtonSegment(value: 'lpg', label: Text(l.lpg)),
              ],
              selected: {yakitFiltre},
              onSelectionChanged: (s) =>
                  ref.read(_yakitFiltresiProvider.notifier).state = s.first,
            ),
          ),

          // Harita
          Expanded(
            child: ilOzetler.when(
              data: (ozetler) {
                // Fiyatları topla
                final fiyatlar = <_IlFiyat>[];
                for (final ozet in ozetler) {
                  double? fiyat;
                  if (yakitFiltre == 'benzin') {
                    fiyat = ozet.benzin95;
                  } else if (yakitFiltre == 'motorin') {
                    fiyat = ozet.motorin;
                  } else {
                    fiyat = ozet.lpg;
                  }
                  if (fiyat != null && fiyat > 0) {
                    final konum = _ilKonumlari[ozet.ilAdi.toLowerCase()];
                    if (konum != null) {
                      fiyatlar.add(
                        _IlFiyat(
                          ilAdi: ozet.ilAdi,
                          ilKodu: ozet.ilKodu,
                          fiyat: fiyat,
                          konum: konum,
                        ),
                      );
                    }
                  }
                }

                if (fiyatlar.isEmpty) {
                  return Center(child: Text(l.veriBulunamadi));
                }

                // Min-max hesapla (renk skalası için)
                final minFiyat = fiyatlar
                    .map((f) => f.fiyat)
                    .reduce((a, b) => a < b ? a : b);
                final maxFiyat = fiyatlar
                    .map((f) => f.fiyat)
                    .reduce((a, b) => a > b ? a : b);

                return Stack(
                  children: [
                    FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(39.0, 35.5),
                        initialZoom: 5.8,
                        minZoom: 5,
                        maxZoom: 8,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.iscgames.fueltr',
                        ),
                        MarkerLayer(
                          markers: fiyatlar.map((il) {
                            final renk = _fiyatRengi(
                              il.fiyat,
                              minFiyat,
                              maxFiyat,
                            );
                            return Marker(
                              point: il.konum,
                              width: 52,
                              height: 28,
                              child: GestureDetector(
                                onTap: () => _showIlDetail(context, il),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: renk,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: renk.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    il.fiyat.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Renk skalası göstergesi
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _RenkSkalasi(
                        minFiyat: minFiyat,
                        maxFiyat: maxFiyat,
                        yakitTipi: yakitFiltre,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LoadingShimmer(itemCount: 1),
              error: (e, _) => Center(child: Text('${l.hata}: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showIlDetail(BuildContext context, _IlFiyat il) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(il.ilAdi),
        content: Text('${l.fiyat}: ${il.fiyat.toStringAsFixed(2)}₺/L'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // İl detay sayfasına git
              context.go(
                '/fiyatlar/il/${il.ilKodu}?ilAdi=${Uri.encodeComponent(il.ilAdi)}',
              );
            },
            child: Text(l.detay),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.kapat)),
        ],
      ),
    );
  }

  /// Fiyata göre renk: yeşil(ucuz) → sarı(orta) → kırmızı(pahalı)
  static Color _fiyatRengi(double fiyat, double min, double max) {
    if (max == min) return Colors.blue;
    final oran = ((fiyat - min) / (max - min)).clamp(0.0, 1.0);
    if (oran < 0.5) {
      // Yeşil → Sarı
      return Color.lerp(AppColors.indirimYesil, Colors.amber, oran * 2)!;
    } else {
      // Sarı → Kırmızı
      return Color.lerp(Colors.amber, AppColors.zamKirmizi, (oran - 0.5) * 2)!;
    }
  }
}

// ─── Renk Skalası Widget ──────────────────────────────────
class _RenkSkalasi extends StatelessWidget {
  final double minFiyat;
  final double maxFiyat;
  final String yakitTipi;

  const _RenkSkalasi({
    required this.minFiyat,
    required this.maxFiyat,
    required this.yakitTipi,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${yakitTipi[0].toUpperCase()}${yakitTipi.substring(1)} ${l.fiyatDagilimi}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  AppColors.indirimYesil,
                  Colors.amber,
                  AppColors.zamKirmizi,
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${minFiyat.toStringAsFixed(1)}₺',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.indirimYesil,
                ),
              ),
              Text(
                '${((minFiyat + maxFiyat) / 2).toStringAsFixed(1)}₺',
                style: const TextStyle(fontSize: 10, color: Colors.amber),
              ),
              Text(
                '${maxFiyat.toStringAsFixed(1)}₺',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.zamKirmizi,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── İl Fiyat Data Class ──────────────────────────────────
class _IlFiyat {
  final String ilAdi;
  final String ilKodu;
  final double fiyat;
  final LatLng konum;
  const _IlFiyat({
    required this.ilAdi,
    required this.ilKodu,
    required this.fiyat,
    required this.konum,
  });
}

// ─── 81 İl Merkez Koordinatları ───────────────────────────
const _ilKonumlari = <String, LatLng>{
  'adana': LatLng(37.0, 35.32),
  'adıyaman': LatLng(37.76, 38.28),
  'afyonkarahisar': LatLng(38.74, 30.54),
  'ağrı': LatLng(39.72, 43.05),
  'aksaray': LatLng(38.37, 34.03),
  'amasya': LatLng(40.65, 35.83),
  'ankara': LatLng(39.93, 32.86),
  'antalya': LatLng(36.88, 30.70),
  'ardahan': LatLng(41.11, 42.70),
  'artvin': LatLng(41.18, 41.82),
  'aydın': LatLng(37.85, 27.85),
  'balıkesir': LatLng(39.65, 27.88),
  'bartın': LatLng(41.64, 32.34),
  'batman': LatLng(37.88, 41.13),
  'bayburt': LatLng(40.26, 40.22),
  'bilecik': LatLng(40.05, 30.00),
  'bingöl': LatLng(38.88, 40.50),
  'bitlis': LatLng(38.40, 42.11),
  'bolu': LatLng(40.73, 31.61),
  'burdur': LatLng(37.72, 30.29),
  'bursa': LatLng(40.19, 29.06),
  'çanakkale': LatLng(40.15, 26.41),
  'çankırı': LatLng(40.60, 33.62),
  'çorum': LatLng(40.55, 34.95),
  'denizli': LatLng(37.77, 29.09),
  'diyarbakır': LatLng(37.91, 40.24),
  'düzce': LatLng(40.84, 31.16),
  'edirne': LatLng(41.68, 26.56),
  'elazığ': LatLng(38.67, 39.22),
  'erzincan': LatLng(39.75, 39.49),
  'erzurum': LatLng(39.91, 41.28),
  'eskişehir': LatLng(39.77, 30.52),
  'gaziantep': LatLng(37.07, 37.38),
  'giresun': LatLng(40.91, 38.39),
  'gümüşhane': LatLng(40.46, 39.48),
  'hakkari': LatLng(37.58, 43.74),
  'hatay': LatLng(36.40, 36.35),
  'ığdır': LatLng(39.92, 44.05),
  'isparta': LatLng(37.76, 30.55),
  'istanbul': LatLng(41.01, 28.98),
  'izmir': LatLng(38.42, 27.13),
  'kahramanmaraş': LatLng(37.58, 36.94),
  'karabük': LatLng(41.20, 32.63),
  'karaman': LatLng(37.18, 33.23),
  'kars': LatLng(40.61, 43.10),
  'kastamonu': LatLng(41.39, 33.78),
  'kayseri': LatLng(38.73, 35.49),
  'kilis': LatLng(36.72, 37.12),
  'kırıkkale': LatLng(39.85, 33.51),
  'kırklareli': LatLng(41.73, 27.23),
  'kırşehir': LatLng(39.15, 34.17),
  'kocaeli': LatLng(40.77, 29.92),
  'konya': LatLng(37.87, 32.48),
  'kütahya': LatLng(39.42, 29.98),
  'malatya': LatLng(38.35, 38.31),
  'manisa': LatLng(38.62, 27.43),
  'mardin': LatLng(37.31, 40.73),
  'mersin': LatLng(36.81, 34.64),
  'muğla': LatLng(37.22, 28.36),
  'muş': LatLng(38.74, 41.51),
  'nevşehir': LatLng(38.63, 34.71),
  'niğde': LatLng(37.97, 34.69),
  'ordu': LatLng(40.98, 37.88),
  'osmaniye': LatLng(37.07, 36.25),
  'rize': LatLng(41.02, 40.52),
  'sakarya': LatLng(40.68, 30.40),
  'samsun': LatLng(41.29, 36.33),
  'siirt': LatLng(37.93, 41.94),
  'sinop': LatLng(42.03, 35.15),
  'sivas': LatLng(39.75, 37.02),
  'şanlıurfa': LatLng(37.17, 38.79),
  'şırnak': LatLng(37.51, 42.46),
  'tekirdağ': LatLng(41.00, 27.51),
  'tokat': LatLng(40.31, 36.55),
  'trabzon': LatLng(41.00, 39.72),
  'tunceli': LatLng(39.11, 39.55),
  'uşak': LatLng(38.67, 29.41),
  'van': LatLng(38.49, 43.38),
  'yalova': LatLng(40.65, 29.28),
  'yozgat': LatLng(39.82, 34.80),
  'zonguldak': LatLng(41.45, 31.80),
};
