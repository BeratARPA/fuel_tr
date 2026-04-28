import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DegisimBadge extends StatelessWidget {
  final double? degisimYuzdesi;

  const DegisimBadge({super.key, this.degisimYuzdesi});

  @override
  Widget build(BuildContext context) {
    if (degisimYuzdesi == null) return const SizedBox.shrink();

    final isPositive = degisimYuzdesi! > 0;
    final isZero = degisimYuzdesi!.abs() < 0.01;

    if (isZero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '— Sabit',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    final color = isPositive ? AppColors.zamKirmizi : AppColors.indirimYesil;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final prefix = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '$prefix%${degisimYuzdesi!.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
