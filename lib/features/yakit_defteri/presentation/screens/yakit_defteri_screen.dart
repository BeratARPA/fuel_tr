import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/yakit_kayit.dart';
import '../providers/yakit_defteri_provider.dart';
import 'aylik_rapor_screen.dart';
import 'yakit_kayit_ekle_screen.dart';

class YakitDefteriScreen extends ConsumerWidget {
  const YakitDefteriScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final kayitlar = ref.watch(yakitDefteriProvider);
    final istatistik = ref.watch(yakitIstatistikProvider);
    final buAy = ref.watch(buAyIstatistikProvider);
    final gecenAy = ref.watch(gecenAyIstatistikProvider);
    final aylikHarcamalar = ref.watch(aylikHarcamaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.yakitDefteri),
        actions: [
          if (kayitlar.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: l.aylikRapor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AylikRaporScreen()),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const YakitKayitEkleScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(l.yeniKayit),
      ),
      body: kayitlar.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    l.henuzKayitYok,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.ilkYakitAlimi,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // İstatistik kartları
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatKart(
                          baslik: l.buAy,
                          deger: '${buAy.toplamHarcama.toStringAsFixed(0)}₺',
                          altBaslik: '${buAy.kayitSayisi} ${l.kayit}',
                          renk: AppColors.primaryLight,
                          degisim: gecenAy.toplamHarcama > 0
                              ? ((buAy.toplamHarcama - gecenAy.toplamHarcama) /
                                    gecenAy.toplamHarcama *
                                    100)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatKart(
                          baslik: l.toplam,
                          deger:
                              '${istatistik.toplamHarcama.toStringAsFixed(0)}₺',
                          altBaslik:
                              '${istatistik.toplamLitre.toStringAsFixed(0)}L',
                          renk: AppColors.benzinTuruncu,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatKart(
                          baslik: l.tuketimLabel,
                          deger: istatistik.ortalamaKmTuketim != null
                              ? istatistik.ortalamaKmTuketim!.toStringAsFixed(1)
                              : '-',
                          altBaslik: 'L/100km',
                          renk: AppColors.motorinMavi,
                        ),
                      ),
                    ],
                  ),
                ),

                // Aylık harcama grafiği
                if (aylikHarcamalar.any((a) => a.toplam > 0))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.aylikHarcama,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 150,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY:
                                      aylikHarcamalar
                                          .map((a) => a.toplam)
                                          .where((t) => t > 0)
                                          .fold(0.0, (a, b) => a > b ? a : b) *
                                      1.2,
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, gi, rod, ri) {
                                        return BarTooltipItem(
                                          '${rod.toY.toStringAsFixed(0)}₺',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, meta) {
                                          final idx = v.toInt();
                                          if (idx >= aylikHarcamalar.length) {
                                            return const SizedBox();
                                          }
                                          final ay = aylikHarcamalar[idx].ay;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              DateFormat(
                                                'MMM',
                                                'tr',
                                              ).format(ay),
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: aylikHarcamalar
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => BarChartGroupData(
                                          x: e.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: e.value.toplam,
                                              color:
                                                  e.key ==
                                                      aylikHarcamalar.length - 1
                                                  ? AppColors.primaryLight
                                                  : AppColors.primaryLight
                                                        .withValues(alpha: 0.4),
                                              width: 20,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(4),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Kayıt listesi başlığı
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    '${l.sonKayitlar} (${kayitlar.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),

                // Kayıt listesi
                ...kayitlar.map((k) => _KayitTile(kayit: k)),
              ],
            ),
    );
  }
}

// ─── İstatistik Kartı ──────────────────────────────────────
class _StatKart extends StatelessWidget {
  final String baslik;
  final String deger;
  final String altBaslik;
  final Color renk;
  final double? degisim;

  const _StatKart({
    required this.baslik,
    required this.deger,
    required this.altBaslik,
    required this.renk,
    this.degisim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: renk.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(baslik, style: TextStyle(fontSize: 10, color: renk)),
          const SizedBox(height: 2),
          Text(
            deger,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
          Text(altBaslik, style: TextStyle(fontSize: 10, color: renk)),
          if (degisim != null) ...[
            const SizedBox(height: 2),
            Text(
              '${degisim! > 0 ? "+" : ""}${degisim!.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: degisim! > 0
                    ? AppColors.zamKirmizi
                    : AppColors.indirimYesil,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Kayıt Tile ────────────────────────────────────────────
class _KayitTile extends ConsumerWidget {
  final YakitKayit kayit;
  const _KayitTile({required this.kayit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final dateStr = DateFormat('dd MMM yyyy', 'tr').format(kayit.tarih);
    final tipRenk = kayit.yakitTipi == 'benzin'
        ? AppColors.benzinTuruncu
        : kayit.yakitTipi == 'motorin'
        ? AppColors.motorinMavi
        : AppColors.lpgMor;

    return Dismissible(
      key: Key(kayit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.zamKirmizi,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.kayitSil),
            content: Text(l.kayitSilOnay),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.iptal),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.sil),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(yakitDefteriProvider.notifier).sil(kayit.id);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tipRenk.withValues(alpha: 0.15),
          child: Icon(Icons.local_gas_station, color: tipRenk, size: 20),
        ),
        title: Text(
          '${kayit.litre.toStringAsFixed(1)}L — ${kayit.tutar.toStringAsFixed(0)}₺',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Text(
              dateStr,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              '${kayit.litreFiyat.toStringAsFixed(2)}₺/L',
              style: TextStyle(fontSize: 12, color: tipRenk),
            ),
            if (kayit.kmSayaci != null) ...[
              const SizedBox(width: 8),
              Text(
                '${kayit.kmSayaci!.toStringAsFixed(0)} km',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        trailing: kayit.not != null && kayit.not!.isNotEmpty
            ? Icon(Icons.note, size: 16, color: Colors.grey[400])
            : null,
      ),
    );
  }
}
