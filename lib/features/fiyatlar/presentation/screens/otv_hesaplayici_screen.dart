import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// ÖTV/KDV oranları provider
final otvOranlariProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/otv_oranlari.json');
  return jsonDecode(jsonStr) as Map<String, dynamic>;
});

class OtvHesaplayiciScreen extends ConsumerWidget {
  final double? benzinFiyat;
  final double? motorinFiyat;
  final double? lpgFiyat;

  const OtvHesaplayiciScreen({
    super.key,
    this.benzinFiyat,
    this.motorinFiyat,
    this.lpgFiyat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final otvData = ref.watch(otvOranlariProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.fiyatAnalizi)),
      body: otvData.when(
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l.fiyatOlusumuAnalizi,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l.fiyatOlusumuAciklama,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),

              if (benzinFiyat != null && benzinFiyat! > 0)
                _FiyatAnalizKarti(
                  yakitTipi: l.benzin95,
                  fiyat: benzinFiyat!,
                  otvData: data['benzin95'] as Map<String, dynamic>,
                  renk: AppColors.benzinTuruncu,
                ),
              const SizedBox(height: 12),
              if (motorinFiyat != null && motorinFiyat! > 0)
                _FiyatAnalizKarti(
                  yakitTipi: l.motorin,
                  fiyat: motorinFiyat!,
                  otvData: data['motorin'] as Map<String, dynamic>,
                  renk: AppColors.motorinMavi,
                ),
              const SizedBox(height: 12),
              if (lpgFiyat != null && lpgFiyat! > 0)
                _FiyatAnalizKarti(
                  yakitTipi: l.lpg,
                  fiyat: lpgFiyat!,
                  otvData: data['lpg'] as Map<String, dynamic>,
                  renk: AppColors.lpgMor,
                ),
              const SizedBox(height: 16),

              // Bilgi notu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.kaynak}: ${data['kaynak'] ?? "EPDK"}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      '${l.otvOranlariTarihi}: ${data['guncelleme'] ?? "-"}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.yaklasikHesapNotu,
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.veriYuklenemedi}: $e')),
      ),
    );
  }
}

class _FiyatAnalizKarti extends StatelessWidget {
  final String yakitTipi;
  final double fiyat;
  final Map<String, dynamic> otvData;
  final Color renk;

  const _FiyatAnalizKarti({
    required this.yakitTipi,
    required this.fiyat,
    required this.otvData,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final otv = (otvData['otv_tl_litre'] as num).toDouble();
    final kdvOran = (otvData['kdv_oran'] as num).toDouble();
    final dagitici = (otvData['dagitici_marj_tl'] as num).toDouble();
    final bayi = (otvData['bayi_marj_tl'] as num).toDouble();

    // KDV = fiyat * kdvOran / (100 + kdvOran)
    final kdv = fiyat * kdvOran / (100 + kdvOran);
    final marjlar = dagitici + bayi;
    final hamPetrol = (fiyat - otv - kdv - marjlar).clamp(0.0, fiyat);

    final parcalar = [
      _Parca(l.hamPetrol, hamPetrol, Colors.brown),
      _Parca(l.otv, otv, Colors.red),
      _Parca(l.kdv, kdv, Colors.orange),
      _Parca(l.dagiticiMarji, dagitici, Colors.blue),
      _Parca(l.bayiMarji, bayi, Colors.teal),
    ];

    final vergiToplam = otv + kdv;
    final vergiYuzde = fiyat > 0 ? (vergiToplam / fiyat * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(Icons.local_gas_station, size: 20, color: renk),
                const SizedBox(width: 6),
                Text(
                  '$yakitTipi: ${fiyat.toStringAsFixed(2)}₺/L',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: renk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${l.vergiler}: ${vergiToplam.toStringAsFixed(2)}₺ (%${vergiYuzde.toStringAsFixed(0)})',
              style: TextStyle(fontSize: 12, color: Colors.red[400]),
            ),
            const SizedBox(height: 12),

            // Pasta grafik
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: parcalar.map((p) {
                          final yuzde = fiyat > 0 ? (p.tutar / fiyat * 100) : 0;
                          return PieChartSectionData(
                            value: p.tutar,
                            color: p.renk,
                            title: '${yuzde.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            radius: 55,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parcalar.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: p.renk,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${p.ad}: ${p.tutar.toStringAsFixed(2)}₺',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Parca {
  final String ad;
  final double tutar;
  final Color renk;
  const _Parca(this.ad, this.tutar, this.renk);
}
