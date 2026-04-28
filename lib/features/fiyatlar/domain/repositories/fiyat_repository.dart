import '../entities/akaryakit_fiyat.dart';
import '../entities/il_fiyat_ozet.dart';

abstract class FiyatRepository {
  Future<List<AkaryakitFiyat>> getIlFiyatlari(String ilKodu);
  Future<List<AkaryakitFiyat>> getTop8FirmaFiyatlari();
  Future<List<AkaryakitFiyat>> getLpgFiyatlari(String ilKodu);
  Future<IlFiyatOzet> getIlOzet(String ilKodu, String ilAdi);
}
