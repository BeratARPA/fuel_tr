import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/widget_updater.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(sharedPreferencesProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    final saved = _prefs.getString('pref_tema');
    if (saved == 'light') state = ThemeMode.light;
    if (saved == 'dark') state = ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    switch (mode) {
      case ThemeMode.light:
        _prefs.setString('pref_tema', 'light');
      case ThemeMode.dark:
        _prefs.setString('pref_tema', 'dark');
      case ThemeMode.system:
        _prefs.setString('pref_tema', 'system');
    }
  }
}

final varsayilanIlProvider =
    StateNotifierProvider<VarsayilanIlNotifier, String?>(
      (ref) => VarsayilanIlNotifier(ref.watch(sharedPreferencesProvider)),
    );

class VarsayilanIlNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;

  VarsayilanIlNotifier(this._prefs)
    : super(_prefs.getString('pref_varsayilan_il'));

  void setIl(String ilKodu) {
    state = ilKodu;
    _prefs.setString('pref_varsayilan_il', ilKodu).then((_) {
      WidgetUpdater.fetchAndUpdateDataFromBackground();
    });
    _prefs.setBool('ilk_acilis_yapildi', true);
  }

  bool get ilkAcilisYapildi => _prefs.getBool('ilk_acilis_yapildi') ?? false;

  void markIlkAcilisDone() {
    _prefs.setBool('ilk_acilis_yapildi', true);
  }
}

/// Dil seçimi provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(sharedPreferencesProvider)),
);

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(const Locale('tr')) {
    final saved = _prefs.getString('pref_locale');
    if (saved != null) state = Locale(saved);
  }

  void setLocale(Locale locale) {
    state = locale;
    _prefs.setString('pref_locale', locale.languageCode);
  }
}

final cacheTtlProvider = StateNotifierProvider<CacheTtlNotifier, int>(
  (ref) => CacheTtlNotifier(ref.watch(sharedPreferencesProvider)),
);

class CacheTtlNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;

  CacheTtlNotifier(this._prefs)
    : super(_prefs.getInt('pref_cache_ttl') ?? 3600);

  void setTtl(int seconds) {
    state = seconds;
    _prefs.setInt('pref_cache_ttl', seconds);
  }
}
