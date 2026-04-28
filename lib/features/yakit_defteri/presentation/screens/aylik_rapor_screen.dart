import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/yakit_kayit.dart';
import '../providers/yakit_defteri_provider.dart';

class AylikRaporScreen extends ConsumerWidget {
  const AylikRaporScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final kayitlar = ref.watch(yakitDefteriProvider);
    final buAy = ref.watch(buAyIstatistikProvider);
    final gecenAy = ref.watch(gecenAyIstatistikProvider);
    final aylikHarcamalar = ref.watch(aylikHarcamaProvider);

    final now = DateTime.now();
    final buAyStr = DateFormat('MMMM yyyy', 'tr').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.aylikRapor),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            onPressed: () => _paylas(l, buAy, gecenAy, buAyStr),
          ),
        ],
      ),
      body: kayitlar.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    l.raporIcinKayitGerekli,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.yakitDefterineKayitEkleyin,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Bu ay özeti
                Text(buAyStr, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Ana istatistikler
                Row(
                  children: [
                    Expanded(
                      child: _BuyukKart(
                        baslik: l.toplamMaliyet,
                        deger: '${buAy.toplamHarcama.toStringAsFixed(0)}₺',
                        ikon: Icons.payments,
                        renk: AppColors.zamKirmizi,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BuyukKart(
                        baslik: '${l.toplam} ${l.litre}',
                        deger: '${buAy.toplamLitre.toStringAsFixed(1)}L',
                        ikon: Icons.water_drop,
                        renk: AppColors.motorinMavi,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _BuyukKart(
                        baslik: l.ortLitreFiyat,
                        deger: '${buAy.ortalamaLitreFiyat.toStringAsFixed(2)}₺',
                        ikon: Icons.local_gas_station,
                        renk: AppColors.benzinTuruncu,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BuyukKart(
                        baslik: l.tuketimLabel,
                        deger: buAy.ortalamaKmTuketim != null
                            ? '${buAy.ortalamaKmTuketim!.toStringAsFixed(1)} L/100km'
                            : l.veriYok,
                        ikon: Icons.speed,
                        renk: AppColors.indirimYesil,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Geçen ayla karşılaştırma
                if (gecenAy.kayitSayisi > 0) ...[
                  Text(
                    l.gecenAylaKarsilastirma,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _KarsilastirmaKart(
                    baslik: l.tutar,
                    buAyDeger: buAy.toplamHarcama,
                    gecenAyDeger: gecenAy.toplamHarcama,
                    birim: '₺',
                  ),
                  _KarsilastirmaKart(
                    baslik: l.litre,
                    buAyDeger: buAy.toplamLitre,
                    gecenAyDeger: gecenAy.toplamLitre,
                    birim: 'L',
                  ),
                  _KarsilastirmaKart(
                    baslik: l.ortFiyat,
                    buAyDeger: buAy.ortalamaLitreFiyat,
                    gecenAyDeger: gecenAy.ortalamaLitreFiyat,
                    birim: '₺/L',
                  ),
                  const SizedBox(height: 16),
                ],

                // 6 aylık grafik
                if (aylikHarcamalar.any((a) => a.toplam > 0)) ...[
                  Text(
                    l.altiAylikHarcamaTrendi,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _hesaplaInterval(aylikHarcamalar),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}₺',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
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
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx >= aylikHarcamalar.length) {
                                  return const SizedBox();
                                }
                                return Text(
                                  DateFormat(
                                    'MMM',
                                    'tr',
                                  ).format(aylikHarcamalar[idx].ay),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: aylikHarcamalar
                                .asMap()
                                .entries
                                .map(
                                  (e) =>
                                      FlSpot(e.key.toDouble(), e.value.toplam),
                                )
                                .toList(),
                            isCurved: true,
                            color: AppColors.primaryLight,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Yakıt tipi dağılımı
                const SizedBox(height: 16),
                _YakitTipiDagilimi(kayitlar: kayitlar),
              ],
            ),
    );
  }

  double _hesaplaInterval(List<AylikHarcama> data) {
    final max = data.map((a) => a.toplam).fold(0.0, (a, b) => a > b ? a : b);
    if (max <= 0) return 100;
    return (max / 4).ceilToDouble();
  }

  void _paylas(
    AppLocalizations l,
    YakitIstatistik buAy,
    YakitIstatistik gecenAy,
    String ayStr,
  ) async {
    final lines = [
      l.paylasAylikRapor,
      ayStr,
      '─────────────────',
      '${l.toplamMaliyet}: ${buAy.toplamHarcama.toStringAsFixed(0)}₺',
      '${l.toplamLitre}: ${buAy.toplamLitre.toStringAsFixed(1)}L',
      '${l.ortFiyat}: ${buAy.ortalamaLitreFiyat.toStringAsFixed(2)}₺/L',
      '${l.kayitSayisi}: ${buAy.kayitSayisi}',
    ];
    if (buAy.ortalamaKmTuketim != null) {
      lines.add(
        '${l.ortTuketim}: ${buAy.ortalamaKmTuketim!.toStringAsFixed(1)} L/100km',
      );
    }
    if (gecenAy.toplamHarcama > 0) {
      final degisim =
          ((buAy.toplamHarcama - gecenAy.toplamHarcama) /
                  gecenAy.toplamHarcama *
                  100)
              .toStringAsFixed(0);
      lines.add('${l.gecenAyaGore}: $degisim%');
    }
    try {
      await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
    } catch (_) {}
  }
}

// ─── Büyük İstatistik Kartı ──────────────────────────────
class _BuyukKart extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;

  const _BuyukKart({
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ikon, size: 16, color: renk),
                const SizedBox(width: 6),
                Text(baslik, style: TextStyle(fontSize: 11, color: renk)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              deger,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: renk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Karşılaştırma Kartı ─────────────────────────────────
class _KarsilastirmaKart extends StatelessWidget {
  final String baslik;
  final double buAyDeger;
  final double gecenAyDeger;
  final String birim;

  const _KarsilastirmaKart({
    required this.baslik,
    required this.buAyDeger,
    required this.gecenAyDeger,
    required this.birim,
  });

  @override
  Widget build(BuildContext context) {
    final fark = buAyDeger - gecenAyDeger;
    final yuzde = gecenAyDeger > 0 ? (fark / gecenAyDeger * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(baslik, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${buAyDeger.toStringAsFixed(birim == '₺/L' ? 2 : 0)}$birim',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 65,
            child: Text(
              '${fark >= 0 ? "+" : ""}${yuzde.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: fark > 0 ? AppColors.zamKirmizi : AppColors.indirimYesil,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Yakıt Tipi Dağılımı ─────────────────────────────────
class _YakitTipiDagilimi extends StatelessWidget {
  final List<YakitKayit> kayitlar;
  const _YakitTipiDagilimi({required this.kayitlar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final benzin = kayitlar.where((k) => k.yakitTipi == 'benzin').length;
    final motorin = kayitlar.where((k) => k.yakitTipi == 'motorin').length;
    final lpg = kayitlar.where((k) => k.yakitTipi == 'lpg').length;
    final toplam = kayitlar.length;

    if (toplam == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.yakitTipiDagilimi,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _DagilimBar(l.benzin, benzin, toplam, AppColors.benzinTuruncu),
        _DagilimBar(l.motorin, motorin, toplam, AppColors.motorinMavi),
        _DagilimBar(l.lpg, lpg, toplam, AppColors.lpgMor),
      ],
    );
  }
}

class _DagilimBar extends StatelessWidget {
  final String tip;
  final int sayi;
  final int toplam;
  final Color renk;

  const _DagilimBar(this.tip, this.sayi, this.toplam, this.renk);

  @override
  Widget build(BuildContext context) {
    final oran = toplam > 0 ? sayi / toplam : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(tip, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: oran,
                backgroundColor: renk.withValues(alpha: 0.1),
                color: renk,
                minHeight: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sayi (${(oran * 100).toStringAsFixed(0)}%)',
            style: TextStyle(fontSize: 11, color: renk),
          ),
        ],
      ),
    );
  }
}
