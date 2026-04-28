import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../arac_profili/presentation/providers/arac_profil_provider.dart';
import '../../domain/entities/yakit_kayit.dart';
import '../providers/yakit_defteri_provider.dart';

class YakitKayitEkleScreen extends ConsumerStatefulWidget {
  const YakitKayitEkleScreen({super.key});

  @override
  ConsumerState<YakitKayitEkleScreen> createState() =>
      _YakitKayitEkleScreenState();
}

class _YakitKayitEkleScreenState extends ConsumerState<YakitKayitEkleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litreController = TextEditingController();
  final _tutarController = TextEditingController();
  final _kmController = TextEditingController();
  final _notController = TextEditingController();

  DateTime _tarih = DateTime.now();
  String _yakitTipi = 'benzin';
  String? _aracId;

  @override
  void initState() {
    super.initState();
    // Aktif araç varsa otomatik doldur
    final aktifArac = ref.read(aktifAracProfilProvider);
    if (aktifArac != null) {
      _yakitTipi = aktifArac.yakitTipi;
      _aracId = aktifArac.id;
    }
  }

  @override
  void dispose() {
    _litreController.dispose();
    _tutarController.dispose();
    _kmController.dispose();
    _notController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.yeniYakitKaydi)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarih seçici
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryLight,
              ),
              title: Text(l.tarih),
              subtitle: Text(
                DateFormat('dd MMMM yyyy, HH:mm', 'tr').format(_tarih),
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _tarih,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  locale: const Locale('tr'),
                );
                if (date != null && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_tarih),
                  );
                  setState(() {
                    _tarih = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time?.hour ?? _tarih.hour,
                      time?.minute ?? _tarih.minute,
                    );
                  });
                }
              },
            ),
            const Divider(),

            // Araç seçimi
            Consumer(
              builder: (context, ref, _) {
                final araclar = ref.watch(aracProfilProvider);
                if (araclar.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.arac, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: _aracId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l.aracSecilmedi),
                        ),
                        ...araclar.map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text('${a.ad} (${a.yakitTipi})'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _aracId = v;
                          if (v != null) {
                            final arac = araclar.firstWhere((a) => a.id == v);
                            _yakitTipi = arac.yakitTipi;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

            // Yakıt tipi
            const SizedBox(height: 8),
            Text(l.yakitTipi, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'benzin',
                  icon: const Icon(Icons.local_gas_station, size: 16),
                  label: Text(l.benzin),
                ),
                ButtonSegment(
                  value: 'motorin',
                  icon: const Icon(Icons.local_gas_station, size: 16),
                  label: Text(l.motorin),
                ),
                ButtonSegment(
                  value: 'lpg',
                  icon: const Icon(Icons.local_gas_station, size: 16),
                  label: Text(l.lpg),
                ),
              ],
              selected: {_yakitTipi},
              onSelectionChanged: (s) => setState(() => _yakitTipi = s.first),
            ),
            const SizedBox(height: 16),

            // Litre ve Tutar
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _litreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.litre,
                      suffixText: 'L',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.water_drop),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.zorunlu;
                      if (double.tryParse(v) == null) return l.gecersiz;
                      return null;
                    },
                    onChanged: (_) => _otomatikHesapla(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tutarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.tutar,
                      suffixText: '₺',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.zorunlu;
                      if (double.tryParse(v) == null) return l.gecersiz;
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // Litre fiyat göstergesi
            if (_litreController.text.isNotEmpty &&
                _tutarController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Builder(
                  builder: (context) {
                    final litre = double.tryParse(_litreController.text) ?? 0;
                    final tutar = double.tryParse(_tutarController.text) ?? 0;
                    if (litre > 0 && tutar > 0) {
                      return Text(
                        '${l.litreFiyati}: ${(tutar / litre).toStringAsFixed(2)}₺/L',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Km sayacı (opsiyonel)
            TextFormField(
              controller: _kmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.kmSayaci,
                suffixText: 'km',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.speed),
                helperText: l.kmSayaciNot,
              ),
            ),
            const SizedBox(height: 16),

            // Not (opsiyonel)
            TextFormField(
              controller: _notController,
              decoration: InputDecoration(
                labelText: l.notOpsiyonel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.note),
                hintText: l.orneginNot,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Kaydet butonu
            FilledButton.icon(
              onPressed: _kaydet,
              icon: const Icon(Icons.save),
              label: Text(l.kaydet),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _otomatikHesapla() {
    // Otomatik hesaplama tetikle
    setState(() {});
  }

  void _kaydet() {
    if (!_formKey.currentState!.validate()) return;

    final kayit = YakitKayit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tarih: _tarih,
      litre: double.parse(_litreController.text),
      tutar: double.parse(_tutarController.text),
      kmSayaci: _kmController.text.isNotEmpty
          ? double.tryParse(_kmController.text)
          : null,
      yakitTipi: _yakitTipi,
      not: _notController.text.isNotEmpty ? _notController.text : null,
      aracId: _aracId,
    );

    ref.read(yakitDefteriProvider.notifier).ekle(kayit);
    Navigator.pop(context);

    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.kayitEklendi),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
