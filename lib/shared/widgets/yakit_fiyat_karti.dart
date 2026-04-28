import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/fiyatlar/domain/entities/akaryakit_fiyat.dart';
import 'degisim_badge.dart';

class YakitFiyatKarti extends StatelessWidget {
  final AkaryakitFiyat fiyat;

  const YakitFiyatKarti({super.key, required this.fiyat});

  Color get _renk {
    final tip = fiyat.yakitTipi.toLowerCase();
    if (tip.contains('95') ||
        tip.contains('kurşunsuz') ||
        tip.contains('benzin')) {
      return AppColors.benzinTuruncu;
    } else if (tip.contains('motorin')) {
      return AppColors.motorinMavi;
    } else if (tip.contains('lpg') || tip.contains('otogaz')) {
      return AppColors.lpgMor;
    }
    return AppColors.primaryLight;
  }

  IconData get _icon {
    final tip = fiyat.yakitTipi.toLowerCase();
    if (tip.contains('lpg') || tip.contains('otogaz')) {
      return Icons.local_gas_station_outlined;
    }
    return Icons.local_gas_station;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _renk.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _renk, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fiyat.yakitTipi,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fiyat.birim,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${fiyat.fiyat.toStringAsFixed(2)} ₺',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _renk,
                  ),
                ),
                const SizedBox(height: 4),
                DegisimBadge(degisimYuzdesi: fiyat.degisimYuzdesi),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
