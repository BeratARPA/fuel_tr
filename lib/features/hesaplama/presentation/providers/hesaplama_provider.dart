import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../fiyatlar/presentation/providers/fiyat_provider.dart';
import '../../data/datasources/osrm_datasource.dart';

final osrmDatasourceProvider = Provider<OsrmDatasource>((ref) {
  return OsrmDatasource(ref.watch(httpClientProvider));
});

/// Seçili yakıt tipi
final yakitTipiProvider = StateProvider<String>((ref) => 'benzin');

/// Ortalama tüketim (L/100km)
final tuketimProvider = StateProvider<double>((ref) => 7.0);

/// Depo kapasitesi (L)
final depoKapasitesiProvider = StateProvider<double>((ref) => 50.0);

/// Başlangıç noktası
final baslangicProvider = StateProvider<LatLng?>((ref) => null);

/// Varış noktası
final varisProvider = StateProvider<LatLng?>((ref) => null);

/// Başlangıç adres text
final baslangicAdresProvider = StateProvider<String>((ref) => '');

/// Varış adres text
final varisAdresProvider = StateProvider<String>((ref) => '');

/// Ara noktalar (waypoints) — konum + label çifti
final araNoktalarProvider =
    StateNotifierProvider<AraNoktalarNotifier, List<RotaNokta>>(
      (ref) => AraNoktalarNotifier(),
    );

class RotaNokta {
  final LatLng konum;
  final String label;
  const RotaNokta({required this.konum, required this.label});
}

class AraNoktalarNotifier extends StateNotifier<List<RotaNokta>> {
  AraNoktalarNotifier() : super([]);

  void ekle(RotaNokta nokta) {
    if (state.length < 5) {
      state = [...state, nokta];
    }
  }

  void kaldir(int index) {
    state = [...state]..removeAt(index);
  }

  void temizle() => state = [];
}

/// Rota hesaplama — başlangıç + ara noktalar + varış
final rotaProvider = FutureProvider.autoDispose<RotaSonuc?>((ref) async {
  final baslangic = ref.watch(baslangicProvider);
  final varis = ref.watch(varisProvider);
  final araNoktalar = ref.watch(araNoktalarProvider);

  if (baslangic == null || varis == null) return null;

  final ds = ref.watch(osrmDatasourceProvider);
  return ds.getRoute(
    baslangic,
    varis,
    araNoktalar: araNoktalar.map((n) => n.konum).toList(),
  );
});
