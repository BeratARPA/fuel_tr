import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../domain/entities/bildirim_ayari.dart';

final bildirimAyariProvider =
    StateNotifierProvider<BildirimAyariNotifier, BildirimAyari>(
      (ref) => BildirimAyariNotifier(ref.watch(sharedPreferencesProvider)),
    );

class BildirimAyariNotifier extends StateNotifier<BildirimAyari> {
  final SharedPreferences _prefs;
  static const _key = 'bildirim_ayarlari';

  BildirimAyariNotifier(this._prefs) : super(const BildirimAyari()) {
    _load();
  }

  void _load() {
    final json = _prefs.getString(_key);
    if (json != null) {
      state = BildirimAyari.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  void update(BildirimAyari ayar) {
    state = ayar;
    _save();
  }

  void toggleAktif() => update(state.copyWith(aktif: !state.aktif));
  void toggleBenzinZam() => update(state.copyWith(benzinZam: !state.benzinZam));
  void toggleMotorinZam() =>
      update(state.copyWith(motorinZam: !state.motorinZam));
  void toggleLpgZam() => update(state.copyWith(lpgZam: !state.lpgZam));
  void toggleHaberBildirim() =>
      update(state.copyWith(haberBildirim: !state.haberBildirim));
  void toggleHaftalikOzet() =>
      update(state.copyWith(haftalikOzet: !state.haftalikOzet));
  void setZamEsigi(double esik) => update(state.copyWith(zamEsigi: esik));
}
