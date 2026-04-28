import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/bildirim_provider.dart';

class BildirimAyarlariScreen extends ConsumerWidget {
  const BildirimAyarlariScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final ayar = ref.watch(bildirimAyariProvider);
    final notifier = ref.read(bildirimAyariProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.bildirimAyarlari)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Ana toggle — büyük kart
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: ayar.aktif
                ? AppColors.primaryLight.withValues(alpha: 0.1)
                : null,
            child: SwitchListTile(
              title: Text(
                l.bildirimlerAcikKapali,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                ayar.aktif ? l.bildirimlerAktif : l.tumBildirimlerKapali,
                style: TextStyle(
                  fontSize: 12,
                  color: ayar.aktif ? AppColors.indirimYesil : Colors.grey,
                ),
              ),
              secondary: Icon(
                ayar.aktif
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: ayar.aktif ? AppColors.primaryLight : Colors.grey,
                size: 28,
              ),
              value: ayar.aktif,
              onChanged: (_) => notifier.toggleAktif(),
            ),
          ),

          if (!ayar.aktif)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.bildirimAciklamaMetni,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ─── Fiyat Bildirimleri ───────────────────────
          _SectionHeader(
            title: l.fiyatBildirimleri,
            icon: Icons.local_gas_station,
            color: AppColors.benzinTuruncu,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _BildirimToggle(
                  icon: Icons.local_gas_station,
                  iconColor: AppColors.benzinTuruncu,
                  title: l.benzinZamBildirimi,
                  subtitle: l.benzinDegisince,
                  value: ayar.benzinZam,
                  enabled: ayar.aktif,
                  onChanged: (_) => notifier.toggleBenzinZam(),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _BildirimToggle(
                  icon: Icons.local_gas_station,
                  iconColor: AppColors.motorinMavi,
                  title: l.motorinZamBildirimi,
                  subtitle: l.motorinDegisince,
                  value: ayar.motorinZam,
                  enabled: ayar.aktif,
                  onChanged: (_) => notifier.toggleMotorinZam(),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _BildirimToggle(
                  icon: Icons.local_gas_station,
                  iconColor: AppColors.lpgMor,
                  title: l.lpgZamBildirimi,
                  subtitle: l.lpgDegisince,
                  value: ayar.lpgZam,
                  enabled: ayar.aktif,
                  onChanged: (_) => notifier.toggleLpgZam(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Diğer Bildirimler ────────────────────────
          _SectionHeader(
            title: l.digerBildirimler,
            icon: Icons.newspaper,
            color: Colors.blue,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _BildirimToggle(
                  icon: Icons.newspaper,
                  iconColor: Colors.blue,
                  title: l.haberBildirimi,
                  subtitle: l.zamIndirimHaberleri,
                  value: ayar.haberBildirim,
                  enabled: ayar.aktif,
                  onChanged: (_) => notifier.toggleHaberBildirim(),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _BildirimToggle(
                  icon: Icons.calendar_today,
                  iconColor: Colors.teal,
                  title: l.haftalikOzet,
                  subtitle: l.haftalikOzetAciklama,
                  value: ayar.haftalikOzet,
                  enabled: ayar.aktif,
                  onChanged: (_) => notifier.toggleHaftalikOzet(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ─── Bildirim Eşiği ───────────────────────────
          _SectionHeader(
            title: l.bildirimEsigi,
            icon: Icons.tune,
            color: Colors.deepPurple,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 18,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.zamEsigi,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '%${ayar.zamEsigi.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.zamEsigiAciklama,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Slider(
                    value: ayar.zamEsigi,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    label: '%${ayar.zamEsigi.toStringAsFixed(1)}',
                    onChanged: ayar.aktif
                        ? (v) => notifier.setZamEsigi(v)
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '%1 (${l.hassas})',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      Text(
                        '%5 (${l.sadeceBuyukZamlar})',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ─── Test ─────────────────────────────────────
          _SectionHeader(
            title: l.test,
            icon: Icons.science,
            color: Colors.grey,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.send, color: Colors.grey),
              title: Text(l.testBildirimiGonder),
              subtitle: Text(l.bildirimleriDogrula),
              trailing: OutlinedButton(
                onPressed: () async {
                  final plugin = FlutterLocalNotificationsPlugin();

                  // Android 13+ bildirim izni iste
                  final android = plugin
                      .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin
                      >();
                  if (android != null) {
                    final granted = await android
                        .requestNotificationsPermission();
                    if (granted != true) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.bildirimlerCalisiyor),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return;
                    }
                  }

                  await plugin.show(
                    7777,
                    'YakıtCep ${l.test}',
                    '${l.bildirimlerCalisiyor} 🎉',
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        'yakit_test',
                        l.testBildirimleri,
                        importance: Importance.high,
                        priority: Priority.high,
                      ),
                      iOS: const DarwinNotificationDetails(),
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.testBildirimGonderildi),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(l.gonder, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
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

// ─── Bildirim Toggle ───────────────────────────────────────
class _BildirimToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BildirimToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: enabled ? iconColor : Colors.grey, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: enabled ? null : Colors.grey),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}
