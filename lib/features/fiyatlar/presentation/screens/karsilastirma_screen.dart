import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/fiyat_provider.dart';
import '../../domain/entities/il_fiyat_ozet.dart';

final _karsilastirmaIlleriProvider = StateProvider<List<String>>((ref) => []);

// Hangi yakıt tipini karşılaştırıyoruz
enum _YakitSec { benzin, motorin, lpg }

final _yakitSecProvider = StateProvider<_YakitSec>((ref) => _YakitSec.benzin);

// Sıralama
enum _Siralama { varsayilan, enUcuz, enPahali }

final _siralamaProvider = StateProvider<_Siralama>(
  (ref) => _Siralama.varsayilan,
);

class KarsilastirmaScreen extends ConsumerWidget {
  const KarsilastirmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final seciliIller = ref.watch(_karsilastirmaIlleriProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.karsilastir),
        actions: [
          if (seciliIller.length >= 2)
            PopupMenuButton<_Siralama>(
              icon: const Icon(Icons.sort),
              tooltip: l.siralama,
              onSelected: (v) => ref.read(_siralamaProvider.notifier).state = v,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _Siralama.varsayilan,
                  child: Text(l.secimSirasina),
                ),
                PopupMenuItem(
                  value: _Siralama.enUcuz,
                  child: Text(l.enUcuzdan),
                ),
                PopupMenuItem(
                  value: _Siralama.enPahali,
                  child: Text(l.enPahalidan),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // İl ekleme satırı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'İl seçin (${seciliIller.length}/${AppConstants.maxKarsilastirmaIl})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (seciliIller.length < AppConstants.maxKarsilastirmaIl)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: l.ilEkle,
                    onPressed: () => _showIlSecDialog(context, ref),
                  ),
                if (seciliIller.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: l.temizle,
                    onPressed: () =>
                        ref.read(_karsilastirmaIlleriProvider.notifier).state =
                            [],
                  ),
              ],
            ),
          ),

          // Seçili iller chip'leri
          if (seciliIller.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: seciliIller.map((ilKodu) {
                  return Chip(
                    label: Text(IlKodlari.getIlAdi(ilKodu)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      ref.read(_karsilastirmaIlleriProvider.notifier).state =
                          seciliIller.where((k) => k != ilKodu).toList();
                    },
                  );
                }).toList(),
              ),
            ),

          // İçerik
          if (seciliIller.length >= 2) ...[
            const Divider(height: 16),
            Expanded(child: _KarsilastirmaIcerik(iller: seciliIller)),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(l.enAz2Il, style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    // Hızlı seçim önerileri
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _HizliSecButon(
                          label: l.istanbulVsAnkara,
                          onTap: () =>
                              ref
                                  .read(_karsilastirmaIlleriProvider.notifier)
                                  .state = [
                                '34',
                                '06',
                              ],
                        ),
                        _HizliSecButon(
                          label: l.ucBuyukSehir,
                          onTap: () =>
                              ref
                                  .read(_karsilastirmaIlleriProvider.notifier)
                                  .state = [
                                '34',
                                '06',
                                '35',
                              ],
                        ),
                        _HizliSecButon(
                          label: l.dortBuyukSehir,
                          onTap: () =>
                              ref
                                  .read(_karsilastirmaIlleriProvider.notifier)
                                  .state = [
                                '34',
                                '06',
                                '35',
                                '16',
                              ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showIlSecDialog(BuildContext context, WidgetRef ref) {
    final secili = ref.read(_karsilastirmaIlleriProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _IlSecSheet(
        seciliIller: secili,
        onSelected: (ilKodu) {
          ref.read(_karsilastirmaIlleriProvider.notifier).state = [
            ...secili,
            ilKodu,
          ];
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ─── Hızlı Seçim Butonu ────────────────────────────────────
class _HizliSecButon extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HizliSecButon({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}

// ─── İl Seçim Sheet (Aramalı) ──────────────────────────────
class _IlSecSheet extends StatefulWidget {
  final List<String> seciliIller;
  final void Function(String ilKodu) onSelected;
  const _IlSecSheet({required this.seciliIller, required this.onSelected});

  @override
  State<_IlSecSheet> createState() => _IlSecSheetState();
}

class _IlSecSheetState extends State<_IlSecSheet> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final iller = IlKodlari.sortedByName
        .where((il) => !widget.seciliIller.contains(il.key))
        .where((il) {
          if (_filter.isEmpty) return true;
          final q = _filter
              .toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ö', 'o')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ç', 'c')
              .replaceAll('ğ', 'g');
          final name = il.value
              .toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ö', 'o')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ç', 'c')
              .replaceAll('ğ', 'g');
          return name.contains(q);
        })
        .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
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
                hintText: l.ilAra,
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
              itemCount: iller.length,
              itemBuilder: (context, index) {
                final il = iller[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text(il.key, style: const TextStyle(fontSize: 11)),
                  ),
                  title: Text(il.value),
                  onTap: () => widget.onSelected(il.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ana İçerik ────────────────────────────────────────────
class _KarsilastirmaIcerik extends ConsumerWidget {
  final List<String> iller;
  const _KarsilastirmaIcerik({required this.iller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final yakitSec = ref.watch(_yakitSecProvider);
    final siralama = ref.watch(_siralamaProvider);

    // Tüm il verilerini topla
    final ozetler = <String, AsyncValue<IlFiyatOzet>>{};
    for (final ilKodu in iller) {
      final ilAdi = IlKodlari.getIlAdi(ilKodu);
      ozetler[ilKodu] = ref.watch(
        ilOzetProvider((ilKodu: ilKodu, ilAdi: ilAdi)),
      );
    }

    final anyLoading = ozetler.values.any((v) => v.isLoading);
    if (anyLoading) return const LoadingShimmer(itemCount: 3);

    final loaded = <String, IlFiyatOzet>{};
    for (final entry in ozetler.entries) {
      entry.value.whenData((data) => loaded[entry.key] = data);
    }

    if (loaded.length < 2) {
      return Center(child: Text(l.verilerYuklenemedi));
    }

    // En ucuz hesapla
    final benzinEntries = loaded.entries
        .where((e) => e.value.benzin95 > 0)
        .toList();
    final motorinEntries = loaded.entries
        .where((e) => e.value.motorin > 0)
        .toList();
    final lpgEntries = loaded.entries
        .where((e) => e.value.lpg != null && e.value.lpg! > 0)
        .toList();

    final enUcuzBenzin = benzinEntries.isNotEmpty
        ? benzinEntries.reduce(
            (a, b) => a.value.benzin95 < b.value.benzin95 ? a : b,
          )
        : null;
    final enUcuzMotorin = motorinEntries.isNotEmpty
        ? motorinEntries.reduce(
            (a, b) => a.value.motorin < b.value.motorin ? a : b,
          )
        : null;
    final enUcuzLpg = lpgEntries.isNotEmpty
        ? lpgEntries.reduce((a, b) => a.value.lpg! < b.value.lpg! ? a : b)
        : null;

    // Sıralama
    var siraliEntries = loaded.entries.toList();
    if (siralama == _Siralama.enUcuz || siralama == _Siralama.enPahali) {
      siraliEntries.sort((a, b) {
        double fa, fb;
        switch (yakitSec) {
          case _YakitSec.benzin:
            fa = a.value.benzin95;
            fb = b.value.benzin95;
          case _YakitSec.motorin:
            fa = a.value.motorin;
            fb = b.value.motorin;
          case _YakitSec.lpg:
            fa = a.value.lpg ?? 999;
            fb = b.value.lpg ?? 999;
        }
        return siralama == _Siralama.enUcuz
            ? fa.compareTo(fb)
            : fb.compareTo(fa);
      });
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // En Ucuz kartları
        _EnUcuzKartlari(
          enUcuzBenzin: enUcuzBenzin,
          enUcuzMotorin: enUcuzMotorin,
          enUcuzLpg: enUcuzLpg,
        ),
        const SizedBox(height: 12),

        // Yakıt tipi seçici
        SegmentedButton<_YakitSec>(
          segments: [
            ButtonSegment(value: _YakitSec.benzin, label: Text(l.benzin)),
            ButtonSegment(value: _YakitSec.motorin, label: Text(l.motorin)),
            ButtonSegment(value: _YakitSec.lpg, label: Text(l.lpg)),
          ],
          selected: {yakitSec},
          onSelectionChanged: (s) =>
              ref.read(_yakitSecProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 12),

        // Bar chart
        _BarChartKarsilastirma(
          entries: siraliEntries,
          yakitSec: yakitSec,
          enUcuzKey: yakitSec == _YakitSec.benzin
              ? enUcuzBenzin?.key
              : yakitSec == _YakitSec.motorin
              ? enUcuzMotorin?.key
              : enUcuzLpg?.key,
        ),
        const SizedBox(height: 16),

        // Fark analizi
        if (siraliEntries.length >= 2)
          _FarkAnaliziKarti(entries: siraliEntries, yakitSec: yakitSec),
        const SizedBox(height: 16),

        // Detay tablosu
        _DetayTablosu(
          entries: siraliEntries,
          enUcuzBenzinKey: enUcuzBenzin?.key,
          enUcuzMotorinKey: enUcuzMotorin?.key,
          enUcuzLpgKey: enUcuzLpg?.key,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── En Ucuz Kartları ──────────────────────────────────────
class _EnUcuzKartlari extends StatelessWidget {
  final MapEntry<String, IlFiyatOzet>? enUcuzBenzin;
  final MapEntry<String, IlFiyatOzet>? enUcuzMotorin;
  final MapEntry<String, IlFiyatOzet>? enUcuzLpg;

  const _EnUcuzKartlari({
    this.enUcuzBenzin,
    this.enUcuzMotorin,
    this.enUcuzLpg,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        if (enUcuzBenzin != null)
          Expanded(
            child: _MiniEnUcuzKart(
              yakitTipi: l.benzin,
              ilAdi: enUcuzBenzin!.value.ilAdi,
              fiyat: enUcuzBenzin!.value.benzin95,
              renk: AppColors.benzinTuruncu,
            ),
          ),
        if (enUcuzBenzin != null && enUcuzMotorin != null)
          const SizedBox(width: 6),
        if (enUcuzMotorin != null)
          Expanded(
            child: _MiniEnUcuzKart(
              yakitTipi: l.motorin,
              ilAdi: enUcuzMotorin!.value.ilAdi,
              fiyat: enUcuzMotorin!.value.motorin,
              renk: AppColors.motorinMavi,
            ),
          ),
        if (enUcuzLpg != null &&
            (enUcuzMotorin != null || enUcuzBenzin != null))
          const SizedBox(width: 6),
        if (enUcuzLpg != null)
          Expanded(
            child: _MiniEnUcuzKart(
              yakitTipi: l.lpg,
              ilAdi: enUcuzLpg!.value.ilAdi,
              fiyat: enUcuzLpg!.value.lpg!,
              renk: AppColors.lpgMor,
            ),
          ),
      ],
    );
  }
}

class _MiniEnUcuzKart extends StatelessWidget {
  final String yakitTipi;
  final String ilAdi;
  final double fiyat;
  final Color renk;

  const _MiniEnUcuzKart({
    required this.yakitTipi,
    required this.ilAdi,
    required this.fiyat,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: renk.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 16, color: renk),
          const SizedBox(height: 2),
          Text(
            yakitTipi,
            style: TextStyle(
              fontSize: 10,
              color: renk,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${fiyat.toStringAsFixed(2)}₺',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
          Text(
            ilAdi,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Bar Chart ─────────────────────────────────────────────
class _BarChartKarsilastirma extends StatelessWidget {
  final List<MapEntry<String, IlFiyatOzet>> entries;
  final _YakitSec yakitSec;
  final String? enUcuzKey;

  const _BarChartKarsilastirma({
    required this.entries,
    required this.yakitSec,
    this.enUcuzKey,
  });

  double _fiyat(IlFiyatOzet o) {
    switch (yakitSec) {
      case _YakitSec.benzin:
        return o.benzin95;
      case _YakitSec.motorin:
        return o.motorin;
      case _YakitSec.lpg:
        return o.lpg ?? 0;
    }
  }

  Color _renk() {
    switch (yakitSec) {
      case _YakitSec.benzin:
        return AppColors.benzinTuruncu;
      case _YakitSec.motorin:
        return AppColors.motorinMavi;
      case _YakitSec.lpg:
        return AppColors.lpgMor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final validEntries = entries.where((e) => _fiyat(e.value) > 0).toList();
    if (validEntries.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(child: Text(l.buYakitIcinVeriYok)),
      );
    }

    final maxFiyat = validEntries
        .map((e) => _fiyat(e.value))
        .reduce((a, b) => a > b ? a : b);
    final minFiyat = validEntries
        .map((e) => _fiyat(e.value))
        .reduce((a, b) => a < b ? a : b);
    final range = maxFiyat - minFiyat;
    final chartMin = range > 0
        ? (minFiyat - range * 0.5).clamp(0.0, double.infinity)
        : (minFiyat * 0.95);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxFiyat * 1.05,
          minY: chartMin,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = validEntries[group.x.toInt()];
                return BarTooltipItem(
                  '${entry.value.ilAdi}\n${_fiyat(entry.value).toStringAsFixed(2)}₺',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (v, meta) => Text(
                  '${v.toStringAsFixed(0)}₺',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final idx = v.toInt();
                  if (idx >= validEntries.length) return const SizedBox();
                  final name = validEntries[idx].value.ilAdi;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      name.length > 7 ? '${name.substring(0, 7)}.' : name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            horizontalInterval: range > 0 ? range / 3 : 1,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: validEntries.asMap().entries.map((entry) {
            final isEnUcuz = entry.value.key == enUcuzKey;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: _fiyat(entry.value.value),
                  fromY: chartMin,
                  color: isEnUcuz ? AppColors.indirimYesil : _renk(),
                  width: validEntries.length <= 2 ? 40 : 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Fark Analizi Kartı ────────────────────────────────────
class _FarkAnaliziKarti extends StatelessWidget {
  final List<MapEntry<String, IlFiyatOzet>> entries;
  final _YakitSec yakitSec;

  const _FarkAnaliziKarti({required this.entries, required this.yakitSec});

  double _fiyat(IlFiyatOzet o) {
    switch (yakitSec) {
      case _YakitSec.benzin:
        return o.benzin95;
      case _YakitSec.motorin:
        return o.motorin;
      case _YakitSec.lpg:
        return o.lpg ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final valid = entries.where((e) => _fiyat(e.value) > 0).toList();
    if (valid.length < 2) return const SizedBox.shrink();

    final fiyatlar = valid.map((e) => _fiyat(e.value)).toList();
    final min = fiyatlar.reduce((a, b) => a < b ? a : b);
    final max = fiyatlar.reduce((a, b) => a > b ? a : b);
    final fark = max - min;
    final farkYuzde = min > 0 ? (fark / min * 100) : 0.0;
    final tasarruf50L = fark * 50;

    final yakitStr = yakitSec == _YakitSec.benzin
        ? l.benzin
        : yakitSec == _YakitSec.motorin
        ? l.motorin
        : l.lpg;

    return Card(
      color: Colors.blue.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  '$yakitStr ${l.farkAnalizi}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AnalizItem(
                    label: l.fiyatFarki,
                    value: '${fark.toStringAsFixed(2)}₺/L',
                    icon: Icons.swap_vert,
                  ),
                ),
                Expanded(
                  child: _AnalizItem(
                    label: l.yuzdeFark,
                    value: '%${farkYuzde.toStringAsFixed(1)}',
                    icon: Icons.percent,
                  ),
                ),
                Expanded(
                  child: _AnalizItem(
                    label: l.tasarruf50L,
                    value: '${tasarruf50L.toStringAsFixed(0)}₺',
                    icon: Icons.savings,
                    color: AppColors.indirimYesil,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalizItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _AnalizItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

// ─── Detay Tablosu ─────────────────────────────────────────
class _DetayTablosu extends StatelessWidget {
  final List<MapEntry<String, IlFiyatOzet>> entries;
  final String? enUcuzBenzinKey;
  final String? enUcuzMotorinKey;
  final String? enUcuzLpgKey;

  const _DetayTablosu({
    required this.entries,
    this.enUcuzBenzinKey,
    this.enUcuzMotorinKey,
    this.enUcuzLpgKey,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Table(
      border: TableBorder.all(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          children: [
            _cell(l.il, isHeader: true),
            _cell(l.benzin, isHeader: true, color: AppColors.benzinTuruncu),
            _cell(l.motorin, isHeader: true, color: AppColors.motorinMavi),
            _cell(l.lpg, isHeader: true, color: AppColors.lpgMor),
          ],
        ),
        ...entries.map((e) {
          final o = e.value;
          return TableRow(
            children: [
              _cell(o.ilAdi),
              _cell(
                o.benzin95 > 0 ? '${o.benzin95.toStringAsFixed(2)}₺' : '-',
                highlight: e.key == enUcuzBenzinKey,
              ),
              _cell(
                o.motorin > 0 ? '${o.motorin.toStringAsFixed(2)}₺' : '-',
                highlight: e.key == enUcuzMotorinKey,
              ),
              _cell(
                o.lpg != null ? '${o.lpg!.toStringAsFixed(2)}₺' : '-',
                highlight: e.key == enUcuzLpgKey,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _cell(
    String text, {
    bool isHeader = false,
    bool highlight = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader || highlight
              ? FontWeight.bold
              : FontWeight.normal,
          fontSize: 12,
          color: highlight ? AppColors.indirimYesil : color,
        ),
      ),
    );
  }
}
