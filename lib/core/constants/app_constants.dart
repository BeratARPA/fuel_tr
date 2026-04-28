class AppConstants {
  AppConstants._();

  static const Duration defaultCacheTtl = Duration(hours: 1);
  static const Duration haberCacheTtl = Duration(minutes: 30);
  static const Duration previousPriceTtl = Duration(hours: 48);
  static const Duration soapTimeout = Duration(seconds: 10);
  static const Duration rssTimeout = Duration(seconds: 10);
  static const int maxRetry = 3;
  static const int maxFavori = 5;
  static const int maxKarsilastirmaIl = 4;
  static const double defaultZamEsigi = 1.5;
  static const double defaultDusmeEsigi = 1.0;
  static const Duration backgroundTaskFrequency = Duration(hours: 6);
}
