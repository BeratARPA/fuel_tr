import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../domain/entities/haber.dart';
import '../providers/haber_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/widgets/native_ad_widget.dart';

final _haberAramaProvider = StateProvider<String>((ref) => '');

class HaberlerScreen extends ConsumerStatefulWidget {
  const HaberlerScreen({super.key});

  @override
  ConsumerState<HaberlerScreen> createState() => _HaberlerScreenState();
}

class _HaberlerScreenState extends ConsumerState<HaberlerScreen> {
  final _aramaController = TextEditingController();

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final haberler = ref.watch(filtrelenmisHaberlerProvider);
    final zamanFiltre = ref.watch(haberFiltresiProvider);
    final kategoriFiltre = ref.watch(kategoriFiltresiProvider);
    final aramaQuery = ref.watch(_haberAramaProvider);
    final istatistikler = ref.watch(haberIstatistikleriProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.akaryakitHaberleri),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(zamHaberleriProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Ã§ubuÄŸu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _aramaController,
              decoration: InputDecoration(
                hintText: l.haberAra,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: aramaQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _aramaController.clear();
                          ref.read(_haberAramaProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(_haberAramaProvider.notifier).state = v,
            ),
          ),

          // Ä°statistik Ã¶zet kartlarÄ±
          istatistikler.whenData((stats) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      _MiniStat(
                        icon: Icons.trending_up,
                        color: AppColors.zamKirmizi,
                        count: stats['zam'] ?? 0,
                        label: l.zam,
                      ),
                      const SizedBox(width: 8),
                      _MiniStat(
                        icon: Icons.trending_down,
                        color: AppColors.indirimYesil,
                        count: stats['indirim'] ?? 0,
                        label: l.indirim,
                      ),
                      const SizedBox(width: 8),
                      _MiniStat(
                        icon: Icons.newspaper,
                        color: Colors.blueGrey,
                        count: stats['toplam'] ?? 0,
                        label: l.toplam,
                      ),
                    ],
                  ),
                );
              }).value ??
              const SizedBox.shrink(),

          // Zaman filtresi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SegmentedButton<HaberFiltresi>(
              segments: [
                ButtonSegment(value: HaberFiltresi.tumu, label: Text(l.tumu)),
                ButtonSegment(
                  value: HaberFiltresi.son24Saat,
                  label: Text(l.son24Saat),
                ),
                ButtonSegment(
                  value: HaberFiltresi.buHafta,
                  label: Text(l.buHafta),
                ),
              ],
              selected: {zamanFiltre},
              onSelectionChanged: (s) =>
                  ref.read(haberFiltresiProvider.notifier).state = s.first,
            ),
          ),

          // Kategori filtresi â€” yatay kaydÄ±rmalÄ± chip'ler
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _KategoriChip(
                  label: l.tumu,
                  icon: Icons.all_inclusive,
                  isSelected: kategoriFiltre == KategoriFiltresi.tumu,
                  onTap: () =>
                      ref.read(kategoriFiltresiProvider.notifier).state =
                          KategoriFiltresi.tumu,
                ),
                _KategoriChip(
                  label: l.zam,
                  icon: Icons.trending_up,
                  color: AppColors.zamKirmizi,
                  isSelected: kategoriFiltre == KategoriFiltresi.zam,
                  onTap: () =>
                      ref.read(kategoriFiltresiProvider.notifier).state =
                          KategoriFiltresi.zam,
                ),
                _KategoriChip(
                  label: l.indirim,
                  icon: Icons.trending_down,
                  color: AppColors.indirimYesil,
                  isSelected: kategoriFiltre == KategoriFiltresi.indirim,
                  onTap: () =>
                      ref.read(kategoriFiltresiProvider.notifier).state =
                          KategoriFiltresi.indirim,
                ),
                _KategoriChip(
                  label: l.fiyat,
                  icon: Icons.price_change,
                  color: Colors.orange,
                  isSelected: kategoriFiltre == KategoriFiltresi.fiyat,
                  onTap: () =>
                      ref.read(kategoriFiltresiProvider.notifier).state =
                          KategoriFiltresi.fiyat,
                ),
                _KategoriChip(
                  label: l.petrolDoviz,
                  icon: Icons.oil_barrel,
                  color: Colors.blueGrey,
                  isSelected: kategoriFiltre == KategoriFiltresi.petrolDoviz,
                  onTap: () =>
                      ref.read(kategoriFiltresiProvider.notifier).state =
                          KategoriFiltresi.petrolDoviz,
                ),
              ],
            ),
          ),

          // Haber listesi
          Expanded(
            child: haberler.when(
              data: (allList) {
                // Arama filtresi
                final list = aramaQuery.isEmpty
                    ? allList
                    : allList.where((h) {
                        final q = aramaQuery.toLowerCase();
                        return h.baslik.toLowerCase().contains(q) ||
                            h.ozet.toLowerCase().contains(q);
                      }).toList();
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aramaQuery.isNotEmpty
                              ? '"$aramaQuery" ile eÅŸleÅŸen haber yok'
                              : l.buFiltredeHaberYok,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        if (kategoriFiltre != KategoriFiltresi.tumu)
                          TextButton(
                            onPressed: () =>
                                ref
                                        .read(kategoriFiltresiProvider.notifier)
                                        .state =
                                    KategoriFiltresi.tumu,
                            child: Text(l.tumHaberleriGoster),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(zamHaberleriProvider);
                  },
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) {
                      // Her 4 haberde bir reklam goster
                      if ((index + 1) % 4 == 0) {
                        return const Column(
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Sponsorlu',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            NativeAdWidget(templateType: TemplateType.medium),
                            SizedBox(height: 8),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    itemBuilder: (context, index) {
                      return _HaberKarti(haber: list[index]);
                    },
                  ),
                );
              },
              loading: () => const LoadingShimmer(itemCount: 5),
              error: (e, _) => ErrorDisplay(
                message: 'Haberler yÃ¼klenemedi: $e',
                onRetry: () => ref.invalidate(zamHaberleriProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Mini Ä°statistik Widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Kategori Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _KategoriChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _KategoriChip({
    required this.label,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : chipColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// â”€â”€â”€ Haber KartÄ± â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _HaberKarti extends StatelessWidget {
  final Haber haber;

  const _HaberKarti({required this.haber});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final etiketData = _etiketVerisi(haber.etiket, l);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/haberler/detay', extra: haber);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiketler satÄ±rÄ±
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  // Ana etiket
                  if (etiketData != null)
                    _EtiketBadge(
                      text: etiketData.text,
                      color: etiketData.color,
                      icon: etiketData.icon,
                    ),
                  // YakÄ±t tÃ¼rÃ¼ etiketi
                  if (haber.zamTuru != null && haber.zamTuru != ZamTuru.genel)
                    _EtiketBadge(
                      text: _zamTuruText(haber.zamTuru!, l),
                      color: _zamTuruColor(haber.zamTuru!),
                    ),
                ],
              ),
              if (etiketData != null) const SizedBox(height: 8),

              // BaÅŸlÄ±k
              Text(
                haber.baslik,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Ã–zet
              if (haber.ozet.isNotEmpty)
                Text(
                  haber.ozet,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // Kaynak, tarih, alaka skoru
              Row(
                children: [
                  Icon(Icons.source, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      haber.kaynak,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Alaka gÃ¶stergesi
                  _AlakaGostergesi(alaka: haber.alaka),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.zamanFarki(haber.yayinTarihi, l),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _EtiketData? _etiketVerisi(HaberEtiketi etiket, AppLocalizations l) {
    switch (etiket) {
      case HaberEtiketi.zamKesin:
        return _EtiketData(l.zamGeldi, AppColors.zamKirmizi, Icons.trending_up);
      case HaberEtiketi.zamBeklentisi:
        return _EtiketData(
          l.zamBeklentisiTag,
          Colors.orange,
          Icons.trending_up,
        );
      case HaberEtiketi.indirimKesin:
        return _EtiketData(
          l.indirimGeldi,
          AppColors.indirimYesil,
          Icons.trending_down,
        );
      case HaberEtiketi.indirimBeklentisi:
        return _EtiketData(
          l.indirimBeklentisiTag,
          Colors.teal,
          Icons.trending_down,
        );
      case HaberEtiketi.fiyatDegisimi:
        return _EtiketData(l.fiyatDegisimi, Colors.blue, Icons.price_change);
      case HaberEtiketi.spiDegisimi:
        return _EtiketData(l.petrolDoviz, Colors.blueGrey, Icons.oil_barrel);
      case HaberEtiketi.bilgilendirme:
        return _EtiketData(l.bilgi, Colors.grey, Icons.info_outline);
    }
  }

  String _zamTuruText(ZamTuru tur, AppLocalizations l) {
    switch (tur) {
      case ZamTuru.benzin:
        return l.benzin;
      case ZamTuru.motorin:
        return l.motorin;
      case ZamTuru.lpg:
        return l.lpg;
      case ZamTuru.otv:
        return 'Ã–TV';
      case ZamTuru.genel:
        return '';
    }
  }

  Color _zamTuruColor(ZamTuru tur) {
    switch (tur) {
      case ZamTuru.benzin:
        return AppColors.benzinTuruncu;
      case ZamTuru.motorin:
        return AppColors.motorinMavi;
      case ZamTuru.lpg:
        return AppColors.lpgMor;
      case ZamTuru.otv:
        return Colors.deepPurple;
      case ZamTuru.genel:
        return Colors.grey;
    }
  }
}

class _EtiketData {
  final String text;
  final Color color;
  final IconData icon;
  const _EtiketData(this.text, this.color, this.icon);
}

// â”€â”€â”€ Etiket Badge Widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EtiketBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _EtiketBadge({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
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

// â”€â”€â”€ Alaka GÃ¶stergesi â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AlakaGostergesi extends StatelessWidget {
  final double alaka;
  const _AlakaGostergesi({required this.alaka});

  @override
  Widget build(BuildContext context) {
    final dots = (alaka * 4).round().clamp(1, 4);
    final color = alaka > 0.6
        ? AppColors.indirimYesil
        : alaka > 0.3
        ? Colors.orange
        : Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < dots ? color : Colors.grey.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
