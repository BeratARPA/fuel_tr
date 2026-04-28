import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/arac_profil.dart';
import '../providers/arac_profil_provider.dart';

class AracProfilScreen extends ConsumerWidget {
  const AracProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final araclar = ref.watch(aracProfilProvider);
    final aktifId = ref.watch(aktifAracProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.araclarim)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEkleDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.aracEkle),
      ),
      body: araclar.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    l.henuzAracYok,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.aracEntegrasyon,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: araclar.length,
              itemBuilder: (context, index) {
                final arac = araclar[index];
                final isAktif = arac.id == aktifId;
                final tipRenk = arac.yakitTipi == 'benzin'
                    ? AppColors.benzinTuruncu
                    : arac.yakitTipi == 'motorin'
                    ? AppColors.motorinMavi
                    : AppColors.lpgMor;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  color: isAktif
                      ? AppColors.primaryLight.withValues(alpha: 0.08)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tipRenk.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.directions_car,
                        color: tipRenk,
                        size: 22,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            arac.ad,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isAktif)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.indirimYesil.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l.aktif,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.indirimYesil,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${arac.yakitTipi.toUpperCase()} • '
                      '${arac.tuketim} L/100km • '
                      '${arac.depo.toInt()}L depo'
                      '${arac.plaka != null ? " • ${arac.plaka}" : ""}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'aktif') {
                          ref
                              .read(aktifAracProvider.notifier)
                              .setAktif(arac.id);
                        } else if (v == 'duzenle') {
                          _showDuzenleDialog(context, ref, arac);
                        } else if (v == 'sil') {
                          ref.read(aracProfilProvider.notifier).sil(arac.id);
                          if (isAktif) {
                            ref.read(aktifAracProvider.notifier).setAktif(null);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        if (!isAktif)
                          PopupMenuItem(
                            value: 'aktif',
                            child: Text(l.aktifYap),
                          ),
                        PopupMenuItem(value: 'duzenle', child: Text(l.duzenle)),
                        PopupMenuItem(value: 'sil', child: Text(l.sil)),
                      ],
                    ),
                    onTap: () =>
                        ref.read(aktifAracProvider.notifier).setAktif(arac.id),
                  ),
                );
              },
            ),
    );
  }

  void _showDuzenleDialog(
    BuildContext context,
    WidgetRef ref,
    AracProfil arac,
  ) {
    final l = AppLocalizations.of(context)!;
    final adController = TextEditingController(text: arac.ad);
    final tuketimController = TextEditingController(
      text: arac.tuketim.toString(),
    );
    final depoController = TextEditingController(text: arac.depo.toString());
    final plakaController = TextEditingController(text: arac.plaka ?? '');
    String yakitTipi = arac.yakitTipi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.araciDuzenle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adController,
                decoration: InputDecoration(
                  labelText: l.aracAdi,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: plakaController,
                decoration: InputDecoration(
                  labelText: l.plakaOpsiyonel,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'benzin', label: Text(l.benzin)),
                  ButtonSegment(value: 'motorin', label: Text(l.motorin)),
                  ButtonSegment(value: 'lpg', label: Text(l.lpg)),
                ],
                selected: {yakitTipi},
                onSelectionChanged: (s) =>
                    setModalState(() => yakitTipi = s.first),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tuketimController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.tuketim,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: depoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.depoKapasite,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (adController.text.isEmpty) return;
                    final updated = AracProfil(
                      id: arac.id,
                      ad: adController.text,
                      yakitTipi: yakitTipi,
                      tuketim:
                          double.tryParse(tuketimController.text) ??
                          arac.tuketim,
                      depo: double.tryParse(depoController.text) ?? arac.depo,
                      plaka: plakaController.text.isNotEmpty
                          ? plakaController.text
                          : null,
                      marka: arac.marka,
                      model: arac.model,
                    );
                    ref.read(aracProfilProvider.notifier).guncelle(updated);
                    Navigator.pop(ctx);
                  },
                  child: Text(l.guncelle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEkleDialog(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final adController = TextEditingController();
    final tuketimController = TextEditingController(text: '7.0');
    final depoController = TextEditingController(text: '50');
    final plakaController = TextEditingController();
    String yakitTipi = 'benzin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.yeniAracEkle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adController,
                decoration: InputDecoration(
                  labelText: l.aracAdi,
                  hintText: l.orneginAileArabasi,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: plakaController,
                decoration: InputDecoration(
                  labelText: l.plakaOpsiyonel,
                  hintText: l.orneginPlaka,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'benzin', label: Text(l.benzin)),
                  ButtonSegment(value: 'motorin', label: Text(l.motorin)),
                  ButtonSegment(value: 'lpg', label: Text(l.lpg)),
                ],
                selected: {yakitTipi},
                onSelectionChanged: (s) =>
                    setModalState(() => yakitTipi = s.first),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tuketimController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.tuketim,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: depoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.depoKapasite,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (adController.text.isEmpty) return;
                    final profil = AracProfil(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      ad: adController.text,
                      yakitTipi: yakitTipi,
                      tuketim: double.tryParse(tuketimController.text) ?? 7.0,
                      depo: double.tryParse(depoController.text) ?? 50,
                      plaka: plakaController.text.isNotEmpty
                          ? plakaController.text
                          : null,
                    );
                    ref.read(aracProfilProvider.notifier).ekle(profil);
                    // İlk araçsa otomatik aktif yap
                    if (ref.read(aracProfilProvider).length == 1) {
                      ref.read(aktifAracProvider.notifier).setAktif(profil.id);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(l.kaydet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
