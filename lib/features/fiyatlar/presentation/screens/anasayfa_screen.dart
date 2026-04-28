import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/widget_updater.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../ayarlar/presentation/providers/ayarlar_provider.dart'
    show varsayilanIlProvider;
import '../../../favoriler/presentation/providers/favori_provider.dart';
import '../../domain/entities/il_fiyat_ozet.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/fiyat_provider.dart';
import '../../../../shared/widgets/native_ad_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// İl arama state
final _ilAramaProvider = StateProvider<String>((ref) => '');

class AnasayfaScreen extends ConsumerStatefulWidget {
  const AnasayfaScreen({super.key});

  @override
  ConsumerState<AnasayfaScreen> createState() => _AnasayfaScreenState();
}

class _AnasayfaScreenState extends ConsumerState<AnasayfaScreen> {
  bool _ilkAcilisKontrolEdildi = false;
  final _aramaController = TextEditingController();

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIlkAcilis();
    });
  }

  void _checkIlkAcilis() {
    if (_ilkAcilisKontrolEdildi) return;
    _ilkAcilisKontrolEdildi = true;

    final notifier = ref.read(varsayilanIlProvider.notifier);
    if (!notifier.ilkAcilisYapildi) {
      _showIlSecimDialog();
    }
  }

  void _showIlSecimDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 48,
                        color: AppColors.benzinTuruncu,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.hosGeldiniz ??
                            'Hoş Geldiniz!',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)?.bulundugunuzIliSecin ??
                            'Bulunduğunuz ili seçin',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: IlKodlari.sortedByName.map((il) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            il.key,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        title: Text(il.value),
                        onTap: () {
                          ref.read(varsayilanIlProvider.notifier).setIl(il.key);
                          ref.read(favoriProvider.notifier).addFavori(il.key);
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final top8 = ref.watch(top8FirmaFiyatlariProvider);
    final aramaQuery = ref.watch(_ilAramaProvider);

    // Filtrelenmiş il listesi
    final tumIller = IlKodlari.sortedByName;
    final filtrelenmisIller = aramaQuery.isEmpty
        ? tumIller
        : tumIller.where((il) {
            final q = aramaQuery
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
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appTitle ?? 'YakıtCep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(top8FirmaFiyatlariProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(top8FirmaFiyatlariProvider);
        },
        child: ListView(
          children: [
            // Ulusal ortalama kartları
            top8.when(
              data: (fiyatlar) {
                final grouped = <String, List<double>>{};
                for (final f in fiyatlar) {
                  grouped.putIfAbsent(f.yakitTipi, () => []).add(f.fiyat);
                }
                final averages = grouped.map((key, values) {
                  final avg = values.reduce((a, b) => a + b) / values.length;
                  return MapEntry(key, avg);
                });

                // Sıralama: Benzin, Motorin, Premium, LPG, diğer
                final sortedEntries = averages.entries.toList()
                  ..sort((a, b) {
                    int order(String tip) {
                      final t = tip.toLowerCase();
                      if (t.contains('95') || t.contains('kurşunsuz')) return 0;
                      if (t.contains('motorin') &&
                          !t.contains('premium') &&
                          !t.contains('excellium'))
                        return 1;
                      if (t.contains('motorin')) return 2;
                      if (t.contains('lpg') || t.contains('otogaz')) return 3;
                      return 4;
                    }

                    return order(a.key).compareTo(order(b.key));
                  });

                // Android widget'ı güncelle
                double? benzinAvg, motorinAvg, lpgAvg;
                for (final e in sortedEntries) {
                  final t = e.key.toLowerCase();
                  if ((t.contains('95') || t.contains('kurşunsuz')) &&
                      benzinAvg == null) {
                    benzinAvg = e.value;
                  } else if (t.contains('motorin') &&
                      !t.contains('premium') &&
                      motorinAvg == null) {
                    motorinAvg = e.value;
                  } else if ((t.contains('lpg') || t.contains('otogaz')) &&
                      lpgAvg == null) {
                    lpgAvg = e.value;
                  }
                }

                if (benzinAvg != null && motorinAvg != null && lpgAvg != null) {
                  Future.microtask(() async {
                    try {
                      await WidgetUpdater.fetchAndUpdateDataFromBackground();
                    } catch (e) {
                      debugPrint('Widget update error from ui: $e');
                    }
                  });
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.ulusalOrtalama ??
                            'Ulusal Ortalama',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sortedEntries.map((e) {
                          return _UlusalOrtalamaKart(
                            yakitTipi: e.key,
                            fiyat: e.value,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      // Son güncelleme zamanı
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.sonGuncelleme(
                              DateFormatter.zamanFarki(
                                fiyatlar.first.guncellemeTarihi,
                                AppLocalizations.of(context),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingShimmer(itemCount: 2),
              ),
              error: (e, _) => ErrorDisplay(
                message:
                    '${AppLocalizations.of(context)!.fiyatlarYuklenemedi}: $e',
                onRetry: () => ref.invalidate(top8FirmaFiyatlariProvider),
              ),
            ),
            // Hızlı erişim butonları — 2x2 grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _QuickButton(
                          icon: Icons.near_me,
                          label:
                              AppLocalizations.of(context)?.yakinIstasyonlar ??
                              'Yakın İstasyonlar',
                          onTap: () =>
                              context.go('/fiyatlar/yakin-istasyonlar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickButton(
                          icon: Icons.currency_exchange,
                          label:
                              AppLocalizations.of(context)?.dovizEtkisi ??
                              'Döviz Etkisi',
                          onTap: () => context.go('/fiyatlar/doviz-etkisi'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickButton(
                          icon: Icons.book,
                          label:
                              AppLocalizations.of(context)?.yakitDefteri ??
                              'Yakıt Defteri',
                          onTap: () => context.go('/fiyatlar/yakit-defteri'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickButton(
                          icon: Icons.map,
                          label:
                              AppLocalizations.of(context)?.fiyatHaritasi ??
                              'Fiyat Haritası',
                          color: Colors.deepOrange,
                          onTap: () => context.go('/fiyatlar/isi-haritasi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Favori iller
            Consumer(
              builder: (context, ref, _) {
                final favoriler = ref.watch(favoriProvider);
                if (favoriler.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.favorilerim ??
                            'Favorilerim',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...favoriler.map((ilKodu) {
                      final ilAdi = IlKodlari.getIlAdi(ilKodu);
                      return _IlListeTile(
                        ilKodu: ilKodu,
                        ilAdi: ilAdi,
                        isFavori: true,
                      );
                    }),
                    const Divider(),
                  ],
                );
              },
            ),

            // Tüm iller başlığı + arama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppLocalizations.of(context)?.tumIller ?? 'Tüm İller',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            // Arama çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _aramaController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.ilAra ?? 'İl ara...',
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
                            ref.read(_ilAramaProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
                onChanged: (val) =>
                    ref.read(_ilAramaProvider.notifier).state = val,
              ),
            ),
            const SizedBox(height: 8),
            ...filtrelenmisIller.asMap().entries.expand((entry) {
              final index = entry.key;
              final il = entry.value;
              final tile = _IlListeTile(ilKodu: il.key, ilAdi: il.value);

              if (index > 0 && index % 10 == 0) {
                return [
                  const Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Sponsorlu',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      NativeAdWidget(templateType: TemplateType.medium),
                      SizedBox(height: 8),
                    ],
                  ),
                  tile,
                ];
              }
              return [tile];
            }),
          ],
        ),
      ),
    );
  }
}

class _UlusalOrtalamaKart extends StatelessWidget {
  final String yakitTipi;
  final double fiyat;

  const _UlusalOrtalamaKart({required this.yakitTipi, required this.fiyat});

  String _kisaAd(AppLocalizations l) {
    final tip = yakitTipi.toLowerCase();
    if (tip.contains('95') || tip.contains('kurşunsuz')) return l.benzin95;
    if (tip.contains('motorin') &&
        (tip.contains('premium') || tip.contains('excellium')))
      return l.motorinPremium;
    if (tip.contains('motorin')) return l.motorin;
    if (tip.contains('lpg') || tip.contains('otogaz')) return l.lpg;
    return yakitTipi;
  }

  Color get _renk {
    final tip = yakitTipi.toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_gas_station, color: _renk, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _kisaAd(AppLocalizations.of(context)!),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${fiyat.toStringAsFixed(2)} ₺',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _renk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IlListeTile extends ConsumerWidget {
  final String ilKodu;
  final String ilAdi;
  final bool isFavori;

  const _IlListeTile({
    required this.ilKodu,
    required this.ilAdi,
    this.isFavori = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ilOzet = ref.watch(ilOzetProvider((ilKodu: ilKodu, ilAdi: ilAdi)));

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isFavori
            ? AppColors.benzinTuruncu.withValues(alpha: 0.2)
            : Colors.grey[200],
        child: Text(
          ilKodu.padLeft(2, '0'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isFavori ? AppColors.benzinTuruncu : Colors.black87,
          ),
        ),
      ),
      title: Text(ilAdi),
      subtitle: ilOzet.when(
        data: (ozet) {
          final hasBenzin = ozet.benzin95 > 0;
          final hasLpg = ozet.lpg != null;
          if (!hasBenzin && !hasLpg) {
            return Text(
              AppLocalizations.of(context)?.veriYok ?? 'Veri yok',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            );
          }
          return Row(
            children: [
              if (hasBenzin) ...[
                Text(
                  'B: ${ozet.benzin95.toStringAsFixed(2)}₺',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.benzinTuruncu,
                  ),
                ),
                _trendIcon(ozet.benzinTrend),
                const SizedBox(width: 6),
                Text(
                  'M: ${ozet.motorin.toStringAsFixed(2)}₺',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.motorinMavi,
                  ),
                ),
                _trendIcon(ozet.motorinTrend),
              ],
              if (hasLpg) ...[
                if (hasBenzin) const SizedBox(width: 6),
                Text(
                  'L: ${ozet.lpg!.toStringAsFixed(2)}₺',
                  style: const TextStyle(fontSize: 12, color: AppColors.lpgMor),
                ),
              ],
            ],
          );
        },
        loading: () => Text(
          AppLocalizations.of(context)?.yukleniyor ?? 'Yükleniyor...',
          style: const TextStyle(fontSize: 12),
        ),
        error: (e, s) => Text(
          AppLocalizations.of(context)?.veriYok ?? 'Veri yok',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        context.go('/fiyatlar/il/$ilKodu?ilAdi=${Uri.encodeComponent(ilAdi)}');
      },
    );
  }

  Widget _trendIcon(FiyatTrend trend) {
    switch (trend) {
      case FiyatTrend.yukari:
        return const Icon(
          Icons.arrow_drop_up,
          size: 16,
          color: AppColors.zamKirmizi,
        );
      case FiyatTrend.asagi:
        return const Icon(
          Icons.arrow_drop_down,
          size: 16,
          color: AppColors.indirimYesil,
        );
      case FiyatTrend.sabit:
        return const SizedBox.shrink();
    }
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        side: BorderSide(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: c),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
