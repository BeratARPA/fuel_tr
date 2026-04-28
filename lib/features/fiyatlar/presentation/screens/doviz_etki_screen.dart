import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../data/datasources/doviz_datasource.dart';
import '../providers/fiyat_provider.dart';

// Providers
final dovizDatasourceProvider = Provider<DovizDatasource>((ref) {
  return DovizDatasource(ref.watch(httpClientProvider));
});

final dovizVerisiProvider = FutureProvider<DovizVerisi>((ref) async {
  final ds = ref.watch(dovizDatasourceProvider);
  return ds.getGuncelKur();
});

final brentVerisiProvider = FutureProvider<BrentVerisi>((ref) async {
  final ds = ref.watch(dovizDatasourceProvider);
  return ds.getBrentFiyat();
});

class DovizEtkiScreen extends ConsumerWidget {
  const DovizEtkiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final doviz = ref.watch(dovizVerisiProvider);
    final brent = ref.watch(brentVerisiProvider);
    final top8 = ref.watch(top8FirmaFiyatlariProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dovizEtkisi),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dovizVerisiProvider);
              ref.invalidate(brentVerisiProvider);
            },
          ),
        ],
      ),
      body: doviz.when(
        data: (dovizData) {
          final brentData = brent.valueOrNull;

          // Tüm yakıt fiyatlarını bul
          double benzinFiyat = 0;
          double motorinFiyat = 0;
          double premiumMotFiyat = 0;
          double lpgFiyat = 0;
          top8.whenData((fiyatlar) {
            for (final f in fiyatlar) {
              final tip = f.yakitTipi.toLowerCase();
              if ((tip.contains('95') || tip.contains('kurşunsuz')) &&
                  benzinFiyat == 0) {
                benzinFiyat = f.fiyat;
              } else if (tip.contains('premium') || tip.contains('excellium')) {
                if (premiumMotFiyat == 0) premiumMotFiyat = f.fiyat;
              } else if (tip.contains('motorin') && motorinFiyat == 0) {
                motorinFiyat = f.fiyat;
              } else if ((tip.contains('lpg') || tip.contains('otogaz')) &&
                  lpgFiyat == 0) {
                lpgFiyat = f.fiyat;
              }
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Güncel kurlar
              Text(
                l.guncelVeriler,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _VeriKarti(
                      baslik: 'USD/TRY',
                      deger: dovizData.usdTry.toStringAsFixed(2),
                      ikon: Icons.attach_money,
                      renk: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _VeriKarti(
                      baslik: 'EUR/TRY',
                      deger: dovizData.eurTry.toStringAsFixed(2),
                      ikon: Icons.euro,
                      renk: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _VeriKarti(
                      baslik: 'Brent',
                      deger: brentData != null
                          ? '\$${brentData.fiyatUsd.toStringAsFixed(0)}'
                          : '...',
                      ikon: Icons.oil_barrel,
                      renk: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fiyat dağılımı analizi
              Text(
                l.fiyatOlusumuAnalizi,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (benzinFiyat > 0)
                _FiyatDagilimKarti(
                  yakitTipi: l.benzin95,
                  fiyat: benzinFiyat,
                  usdTry: dovizData.usdTry,
                  brentUsd: brentData?.fiyatUsd ?? 72,
                  renk: AppColors.benzinTuruncu,
                ),
              const SizedBox(height: 8),
              if (motorinFiyat > 0)
                _FiyatDagilimKarti(
                  yakitTipi: l.motorin,
                  fiyat: motorinFiyat,
                  usdTry: dovizData.usdTry,
                  brentUsd: brentData?.fiyatUsd ?? 72,
                  renk: AppColors.motorinMavi,
                ),
              if (premiumMotFiyat > 0) ...[
                const SizedBox(height: 8),
                _FiyatDagilimKarti(
                  yakitTipi: l.motorinPremium,
                  fiyat: premiumMotFiyat,
                  usdTry: dovizData.usdTry,
                  brentUsd: brentData?.fiyatUsd ?? 72,
                  renk: Colors.indigo,
                ),
              ],
              if (lpgFiyat > 0) ...[
                const SizedBox(height: 8),
                _FiyatDagilimKarti(
                  yakitTipi: l.lpg,
                  fiyat: lpgFiyat,
                  usdTry: dovizData.usdTry,
                  brentUsd: brentData?.fiyatUsd ?? 72,
                  renk: AppColors.lpgMor,
                ),
              ],
              const SizedBox(height: 16),

              // Etki analizi
              Text(
                l.dovizEtkisiSimulasyonu,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l.dolarDegisirse,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              if (benzinFiyat > 0)
                _DovizSimulasyonu(
                  mevcutFiyat: benzinFiyat,
                  mevcutUsdTry: dovizData.usdTry,
                ),
              const SizedBox(height: 16),

              // Bilgi notu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[300]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.dovizEtkisiAciklama,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingShimmer(itemCount: 4),
        error: (e, _) => ErrorDisplay(
          message: '${l.dovizVerileriYuklenemedi}: $e',
          onRetry: () => ref.invalidate(dovizVerisiProvider),
        ),
      ),
    );
  }
}

// ─── Veri Kartı ────────────────────────────────────────────
class _VeriKarti extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;

  const _VeriKarti({
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
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
          Icon(ikon, size: 20, color: renk),
          const SizedBox(height: 4),
          Text(baslik, style: TextStyle(fontSize: 10, color: renk)),
          Text(
            deger,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fiyat Dağılım Kartı (Yatay Bar) ──────────────────────
class _FiyatDagilimKarti extends StatelessWidget {
  final String yakitTipi;
  final double fiyat;
  final double usdTry;
  final double brentUsd;
  final Color renk;

  const _FiyatDagilimKarti({
    required this.yakitTipi,
    required this.fiyat,
    required this.usdTry,
    required this.brentUsd,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Yaklaşık fiyat bileşenleri (EPDK yapısı)
    // 1 varil = 159 litre, rafineri verimi ~%40-45
    final hamPetrolPaylTl = (brentUsd / 159) * usdTry * 2.5; // yaklaşık
    final otv = yakitTipi.contains('Benzin') ? 7.52 : 5.35;
    final kdv = fiyat * 0.20;
    final dagiticiMarj = (fiyat - otv - kdv - hamPetrolPaylTl).clamp(
      0.0,
      fiyat * 0.15,
    );

    final parcalar = [
      _FiyatParca(l.hamPetrol, hamPetrolPaylTl, Colors.brown),
      _FiyatParca(l.otv, otv, Colors.red),
      _FiyatParca('${l.kdv} (%20)', kdv, Colors.orange),
      _FiyatParca(l.dagiticiBayi, dagiticiMarj, Colors.blue),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_gas_station, size: 18, color: renk),
                const SizedBox(width: 6),
                Text(
                  '$yakitTipi: ${fiyat.toStringAsFixed(2)}₺/L',
                  style: TextStyle(fontWeight: FontWeight.bold, color: renk),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Yatay stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: parcalar.map((p) {
                    final oran = (p.tutar / fiyat).clamp(0.0, 1.0);
                    return Expanded(
                      flex: (oran * 100).round().clamp(1, 100),
                      child: Container(
                        color: p.renk,
                        child: Center(
                          child: oran > 0.12
                              ? Text(
                                  '%${(oran * 100).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: parcalar.map((p) {
                return Row(
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
                    const SizedBox(width: 4),
                    Text(
                      '${p.ad}: ${p.tutar.toStringAsFixed(2)}₺',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiyatParca {
  final String ad;
  final double tutar;
  final Color renk;
  const _FiyatParca(this.ad, this.tutar, this.renk);
}

// ─── Döviz Simülasyonu ─────────────────────────────────────
class _DovizSimulasyonu extends StatelessWidget {
  final double mevcutFiyat;
  final double mevcutUsdTry;

  const _DovizSimulasyonu({
    required this.mevcutFiyat,
    required this.mevcutUsdTry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // -10%, -5%, mevcut, +5%, +10% dolar senaryoları
    final senaryolar = <_Senaryo>[];
    for (final oran in [-10.0, -5.0, 0.0, 5.0, 10.0]) {
      final yeniKur = mevcutUsdTry * (1 + oran / 100);
      // Yaklaşık: fiyatın ~%35-40'ı dövize bağlı
      final dovizEtkiOrani = 0.37;
      final yeniFiyat = mevcutFiyat * (1 + (oran / 100) * dovizEtkiOrani);
      senaryolar.add(
        _Senaryo(
          dolarDegisim: oran,
          yeniKur: yeniKur,
          yeniFiyat: yeniFiyat,
          fiyatDegisim: yeniFiyat - mevcutFiyat,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Tablo
            Table(
              border: TableBorder.all(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
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
                    _TableCell(l.dolar, isHeader: true),
                    _TableCell(l.kur, isHeader: true),
                    _TableCell(l.benzin, isHeader: true),
                    _TableCell(l.fark, isHeader: true),
                  ],
                ),
                ...senaryolar.map(
                  (s) => TableRow(
                    decoration: s.dolarDegisim == 0
                        ? BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.05),
                          )
                        : null,
                    children: [
                      _TableCell(
                        s.dolarDegisim == 0
                            ? l.mevcut
                            : '${s.dolarDegisim > 0 ? "+" : ""}${s.dolarDegisim.toStringAsFixed(0)}%',
                        color: s.dolarDegisim > 0
                            ? AppColors.zamKirmizi
                            : s.dolarDegisim < 0
                            ? AppColors.indirimYesil
                            : null,
                      ),
                      _TableCell('${s.yeniKur.toStringAsFixed(2)}₺'),
                      _TableCell(
                        '${s.yeniFiyat.toStringAsFixed(2)}₺',
                        bold: s.dolarDegisim == 0,
                      ),
                      _TableCell(
                        s.fiyatDegisim == 0
                            ? '-'
                            : '${s.fiyatDegisim > 0 ? "+" : ""}${s.fiyatDegisim.toStringAsFixed(2)}₺',
                        color: s.fiyatDegisim > 0
                            ? AppColors.zamKirmizi
                            : s.fiyatDegisim < 0
                            ? AppColors.indirimYesil
                            : null,
                      ),
                    ],
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

class _Senaryo {
  final double dolarDegisim;
  final double yeniKur;
  final double yeniFiyat;
  final double fiyatDegisim;
  const _Senaryo({
    required this.dolarDegisim,
    required this.yeniKur,
    required this.yeniFiyat,
    required this.fiyatDegisim,
  });
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool bold;
  final Color? color;

  const _TableCell(
    this.text, {
    this.isHeader = false,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader || bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
