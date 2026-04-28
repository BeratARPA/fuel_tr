import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../domain/entities/yakin_istasyon.dart';
import '../providers/istasyon_provider.dart';

Future<void> _yolTarifiAl(YakinIstasyon istasyon) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${istasyon.konum.latitude},${istasyon.konum.longitude}',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class YakinIstasyonlarScreen extends ConsumerWidget {
  const YakinIstasyonlarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final konumAsync = ref.watch(konumProvider);
    final istasyonlarAsync = ref.watch(yakinIstasyonlarProvider);
    final yaricap = ref.watch(yaricapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.yakinIstasyonlarBaslik),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(konumProvider);
              ref.invalidate(yakinIstasyonlarProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Yarıçap seçici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 1000,
                  label: Text('1km', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 3000,
                  label: Text('3km', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 5000,
                  label: Text('5km', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 10000,
                  label: Text('10km', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {yaricap},
              onSelectionChanged: (s) {
                ref.read(yaricapProvider.notifier).state = s.first;
              },
            ),
          ),

          // Harita
          Expanded(
            flex: 2,
            child: konumAsync.when(
              data: (konum) => _HaritaView(
                konum: konum,
                istasyonlar: istasyonlarAsync.valueOrNull ?? [],
                yaricap: yaricap,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: ErrorDisplay(
                  message: '$e',
                  onRetry: () => ref.invalidate(konumProvider),
                ),
              ),
            ),
          ),

          // İstasyon sayısı
          if (istasyonlarAsync.hasValue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.local_gas_station, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l.istasyonBulundu(
                        istasyonlarAsync.value!.length,
                        yaricap >= 1000
                            ? '${yaricap ~/ 1000} km'
                            : '$yaricap m',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // İstasyon listesi
          Expanded(
            flex: 3,
            child: istasyonlarAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Text(l.buYaricaptaYok),
                        TextButton(
                          onPressed: () {
                            if (yaricap < 10000) {
                              ref.read(yaricapProvider.notifier).state =
                                  yaricap * 2;
                            }
                          },
                          child: Text(l.yaricapiGenislet),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      _IstasyonTile(istasyon: list[index]),
                );
              },
              loading: () => const LoadingShimmer(itemCount: 5),
              error: (e, _) => ErrorDisplay(
                message: '${l.istasyonlarYuklenemedi}: $e',
                onRetry: () => ref.invalidate(yakinIstasyonlarProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Harita View ───────────────────────────────────────────
class _HaritaView extends StatefulWidget {
  final LatLng konum;
  final List<YakinIstasyon> istasyonlar;
  final int yaricap;

  const _HaritaView({
    required this.konum,
    required this.istasyonlar,
    required this.yaricap,
  });

  @override
  State<_HaritaView> createState() => _HaritaViewState();
}

class _HaritaViewState extends State<_HaritaView> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  double _zoomForRadius(int yaricap) {
    if (yaricap <= 1000) return 15;
    if (yaricap <= 3000) return 13.5;
    if (yaricap <= 5000) return 12.5;
    return 11.5;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.konum,
        initialZoom: _zoomForRadius(widget.yaricap),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.iscgames.fueltr',
        ),
        // Yarıçap çemberi
        CircleLayer(
          circles: [
            CircleMarker(
              point: widget.konum,
              radius: widget.yaricap.toDouble(),
              useRadiusInMeter: true,
              color: AppColors.primaryLight.withValues(alpha: 0.08),
              borderColor: AppColors.primaryLight.withValues(alpha: 0.3),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        // Marker'lar
        MarkerLayer(
          markers: [
            // Kullanıcı konumu — mavi nokta
            Marker(
              point: widget.konum,
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // İstasyonlar
            ...widget.istasyonlar.map(
              (ist) => Marker(
                point: ist.konum,
                width: 36,
                height: 36,
                child: Tooltip(
                  message: _buildTooltip(ist),
                  child: GestureDetector(
                    onTap: () => _istasyonTiklandi(context, ist),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _markaRenk(ist.markaKisa),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _istasyonTiklandi(BuildContext context, YakinIstasyon ist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IstasyonTile(istasyon: ist),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text(
                    'Yol Tarifi Al',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _yolTarifiAl(ist);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTooltip(YakinIstasyon ist) {
    String msg =
        '${ist.markaKisa}\n${ist.mesafeKm < 1 ? '${(ist.mesafeKm * 1000).toInt()}m' : '${ist.mesafeKm.toStringAsFixed(1)}km'}';
    if (ist.benzinFiyati != null) msg += '\nB: ₺${ist.benzinFiyati}';
    if (ist.motorinFiyati != null) msg += '\nM: ₺${ist.motorinFiyati}';
    if (ist.lpgFiyati != null) msg += '\nL: ₺${ist.lpgFiyati}';
    return msg;
  }

  Color _markaRenk(String marka) {
    switch (marka.toLowerCase()) {
      case 'shell':
        return const Color(0xFFFFCC00);
      case 'bp':
        return const Color(0xFF009900);
      case 'opet':
        return const Color(0xFFE31937);
      case 'petrol ofisi':
        return const Color(0xFF0066CC);
      case 'total':
        return const Color(0xFFFF0000);
      case 'alpet':
        return const Color(0xFF1B4F72);
      default:
        return AppColors.primaryLight;
    }
  }
}

// ─── İstasyon Tile ─────────────────────────────────────────
class _IstasyonTile extends StatelessWidget {
  final YakinIstasyon istasyon;

  const _IstasyonTile({required this.istasyon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _yolTarifiAl(istasyon),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _markaRenk(
                      istasyon.markaKisa,
                    ).withValues(alpha: 0.15),
                    child: Icon(
                      Icons.local_gas_station,
                      color: _markaRenk(istasyon.markaKisa),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          istasyon.markaKisa,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (istasyon.adres != null)
                          Text(
                            istasyon.adres!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _mesafeRenk(
                        istasyon.mesafeKm,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      istasyon.mesafeKm < 1
                          ? '${(istasyon.mesafeKm * 1000).toInt()} m'
                          : '${istasyon.mesafeKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _mesafeRenk(istasyon.mesafeKm),
                      ),
                    ),
                  ),
                ],
              ),
              if (istasyon.benzinFiyati != null ||
                  istasyon.motorinFiyati != null ||
                  istasyon.lpgFiyati != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (istasyon.benzinFiyati != null)
                        Expanded(
                          child: _FiyatKutusu(
                            tip: 'Benzin',
                            fiyat: istasyon.benzinFiyati!,
                            degisim: istasyon.benzinDegisim,
                          ),
                        ),
                      if (istasyon.motorinFiyati != null)
                        Expanded(
                          child: _FiyatKutusu(
                            tip: 'Motorin',
                            fiyat: istasyon.motorinFiyati!,
                            degisim: istasyon.motorinDegisim,
                          ),
                        ),
                      if (istasyon.lpgFiyati != null)
                        Expanded(
                          child: _FiyatKutusu(
                            tip: 'LPG',
                            fiyat: istasyon.lpgFiyati!,
                            degisim: istasyon.lpgDegisim,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _markaRenk(String marka) {
    switch (marka.toLowerCase()) {
      case 'shell':
        return const Color(0xFFFFCC00);
      case 'bp':
        return const Color(0xFF009900);
      case 'opet':
        return const Color(0xFFE31937);
      case 'petrol ofisi':
        return const Color(0xFF0066CC);
      case 'total':
        return const Color(0xFFFF0000);
      case 'alpet':
        return const Color(0xFF1B4F72);
      default:
        return AppColors.primaryLight;
    }
  }

  Color _mesafeRenk(double km) {
    if (km < 1) return AppColors.indirimYesil;
    if (km < 3) return Colors.orange;
    return AppColors.zamKirmizi;
  }
}

class _FiyatKutusu extends StatelessWidget {
  final String tip;
  final double fiyat;
  final double? degisim;

  const _FiyatKutusu({required this.tip, required this.fiyat, this.degisim});

  @override
  Widget build(BuildContext context) {
    // Sadece belirgin değişimleri listele
    final gosterilecekDegisim = (degisim != null && degisim!.abs() >= 0.01)
        ? degisim
        : null;
    final isIndirim = gosterilecekDegisim != null && gosterilecekDegisim < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tip,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₺${fiyat.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (gosterilecekDegisim != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isIndirim
                  ? AppColors.indirimYesil.withValues(alpha: 0.1)
                  : AppColors.zamKirmizi.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIndirim ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 10,
                  color: isIndirim
                      ? AppColors.indirimYesil
                      : AppColors.zamKirmizi,
                ),
                Text(
                  '₺${gosterilecekDegisim.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isIndirim
                        ? AppColors.indirimYesil
                        : AppColors.zamKirmizi,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 16),
      ],
    );
  }
}
