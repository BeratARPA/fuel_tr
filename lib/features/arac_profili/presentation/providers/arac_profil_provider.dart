import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../domain/entities/arac_profil.dart';

final aracProfilProvider =
    StateNotifierProvider<AracProfilNotifier, List<AracProfil>>(
      (ref) => AracProfilNotifier(ref.watch(sharedPreferencesProvider)),
    );

/// Aktif (seçili) araç
final aktifAracProvider = StateNotifierProvider<AktifAracNotifier, String?>(
  (ref) => AktifAracNotifier(ref.watch(sharedPreferencesProvider)),
);

/// Aktif araç profili (computed)
final aktifAracProfilProvider = Provider<AracProfil?>((ref) {
  final araclar = ref.watch(aracProfilProvider);
  final aktifId = ref.watch(aktifAracProvider);
  if (aktifId == null || araclar.isEmpty) return null;
  return araclar.where((a) => a.id == aktifId).firstOrNull;
});

class AracProfilNotifier extends StateNotifier<List<AracProfil>> {
  final SharedPreferences _prefs;
  static const _key = 'arac_profiller';

  AracProfilNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final json = _prefs.getString(_key);
    if (json != null) {
      state = (jsonDecode(json) as List)
          .map((e) => AracProfil.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    await _prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void ekle(AracProfil profil) {
    state = [...state, profil];
    _save();
  }

  void sil(String id) {
    state = state.where((a) => a.id != id).toList();
    _save();
  }

  void guncelle(AracProfil profil) {
    state = state.map((a) => a.id == profil.id ? profil : a).toList();
    _save();
  }
}

class AktifAracNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  static const _key = 'aktif_arac_id';

  AktifAracNotifier(this._prefs) : super(_prefs.getString(_key));

  void setAktif(String? id) {
    state = id;
    if (id != null) {
      _prefs.setString(_key, id);
    } else {
      _prefs.remove(_key);
    }
  }
}
