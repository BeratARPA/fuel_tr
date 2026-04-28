import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/widget_updater.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';

final favoriProvider = StateNotifierProvider<FavoriNotifier, List<String>>(
  (ref) => FavoriNotifier(ref.watch(sharedPreferencesProvider)),
);

class FavoriNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'favori_iller';

  FavoriNotifier(this._prefs)
    : super(_prefs.getStringList('favori_iller') ?? []);

  bool addFavori(String ilKodu) {
    if (state.length >= AppConstants.maxFavori) return false;
    if (state.contains(ilKodu)) return true;
    state = [...state, ilKodu];
    _prefs.setStringList(_key, state).then((_) {
      WidgetUpdater.fetchAndUpdateDataFromBackground(overrideIller: state);
    });
    return true;
  }

  void removeFavori(String ilKodu) {
    state = state.where((k) => k != ilKodu).toList();
    _prefs.setStringList(_key, state).then((_) {
      WidgetUpdater.fetchAndUpdateDataFromBackground(overrideIller: state);
    });
  }

  bool isFavori(String ilKodu) => state.contains(ilKodu);
}
