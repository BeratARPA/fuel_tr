import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/usecases/fiyat_tahmin.dart';

class TahminKarti extends StatelessWidget {
  final FiyatTahmin? benzinTahmin;
  final FiyatTahmin? motorinTahmin;

  const TahminKarti({super.key, this.benzinTahmin, this.motorinTahmin});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (benzinTahmin == null && motorinTahmin == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_graph,
                  size: 18,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  l.fiyatTahmini,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BETA',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (benzinTahmin != null)
              _TahminSatir(
                yakitTipi: l.benzin,
                tahmin: benzinTahmin!,
                renk: AppColors.benzinTuruncu,
              ),
            if (benzinTahmin != null && motorinTahmin != null)
              const SizedBox(height: 6),
            if (motorinTahmin != null)
              _TahminSatir(
                yakitTipi: l.motorin,
                tahmin: motorinTahmin!,
                renk: AppColors.motorinMavi,
              ),
            const SizedBox(height: 8),
            Text(
              'Son ${benzinTahmin?.gunSayisi ?? motorinTahmin?.gunSayisi ?? 0} '
              'gunluk trend analizi',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TahminSatir extends StatelessWidget {
  final String yakitTipi;
  final FiyatTahmin tahmin;
  final Color renk;

  const _TahminSatir({
    required this.yakitTipi,
    required this.tahmin,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final icon = tahmin.yon == TahminYonu.artis
        ? Icons.trending_up
        : tahmin.yon == TahminYonu.dusus
        ? Icons.trending_down
        : Icons.trending_flat;

    final yonRenk = tahmin.yon == TahminYonu.artis
        ? AppColors.zamKirmizi
        : tahmin.yon == TahminYonu.dusus
        ? AppColors.indirimYesil
        : Colors.grey;

    final yonText = tahmin.yon == TahminYonu.artis
        ? l.artisBekleniyor
        : tahmin.yon == TahminYonu.dusus
        ? l.dususBekleniyor
        : l.sabitKalmasiBekleniyor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: yonRenk.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: yonRenk.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, size: 16, color: renk),
          const SizedBox(width: 6),
          Text(
            yakitTipi,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: renk,
            ),
          ),
          const Spacer(),
          Icon(icon, size: 18, color: yonRenk),
          const SizedBox(width: 4),
          Text(
            '${tahmin.tahminiDegisimYuzde > 0 ? "+" : ""}'
            '${tahmin.tahminiDegisimYuzde.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: yonRenk,
            ),
          ),
          const SizedBox(width: 8),
          Text(yonText, style: TextStyle(fontSize: 10, color: yonRenk)),
        ],
      ),
    );
  }
}
