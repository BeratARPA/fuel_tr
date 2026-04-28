import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../data/datasources/osrm_datasource.dart';
import '../../domain/entities/hesaplama_sonuc.dart';
import '../../../arac_profili/presentation/providers/arac_profil_provider.dart';
import '../providers/hesaplama_provider.dart';

// İl seçimi provider
final _seciliIlProvider = StateProvider<String>((ref) => '06');
final _gidisDonusProvider = StateProvider<bool>((ref) => false);
final _kisiSayisiProvider = StateProvider<int>((ref) => 1);

class HesaplamaScreen extends ConsumerStatefulWidget {
  const HesaplamaScreen({super.key});

  @override
  ConsumerState<HesaplamaScreen> createState() => _HesaplamaScreenState();
}

class _HesaplamaScreenState extends ConsumerState<HesaplamaScreen> {
  final _tuketimController = TextEditingController(text: '7.0');
  final _depoController = TextEditingController(text: '50');
  String _baslangicLabel = '';
  String _varisLabel = '';
  bool _reverseLoading = false;

  // Harita modu — local state, provider değil
  _HaritaModu _haritaModu = _HaritaModu.yok;

  // Haritaya geçirilecek marker/polyline verileri
  List<_MarkerData> _markers = [];
  List<LatLng> _routePoints = [];

  @override
  void dispose() {
    _tuketimController.dispose();
    _depoController.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    final baslangic = ref.read(baslangicProvider);
    final varis = ref.read(varisProvider);
    final araNoktalar = ref.read(araNoktalarProvider);

    final markers = <_MarkerData>[];
    if (baslangic != null) {
      markers.add(_MarkerData(point: baslangic, type: _MarkerType.baslangic));
    }
    for (int i = 0; i < araNoktalar.length; i++) {
      markers.add(
        _MarkerData(
          point: araNoktalar[i].konum,
          type: _MarkerType.ara,
          index: i + 1,
        ),
      );
    }
    if (varis != null) {
      markers.add(_MarkerData(point: varis, type: _MarkerType.varis));
    }

    setState(() {
      _markers = markers;
    });
  }

  /// Haritaya tıklayınca
  Future<void> _onMapTap(LatLng point) async {
    if (_haritaModu == _HaritaModu.yok) return;

    final mod = _haritaModu;
    setState(() => _reverseLoading = true);

    // Reverse geocoding
    String label =
        '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    try {
      final ds = ref.read(osrmDatasourceProvider);
      final adres = await ds.reverseGeocode(point);
      if (adres.isNotEmpty) label = adres;
    } catch (_) {}

    if (!mounted) return;

    if (mod == _HaritaModu.baslangicSec) {
      ref.read(baslangicProvider.notifier).state = point;
      ref.read(baslangicAdresProvider.notifier).state = label;
      setState(() {
        _baslangicLabel = label;
        _reverseLoading = false;
        _haritaModu = _HaritaModu.varisSec;
      });
    } else if (mod == _HaritaModu.varisSec) {
      ref.read(varisProvider.notifier).state = point;
      ref.read(varisAdresProvider.notifier).state = label;
      setState(() {
        _varisLabel = label;
        _reverseLoading = false;
        _haritaModu = _HaritaModu.yok;
      });
    } else if (mod == _HaritaModu.araNoktaSec) {
      ref
          .read(araNoktalarProvider.notifier)
          .ekle(RotaNokta(konum: point, label: label));
      setState(() {
        _reverseLoading = false;
        _haritaModu = _HaritaModu.yok;
      });
    }

    // Marker'ları güncelle (frame sonrası, rota henüz yüklenmemiş olabilir)
    _updateMarkers();
  }

  /// Şehir listesinden seç
  void _selectCity(String tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SehirSecSheet(
        isBaslangic: tip == 'baslangic',
        onSelected: (ad, konum) {
          Navigator.pop(ctx);
          if (tip == 'baslangic') {
            ref.read(baslangicProvider.notifier).state = konum;
            ref.read(baslangicAdresProvider.notifier).state = ad;
            setState(() => _baslangicLabel = ad);
          } else if (tip == 'varis') {
            ref.read(varisProvider.notifier).state = konum;
            ref.read(varisAdresProvider.notifier).state = ad;
            setState(() => _varisLabel = ad);
          } else {
            ref
                .read(araNoktalarProvider.notifier)
                .ekle(RotaNokta(konum: konum, label: ad));
          }
          _updateMarkers();
        },
      ),
    );
  }

  String _presetAd(String key, AppLocalizations l) {
    switch (key) {
      case 'compact':
        return l.kucukOtomobil;
      case 'sedan_benzin':
        return '${l.sedan} (${l.benzin})';
      case 'sedan_dizel':
        return '${l.sedan} (${l.motorin})';
      case 'suv_benzin':
        return '${l.suv} (${l.benzin})';
      case 'suv_dizel':
        return '${l.suv} (${l.motorin})';
      case 'lpg_sedan':
        return 'LPG ${l.sedan}';
      case 'ticari':
        return '${l.ticari} (${l.motorin})';
      case 'motosiklet':
        return l.motosiklet;
      default:
        return key;
    }
  }

  void _showAracPresetler(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.aracSec,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final kayitliAraclar = ref.watch(aracProfilProvider);
                    final tumListe = [
                      // Önce kayıtlı araçlar
                      ...kayitliAraclar.map(
                        (a) => _AracItem(
                          ad: '${a.ad}${a.plaka != null ? " (${a.plaka})" : ""}',
                          tuketim: a.tuketim,
                          depo: a.depo,
                          yakitTipi: a.yakitTipi,
                          isKayitli: true,
                        ),
                      ),
                      // Sonra hazır presetler
                      ...AracPreset.presetler.map(
                        (p) => _AracItem(
                          ad: _presetAd(p.ad, l),
                          tuketim: p.tuketim,
                          depo: p.depo,
                          yakitTipi: p.yakitTipi,
                          isKayitli: false,
                        ),
                      ),
                    ];
                    return ListView.builder(
                      itemCount: tumListe.length,
                      itemBuilder: (context, index) {
                        final item = tumListe[index];
                        // Kayıtlı araçlar ve presetler arası bölücü
                        final showDivider =
                            index == kayitliAraclar.length &&
                            kayitliAraclar.isNotEmpty;
                        return Column(
                          children: [
                            if (showDivider)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        l.hazirAraclar,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                            ListTile(
                              leading: Icon(
                                item.yakitTipi == 'motorin'
                                    ? Icons.local_shipping
                                    : Icons.directions_car,
                                color: item.yakitTipi == 'benzin'
                                    ? AppColors.benzinTuruncu
                                    : item.yakitTipi == 'motorin'
                                    ? AppColors.motorinMavi
                                    : AppColors.lpgMor,
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(item.ad)),
                                  if (item.isKayitli)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.indirimYesil
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l.kayitli,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.indirimYesil,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                '${item.tuketim} L/100km • ${item.depo.toInt()}L depo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                _tuketimController.text = item.tuketim
                                    .toString();
                                _depoController.text = item.depo
                                    .toInt()
                                    .toString();
                                ref.read(tuketimProvider.notifier).state =
                                    item.tuketim;
                                ref
                                        .read(depoKapasitesiProvider.notifier)
                                        .state =
                                    item.depo;
                                ref.read(yakitTipiProvider.notifier).state =
                                    item.yakitTipi;
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _temizle() {
    ref.read(baslangicProvider.notifier).state = null;
    ref.read(varisProvider.notifier).state = null;
    ref.read(araNoktalarProvider.notifier).temizle();
    setState(() {
      _baslangicLabel = '';
      _varisLabel = '';
      _haritaModu = _HaritaModu.yok;
      _markers = [];
      _routePoints = [];
    });
  }

  Color _modColor(_HaritaModu mod) {
    switch (mod) {
      case _HaritaModu.baslangicSec:
        return AppColors.indirimYesil;
      case _HaritaModu.araNoktaSec:
        return Colors.orange;
      case _HaritaModu.varisSec:
        return AppColors.zamKirmizi;
      default:
        return Colors.grey;
    }
  }

  String _modText(_HaritaModu mod, AppLocalizations l) {
    switch (mod) {
      case _HaritaModu.baslangicSec:
        return l.haritadaBaslangicaDok;
      case _HaritaModu.araNoktaSec:
        return l.haritadaAraNoktayaDok;
      case _HaritaModu.varisSec:
        return l.haritadaVarisaDok;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final yakitTipi = ref.watch(yakitTipiProvider);
    final baslangic = ref.watch(baslangicProvider);
    final varis = ref.watch(varisProvider);
    final araNoktalar = ref.watch(araNoktalarProvider);
    final rota = ref.watch(rotaProvider);
    final seciliIl = ref.watch(_seciliIlProvider);

    // Rota güncellendiğinde polyline'ı güncelle (build içinde değil, listener ile)
    ref.listen(rotaProvider, (prev, next) {
      if (next.valueOrNull != null) {
        setState(() {
          _routePoints = next.valueOrNull!.rotaNoktlari;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l.yakitHesapla)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Araç Bilgileri ---
          Row(
            children: [
              Expanded(
                child: Text(
                  l.aracBilgileri,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              // Hazır araç seçici
              TextButton.icon(
                onPressed: () => _showAracPresetler(context),
                icon: const Icon(Icons.directions_car, size: 16),
                label: Text(l.hazirArac, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'benzin', label: Text(l.benzin)),
              ButtonSegment(value: 'motorin', label: Text(l.motorin)),
              ButtonSegment(value: 'lpg', label: Text(l.lpg)),
            ],
            selected: {yakitTipi},
            onSelectionChanged: (s) =>
                ref.read(yakitTipiProvider.notifier).state = s.first,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tuketimController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.tuketim,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    if (val != null && val > 0) {
                      ref.read(tuketimProvider.notifier).state = val;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _depoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.depoKapasite,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    if (val != null && val > 0) {
                      ref.read(depoKapasitesiProvider.notifier).state = val;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // İl seçimi (fiyat için)
          Row(
            children: [
              Text('${l.fiyatIli}: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: seciliIl,
                  isExpanded: true,
                  items: IlKodlari.sortedByName
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(_seciliIlProvider.notifier).state = v;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Gidiş-Dönüş ve Kişi Sayısı
          Row(
            children: [
              // Gidiş-dönüş toggle
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final gidisDonus = ref.watch(_gidisDonusProvider);
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          ref.read(_gidisDonusProvider.notifier).state =
                              !gidisDonus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gidisDonus
                                ? AppColors.primaryLight
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                          color: gidisDonus
                              ? AppColors.primaryLight.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: gidisDonus
                                  ? AppColors.primaryLight
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              gidisDonus ? l.gidisDonusu : 'Tek Yön',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: gidisDonus
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: gidisDonus
                                    ? AppColors.primaryLight
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Kişi sayısı
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final kisi = ref.watch(_kisiSayisiProvider);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$kisi ${l.kisi}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: kisi > 1
                                  ? () =>
                                        ref
                                                .read(
                                                  _kisiSayisiProvider.notifier,
                                                )
                                                .state =
                                            kisi - 1
                                  : null,
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: kisi < 8
                                  ? () =>
                                        ref
                                                .read(
                                                  _kisiSayisiProvider.notifier,
                                                )
                                                .state =
                                            kisi + 1
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // --- Rota Seçimi ---
          Text(l.rotaSecimi, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Başlangıç butonu
          _RotaNoktaButon(
            label: _baslangicLabel.isEmpty
                ? l.baslangicNoktasi
                : _baslangicLabel,
            icon: Icons.trip_origin,
            color: AppColors.indirimYesil,
            isActive: _haritaModu == _HaritaModu.baslangicSec,
            onTapHarita: () {
              setState(() {
                _haritaModu = _haritaModu == _HaritaModu.baslangicSec
                    ? _HaritaModu.yok
                    : _HaritaModu.baslangicSec;
              });
            },
            onTapListe: () => _selectCity('baslangic'),
          ),

          // Ara noktalar listesi
          ...araNoktalar.asMap().entries.map((entry) {
            final i = entry.key;
            final nokta = entry.value;
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                  ),
                  color: Colors.orange.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.more_vert, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '${l.araNokta} ${i + 1}: ${nokta.label}',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        ref.read(araNoktalarProvider.notifier).kaldir(i);
                        _updateMarkers();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Ara nokta ekleme butonu (max 5)
          if (baslangic != null && araNoktalar.length < 5)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _haritaModu = _haritaModu == _HaritaModu.araNoktaSec
                              ? _HaritaModu.yok
                              : _HaritaModu.araNoktaSec;
                        });
                      },
                      icon: Icon(
                        _haritaModu == _HaritaModu.araNoktaSec
                            ? Icons.touch_app
                            : Icons.add_location_alt,
                        size: 16,
                        color: Colors.orange,
                      ),
                      label: Text(
                        _haritaModu == _HaritaModu.araNoktaSec
                            ? l.haritayaDokunun
                            : l.araNoktaEkleHarita,
                        style: TextStyle(
                          fontSize: 12,
                          color: _haritaModu == _HaritaModu.araNoktaSec
                              ? Colors.orange
                              : null,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _haritaModu == _HaritaModu.araNoktaSec
                              ? Colors.orange
                              : Colors.grey.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: OutlinedButton(
                      onPressed: () => _selectCity('ara'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(Icons.list, size: 18),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Varış butonu
          _RotaNoktaButon(
            label: _varisLabel.isEmpty ? l.varisNoktasi : _varisLabel,
            icon: Icons.location_on,
            color: AppColors.zamKirmizi,
            isActive: _haritaModu == _HaritaModu.varisSec,
            onTapHarita: () {
              setState(() {
                _haritaModu = _haritaModu == _HaritaModu.varisSec
                    ? _HaritaModu.yok
                    : _HaritaModu.varisSec;
              });
            },
            onTapListe: () => _selectCity('varis'),
          ),

          const SizedBox(height: 8),

          // Aktif mod göstergesi
          if (_haritaModu != _HaritaModu.yok || _reverseLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _modColor(_haritaModu).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (_reverseLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.touch_app,
                      size: 18,
                      color: _modColor(_haritaModu),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _reverseLoading
                          ? l.konumBelirleniyor
                          : _modText(_haritaModu, l),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Harita — tamamen izole widget
          _IzoleHarita(
            markers: _markers,
            routePoints: _routePoints,
            haritaModu: _haritaModu,
            modColor: _modColor(_haritaModu),
            onTap: _onMapTap,
          ),
          const SizedBox(height: 8),

          // Temizle butonu
          if (baslangic != null || varis != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _temizle,
                icon: const Icon(Icons.clear, size: 16),
                label: Text(l.temizle),
              ),
            ),
          const Divider(height: 24),

          // --- Sonuçlar ---
          if (rota.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          if (rota.hasError)
            Card(
              color: AppColors.zamKirmizi.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${l.rotaHesaplanamadi}: ${rota.error}',
                  style: const TextStyle(color: AppColors.zamKirmizi),
                ),
              ),
            ),
          if (rota.valueOrNull != null)
            _SonucKartlari(
              rota: rota.valueOrNull!,
              ilKodu: seciliIl,
              yakitTipi: yakitTipi,
            ),
        ],
      ),
    );
  }
}

// ─── Harita modu enum ──────────────────────────────────────────
enum _HaritaModu { yok, baslangicSec, varisSec, araNoktaSec }

// ─── Marker veri modeli (haritaya geçmek için) ─────────────────
enum _MarkerType { baslangic, ara, varis }

class _MarkerData {
  final LatLng point;
  final _MarkerType type;
  final int index;
  const _MarkerData({required this.point, required this.type, this.index = 0});
}

// ─── İzole Harita Widget — kendi MapController'ı var ───────────
// Bu widget provider'lardan bağımsız, sadece data alır.
// Bu sayede provider değişiklikleri FlutterMap'i yeniden oluşturmaz.
class _IzoleHarita extends StatefulWidget {
  final List<_MarkerData> markers;
  final List<LatLng> routePoints;
  final _HaritaModu haritaModu;
  final Color modColor;
  final void Function(LatLng) onTap;

  const _IzoleHarita({
    required this.markers,
    required this.routePoints,
    required this.haritaModu,
    required this.modColor,
    required this.onTap,
  });

  @override
  State<_IzoleHarita> createState() => _IzoleHaritaState();
}

class _IzoleHaritaState extends State<_IzoleHarita> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(39.9334, 32.8597),
                initialZoom: 6,
                onTap: (_, point) {
                  // Callback'i async çağır — FlutterMap tap cycle dışına çık
                  Future.microtask(() => widget.onTap(point));
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.iscgames.fueltr',
                ),
                MarkerLayer(
                  markers: widget.markers.map((m) {
                    switch (m.type) {
                      case _MarkerType.baslangic:
                        return Marker(
                          point: m.point,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.trip_origin,
                            color: AppColors.indirimYesil,
                            size: 32,
                          ),
                        );
                      case _MarkerType.ara:
                        return Marker(
                          point: m.point,
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${m.index}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      case _MarkerType.varis:
                        return Marker(
                          point: m.point,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.zamKirmizi,
                            size: 32,
                          ),
                        );
                    }
                  }).toList(),
                ),
                if (widget.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePoints,
                        color: AppColors.primaryLight,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
            // Harita üstü border (aktif mod)
            if (widget.haritaModu != _HaritaModu.yok)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.modColor, width: 3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Rota Nokta Butonu ─────────────────────────────────────────
class _RotaNoktaButon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTapHarita;
  final VoidCallback onTapListe;

  const _RotaNoktaButon({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTapHarita,
    required this.onTapListe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTapHarita,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: label.contains('seç')
                              ? Colors.grey[500]
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) Icon(Icons.touch_app, size: 16, color: color),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          InkWell(
            onTap: onTapListe,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              child: Icon(Icons.list, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Şehir Seçim BottomSheet ───────────────────────────────────
class _SehirSecSheet extends StatefulWidget {
  final bool isBaslangic;
  final void Function(String ad, LatLng konum) onSelected;

  const _SehirSecSheet({required this.isBaslangic, required this.onSelected});

  @override
  State<_SehirSecSheet> createState() => _SehirSecSheetState();
}

class _SehirSecSheetState extends State<_SehirSecSheet> {
  String _filter = '';

  List<Map<String, String>> get _filteredCities {
    if (_filter.isEmpty) return OsrmDatasource.turkiyeIlleri;
    final q = _filter
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g');
    return OsrmDatasource.turkiyeIlleri.where((il) {
      final name = il['ad']!
          .toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ö', 'o')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ç', 'c')
          .replaceAll('ğ', 'g');
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cities = _filteredCities;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.sehirAra,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: widget.isBaslangic
                        ? AppColors.indirimYesil
                        : AppColors.zamKirmizi,
                  ),
                  title: Text(city['ad']!),
                  onTap: () {
                    widget.onSelected(
                      city['ad']!,
                      LatLng(
                        double.parse(city['lat']!),
                        double.parse(city['lon']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sonuç Kartları ────────────────────────────────────────────
class _SonucKartlari extends ConsumerWidget {
  final RotaSonuc rota;
  final String ilKodu;
  final String yakitTipi;

  const _SonucKartlari({
    required this.rota,
    required this.ilKodu,
    required this.yakitTipi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final ilOzet = ref.watch(
      ilOzetProvider((ilKodu: ilKodu, ilAdi: IlKodlari.getIlAdi(ilKodu))),
    );
    final tuketim = ref.watch(tuketimProvider);
    final depo = ref.watch(depoKapasitesiProvider);
    final gidisDonus = ref.watch(_gidisDonusProvider);
    final kisiSayisi = ref.watch(_kisiSayisiProvider);

    return ilOzet.when(
      data: (ozet) {
        double fiyat;
        String tipLabel;
        switch (yakitTipi) {
          case 'motorin':
            fiyat = ozet.motorin;
            tipLabel = l.motorin;
          case 'lpg':
            fiyat = ozet.lpg ?? 0;
            tipLabel = l.lpg;
          default:
            fiyat = ozet.benzin95;
            tipLabel = l.benzin;
        }

        if (fiyat == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$tipLabel ${l.fiyatVerisiBulunamadi}'),
            ),
          );
        }

        final sonuc = HesaplamaSonuc(
          mesafeKm: rota.mesafeKm,
          sureText: rota.sureText,
          yakitFiyati: fiyat,
          yakitTipi: tipLabel,
          tuketim: tuketim,
          depoKapasitesi: depo,
        );

        final toplamMaliyet = gidisDonus
            ? sonuc.gidisDonusMaliyet
            : sonuc.toplamMaliyet;
        final toplamYakit = gidisDonus
            ? sonuc.gidisDonusYakit
            : sonuc.toplamTuketim;
        final toplamMesafe = gidisDonus ? sonuc.mesafeKm * 2 : sonuc.mesafeKm;

        return Column(
          children: [
            // Başlık + Paylaş
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.hesaplamaSonucu,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  tooltip: l.paylas,
                  onPressed: () async {
                    final text =
                        'YakitCep Hesaplama\n'
                        '---------------\n'
                        '${l.mesafe}: ${toplamMesafe.toStringAsFixed(0)} km ${gidisDonus ? "(Gidis-Donus)" : ""}\n'
                        '${l.sure}: ${sonuc.sureText}\n'
                        '$tipLabel: ${fiyat.toStringAsFixed(2)} TL/L\n'
                        '${l.tuketimLabel}: ${tuketim.toStringAsFixed(1)} L/100km\n'
                        '---------------\n'
                        '${l.toplamMaliyet}: ${toplamMaliyet.toStringAsFixed(0)} TL\n'
                        '${kisiSayisi > 1 ? "Kisi basi: ${sonuc.kisiBasiMaliyet(kisiSayisi).toStringAsFixed(0)} TL ($kisiSayisi kisi)\n" : ""}'
                        '${l.toplamYakit}: ${toplamYakit.toStringAsFixed(1)} L';
                    try {
                      await SharePlus.instance.share(ShareParams(text: text));
                    } catch (_) {
                      // Paylaşım iptal veya hata — sessizce devam et
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ana maliyet kartı
            Card(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${toplamMaliyet.toStringAsFixed(0)} ₺',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                    ),
                    Text(
                      gidisDonus
                          ? l.gidisDonusuToplamMaliyet
                          : l.toplamYakitMaliyeti,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if (kisiSayisi > 1) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${l.kisiBasiMaliyet}: ${(toplamMaliyet / kisiSayisi).toStringAsFixed(0)} ₺ ($kisiSayisi ${l.kisi})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Metrik kartları
            Row(
              children: [
                Expanded(
                  child: _miniKart(
                    context,
                    l.mesafe,
                    '${toplamMesafe.toStringAsFixed(0)} km',
                    Icons.straighten,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniKart(
                    context,
                    l.sure,
                    sonuc.sureText,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _miniKart(
                    context,
                    '$tipLabel ${l.fiyat}',
                    '${fiyat.toStringAsFixed(2)} ₺/L',
                    Icons.local_gas_station,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniKart(
                    context,
                    l.harcamaKm,
                    '${sonuc.kmBasinaMaliyet.toStringAsFixed(2)} ₺',
                    Icons.speed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _miniKart(
                    context,
                    l.toplamYakit,
                    '${toplamYakit.toStringAsFixed(1)} L',
                    Icons.water_drop,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniKart(
                    context,
                    l.depoSayisi,
                    '${sonuc.gerekliDepo.toStringAsFixed(1)} ${l.depoLabel}',
                    Icons.battery_full,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _miniKart(
                    context,
                    l.depoMenzili,
                    '${sonuc.depoIleKm.toStringAsFixed(0)} km',
                    Icons.battery_charging_full,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniKart(
                    context,
                    l.yuzKmMaliyet,
                    '${(sonuc.kmBasinaMaliyet * 100).toStringAsFixed(0)} ₺',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tasarruf ipucu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 18, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tasarrufIpucu(sonuc, l),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('${l.fiyatBilgisiAlinamadi}: $e'),
    );
  }

  String _tasarrufIpucu(HesaplamaSonuc sonuc, AppLocalizations l) {
    if (sonuc.tuketim > 8) {
      return '💡 ${l.tasarrufYuksekTuketim}';
    }
    if (sonuc.mesafeKm > 500) {
      return '💡 ${l.tasarrufUzunYol}';
    }
    if (sonuc.gerekliDepo > 1.5) {
      return '💡 ${l.tasarrufSehirDisi}';
    }
    return '💡 ${l.tasarrufKlima}';
  }

  Widget _miniKart(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Araç listesi için ortak model (kayıtlı + preset)
class _AracItem {
  final String ad;
  final double tuketim;
  final double depo;
  final String yakitTipi;
  final bool isKayitli;

  const _AracItem({
    required this.ad,
    required this.tuketim,
    required this.depo,
    required this.yakitTipi,
    required this.isKayitli,
  });
}
