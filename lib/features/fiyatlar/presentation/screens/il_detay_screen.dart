import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/yakit_fiyat_karti.dart';
import '../../domain/usecases/fiyat_tahmin.dart';
import '../widgets/tahmin_karti.dart';
import 'otv_hesaplayici_screen.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../favoriler/presentation/providers/favori_provider.dart';
import '../providers/fiyat_provider.dart';

class IlDetayScreen extends ConsumerWidget {
  final String ilKodu;
  final String ilAdi;

  const IlDetayScreen({super.key, required this.ilKodu, required this.ilAdi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final favoriler = ref.watch(favoriProvider);
    final isFavori = favoriler.contains(ilKodu);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(ilAdi),
          actions: [
            IconButton(
              icon: Icon(
                isFavori ? Icons.favorite : Icons.favorite_border,
                color: isFavori ? AppColors.zamKirmizi : null,
              ),
              onPressed: () {
                if (isFavori) {
                  ref.read(favoriProvider.notifier).removeFavori(ilKodu);
                } else {
                  final added = ref
                      .read(favoriProvider.notifier)
                      .addFavori(ilKodu);
                  if (!added && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.maxFavoriUyari)));
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              tooltip: l.paylas,
              onPressed: () {
                final fiyatlar = ref.read(ilFiyatlariProvider(ilKodu));
                fiyatlar.whenData((list) async {
                  final ll = AppLocalizations.of(context)!;
                  final lines = <String>[
                    '${ll.appTitle} - $ilAdi ${ll.fiyatlar}',
                    '---------------',
                  ];
                  for (final f in list) {
                    lines.add(
                      '${f.yakitTipi}: ${f.fiyat.toStringAsFixed(2)} TL',
                    );
                  }
                  lines.add('---------------');
                  try {
                    await SharePlus.instance.share(
                      ShareParams(text: lines.join('\n')),
                    );
                  } catch (_) {}
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(ilFiyatlariProvider(ilKodu));
                ref.invalidate(markaFiyatlariProvider(ilAdi));
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.fiyatlar_tab),
              Tab(text: l.markalar_tab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Fiyatlar
            _FiyatlarTab(ilKodu: ilKodu),
            // Tab 2: Markalar
            _MarkalarTab(ilAdi: ilAdi),
          ],
        ),
      ),
    );
  }
}

class _FiyatlarTab extends ConsumerWidget {
  final String ilKodu;
  const _FiyatlarTab({required this.ilKodu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final fiyatlar = ref.watch(ilFiyatlariProvider(ilKodu));

    return fiyatlar.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(child: Text(l.buIlIcinVeriYok));
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ilFiyatlariProvider(ilKodu));
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              ...list.map((f) => YakitFiyatKarti(fiyat: f)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  l.ilOrtalamasiNotu,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 8),
              // ÖTV Analizi butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    double? benzin, motorin, lpg;
                    for (final f in list) {
                      final tip = f.yakitTipi.toLowerCase();
                      if (tip.contains('95') || tip.contains('kurşunsuz')) {
                        benzin = f.fiyat;
                      } else if (tip.contains('motorin') &&
                          !tip.contains('premium')) {
                        motorin = f.fiyat;
                      } else if (tip.contains('lpg') ||
                          tip.contains('otogaz')) {
                        lpg = f.fiyat;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtvHesaplayiciScreen(
                          benzinFiyat: benzin,
                          motorinFiyat: motorin,
                          lpgFiyat: lpg,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.pie_chart, size: 16),
                  label: Text(l.fiyatAnalizi),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Fiyat tahmini
              Consumer(
                builder: (context, ref, _) {
                  final cm = ref.watch(cacheManagerProvider);
                  final history = cm.getPriceHistory(ilKodu);
                  final benzinTahmin = FiyatTahmin.hesapla(history, 'benzin');
                  final motorinTahmin = FiyatTahmin.hesapla(history, 'motorin');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TahminKarti(
                      benzinTahmin: benzinTahmin,
                      motorinTahmin: motorinTahmin,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _FiyatGrafigi(fiyatlar: list),
              const SizedBox(height: 8),
              _FiyatTarihceGrafigi(ilKodu: ilKodu),
            ],
          ),
        );
      },
      loading: () => const LoadingShimmer(itemCount: 4),
      error: (e, _) => ErrorDisplay(
        message: '${l.fiyatlarYuklenemedi}: $e',
        onRetry: () => ref.invalidate(ilFiyatlariProvider(ilKodu)),
      ),
    );
  }
}

class _MarkalarTab extends ConsumerWidget {
  final String ilAdi;
  const _MarkalarTab({required this.ilAdi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final markalar = ref.watch(markaFiyatlariProvider(ilAdi));

    return markalar.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(child: Text(l.markaFiyatVeriYok));
        }
        // Sütun bazlı en ucuz hesapla
        final benzinFiyatlar = list
            .where((m) => m.benzin != null)
            .map((m) => m.benzin!);
        final motorinFiyatlar = list
            .where((m) => m.motorin != null)
            .map((m) => m.motorin!);
        final lpgFiyatlar = list.where((m) => m.lpg != null).map((m) => m.lpg!);
        final minBenzin = benzinFiyatlar.isNotEmpty
            ? benzinFiyatlar.reduce((a, b) => a < b ? a : b)
            : null;
        final minMotorin = motorinFiyatlar.isNotEmpty
            ? motorinFiyatlar.reduce((a, b) => a < b ? a : b)
            : null;
        final minLpg = lpgFiyatlar.isNotEmpty
            ? lpgFiyatlar.reduce((a, b) => a < b ? a : b)
            : null;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(markaFiyatlariProvider(ilAdi));
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              // Başlık satırı
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        l.marka,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.benzin,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.benzinTuruncu,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.motorin,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.motorinMavi,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.lpg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.lpgMor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Marka satırları
              ...list.asMap().entries.map((entry) {
                final m = entry.value;
                final isBenzinMin =
                    m.benzin != null &&
                    minBenzin != null &&
                    m.benzin == minBenzin;
                final isMotorinMin =
                    m.motorin != null &&
                    minMotorin != null &&
                    m.motorin == minMotorin;
                final isLpgMin =
                    m.lpg != null && minLpg != null && m.lpg == minLpg;
                final hasAnyMin = isBenzinMin || isMotorinMin || isLpgMin;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: hasAnyMin
                        ? AppColors.indirimYesil.withValues(alpha: 0.05)
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          m.firma,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          m.benzin != null
                              ? '${m.benzin!.toStringAsFixed(2)}₺'
                              : '-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isBenzinMin ? AppColors.indirimYesil : null,
                            fontWeight: isBenzinMin
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          m.motorin != null
                              ? '${m.motorin!.toStringAsFixed(2)}₺'
                              : '-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMotorinMin ? AppColors.indirimYesil : null,
                            fontWeight: isMotorinMin
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          m.lpg != null ? '${m.lpg!.toStringAsFixed(2)}₺' : '-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isLpgMin ? AppColors.indirimYesil : null,
                            fontWeight: isLpgMin
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Toplam marka sayısı
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.akaryakitFirmasi(list.length),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingShimmer(itemCount: 8),
      error: (e, _) => ErrorDisplay(
        message: '${l.markaFiyatlariYuklenemedi}: $e',
        onRetry: () => ref.invalidate(markaFiyatlariProvider(ilAdi)),
      ),
    );
  }
}

class _FiyatGrafigi extends StatelessWidget {
  final List fiyatlar;

  const _FiyatGrafigi({required this.fiyatlar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Basit bar chart - fiyat karşılaştırması
    final spots = <BarChartGroupData>[];
    for (int i = 0; i < fiyatlar.length; i++) {
      final f = fiyatlar[i];
      Color color;
      final tip = f.yakitTipi.toLowerCase();
      if (tip.contains('95') ||
          tip.contains('kurşunsuz') ||
          tip.contains('benzin')) {
        color = AppColors.benzinTuruncu;
      } else if (tip.contains('motorin')) {
        color = AppColors.motorinMavi;
      } else if (tip.contains('lpg') || tip.contains('otogaz')) {
        color = AppColors.lpgMor;
      } else {
        color = AppColors.primaryLight;
      }
      spots.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: f.fiyat,
              color: color,
              width: 24,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.fiyatKarsilastirmasi,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: spots,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < fiyatlar.length) {
                              final tip = fiyatlar[idx].yakitTipi;
                              // Kısa etiket
                              String label;
                              final lower = tip.toLowerCase();
                              if (lower.contains('95') ||
                                  lower.contains('kurşunsuz')) {
                                label = l.benzin;
                              } else if (lower.contains('motorin')) {
                                label = l.motorin;
                              } else if (lower.contains('lpg')) {
                                label = l.lpg;
                              } else {
                                label = tip.length > 6
                                    ? '${tip.substring(0, 6)}..'
                                    : tip;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toStringAsFixed(0)}₺',
                              style: const TextStyle(fontSize: 10),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiyatTarihceGrafigi extends ConsumerWidget {
  final String ilKodu;

  const _FiyatTarihceGrafigi({required this.ilKodu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cm = ref.watch(cacheManagerProvider);
    final history = cm.getPriceHistory(ilKodu);

    if (history.isEmpty) return const SizedBox.shrink();

    if (history.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.show_chart, color: Colors.grey[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.fiyatGecmisiAciklama,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Benzin ve Motorin line chart
    final benzinSpots = <FlSpot>[];
    final motorinSpots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < history.length; i++) {
      final entry = history[i];
      final fiyatlar = (entry['fiyatlar'] as Map<String, dynamic>?) ?? {};
      labels.add((entry['tarih'] as String? ?? '').substring(5)); // MM-DD

      for (final kv in fiyatlar.entries) {
        final tip = kv.key.toLowerCase();
        final val = (kv.value as num).toDouble();
        if (tip.contains('95') || tip.contains('kurşunsuz')) {
          benzinSpots.add(FlSpot(i.toDouble(), val));
        } else if (tip.contains('motorin') && !tip.contains('premium')) {
          motorinSpots.add(FlSpot(i.toDouble(), val));
        }
      }
    }

    if (benzinSpots.isEmpty && motorinSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    final allValues = [
      ...benzinSpots.map((s) => s.y),
      ...motorinSpots.map((s) => s.y),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.fiyatGecmisi,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l.sonGunler(history.length),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      if (benzinSpots.isNotEmpty)
                        LineChartBarData(
                          spots: benzinSpots,
                          isCurved: true,
                          color: AppColors.benzinTuruncu,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.benzinTuruncu.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      if (motorinSpots.isNotEmpty)
                        LineChartBarData(
                          spots: motorinSpots,
                          isCurved: true,
                          color: AppColors.motorinMavi,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.motorinMavi.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[idx],
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toStringAsFixed(0)}₺',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(l.benzin, AppColors.benzinTuruncu),
                  const SizedBox(width: 16),
                  _legendItem(l.motorin, AppColors.motorinMavi),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
