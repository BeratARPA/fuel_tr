import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/il_kodlari.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/il_secici_widget.dart';
import '../../../arac_profili/presentation/screens/arac_profil_screen.dart';
import '../../../bildirimler/presentation/screens/bildirim_ayarlari_screen.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../providers/ayarlar_provider.dart';

class AyarlarScreen extends ConsumerWidget {
  const AyarlarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final varsayilanIl = ref.watch(varsayilanIlProvider);
    final cacheTtl = ref.watch(cacheTtlProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.ayarlar)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ─── Görünüm ──────────────────────────────────
          _SectionHeader(
            title: l.gorunum,
            icon: Icons.palette,
            color: Colors.purple,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.settings_brightness,
                    color: Colors.purple,
                  ),
                  title: Text(l.tema),
                  subtitle: Text(_themeModeLabel(l, themeMode)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode, size: 18),
                        label: Text(
                          l.acik,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.settings_brightness, size: 18),
                        label: Text(
                          l.sistem,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode, size: 18),
                        label: Text(
                          l.koyu,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(s.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── Dil ────────────────────────────────────
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.teal),
                  title: Text(l.dilLanguage),
                  subtitle: Text(
                    ref.watch(localeProvider).languageCode == 'tr'
                        ? 'Türkçe'
                        : 'English',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'tr',
                        label: Text('Türkçe', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text('English', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {ref.watch(localeProvider).languageCode},
                    onSelectionChanged: (s) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(s.first));
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Varsayılanlar ────────────────────────────
          _SectionHeader(
            title: l.varsayilanlar,
            icon: Icons.tune,
            color: Colors.blue,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.location_city, color: Colors.blue),
              title: Text(l.varsayilanIl),
              subtitle: Text(
                varsayilanIl != null
                    ? IlKodlari.getIlAdi(varsayilanIl)
                    : l.secilmedi,
                style: TextStyle(
                  color: varsayilanIl != null ? null : Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: IlSeciciWidget(
                      seciliIlKodu: varsayilanIl,
                      hintText: l.varsayilanIlAra,
                      onIlSecildi: (ilKodu) {
                        ref.read(varsayilanIlProvider.notifier).setIl(ilKodu);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blue),
              title: Text(l.araclarim),
              subtitle: Text(l.aracProfilleriYonet),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AracProfilScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Önbellek ─────────────────────────────────
          _SectionHeader(
            title: l.veriYonetimi,
            icon: Icons.storage,
            color: Colors.orange,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer, color: Colors.orange),
                  title: Text(l.onbellekSuresi),
                  subtitle: Text(l.onbellekAciklama),
                  trailing: DropdownButton<int>(
                    value: cacheTtl,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 3600, child: Text(l.birSaat)),
                      DropdownMenuItem(value: 10800, child: Text(l.ucSaat)),
                      DropdownMenuItem(value: 21600, child: Text(l.altiSaat)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(cacheTtlProvider.notifier).setTtl(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // Cache bilgisi
                Consumer(
                  builder: (context, ref, _) {
                    final cm = ref.watch(cacheManagerProvider);
                    final keys = cm.getCachedKeys();
                    final ilCount = keys
                        .where((k) => k.startsWith('cache_fiyat_'))
                        .length;
                    return ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                      ),
                      title: Text(
                        l.ilVerisiOnbellekte(ilCount),
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        l.toplamCacheKaydi(keys.length),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.zamKirmizi,
                  ),
                  title: Text(l.onbellegiTemizle),
                  subtitle: Text(l.tumKayitliVerileriSil),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.onbellegiTemizle),
                        content: Text(l.onbellekSilinecekUyari),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l.iptal),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l.temizle),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final cm = ref.read(cacheManagerProvider);
                      final stats = cm.getCacheStats();
                      await cm.clear();
                      // Provider'ları invalidate et
                      ref.invalidate(ilFiyatlariProvider);
                      ref.invalidate(top8FirmaFiyatlariProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${l.onbellekTemizlendi} (${stats.keyCount} kayıt silindi)',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Bildirimler ──────────────────────────────
          _SectionHeader(
            title: l.bildirimler,
            icon: Icons.notifications,
            color: AppColors.benzinTuruncu,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: AppColors.benzinTuruncu,
              ),
              title: Text(l.bildirimAyarlari),
              subtitle: Text(l.zamIndirimBildirim),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BildirimAyarlariScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Hakkında ─────────────────────────────────
          _SectionHeader(
            title: l.hakkinda,
            icon: Icons.info,
            color: Colors.teal,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.local_gas_station,
                    color: AppColors.primaryLight,
                  ),
                  title: Text(
                    'YakıtCep',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('v1.0.0'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.shield, color: Colors.teal),
                  title: Text(l.veriKaynagi),
                  subtitle: Text(
                    l.epDKAciklama,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.green),
                  title: Text(l.harita),
                  subtitle: Text(
                    l.haritaAciklama,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.rss_feed, color: Colors.orange),
                  title: Text(l.haberler),
                  subtitle: Text(
                    l.haberKaynaklari,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '${l.acik} tema';
      case ThemeMode.dark:
        return '${l.koyu} tema';
      case ThemeMode.system:
        return '${l.sistem} temasını takip eder';
    }
  }
}

// ─── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
