import '../entities/haber.dart';

abstract class HaberRepository {
  Future<List<Haber>> getZamHaberleri();
}
