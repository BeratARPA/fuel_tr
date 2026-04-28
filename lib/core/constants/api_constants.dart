class ApiConstants {
  ApiConstants._();

  /// Akaryakıt fiyat API (JSON) — EPDK verilerini sunar
  static const String fiyatApiBaseUrl =
      'https://hasanadiguzel.com.tr/api/akaryakit';

  /// EPDK SOAP (yedek - erişilebilirlik değişken)
  static const String petrolBaseUrl =
      'https://lisansws.epdk.gov.tr/services/yayin';
  static const String lpgBaseUrl =
      'https://lisansws.epdk.gov.tr/services/bildirimLPGTarife';
  static const String soapAction = '';
  static const String namespace =
      'http://genel.service.ws.epvys.g222.tubitak.gov.tr/';
  static const String lpgNamespace =
      'http://genel.services.ws.epvys.g222.tubitak.gov.tr/';

  static const int sorguIlFiyatlari = 72;
  static const int sorguTop8Firma = 71;
  static const int sorguLpgIlFiyatlari = 54;

  // ─── RSS Kaynakları ──────────────────────────────────────
  // Sadece akaryakıt odaklı arama sorguları — genel ekonomi RSS'leri kaldırıldı
  static const List<String> rssUrls = [
    'https://news.google.com/rss/search?q=akaryak%C4%B1t+zam+OR+indirim&hl=tr&gl=TR&ceid=TR:tr',
    'https://news.google.com/rss/search?q=benzin+motorin+fiyat+zamland%C4%B1+OR+indirim&hl=tr&gl=TR&ceid=TR:tr',
    'https://news.google.com/rss/search?q=benzin+fiyat%C4%B1+bug%C3%BCn&hl=tr&gl=TR&ceid=TR:tr',
    'https://news.google.com/rss/search?q=motorin+fiyat%C4%B1+bug%C3%BCn&hl=tr&gl=TR&ceid=TR:tr',
    'https://news.google.com/rss/search?q=LPG+otogaz+fiyat&hl=tr&gl=TR&ceid=TR:tr',
    'https://news.google.com/rss/search?q=EPDK+akaryak%C4%B1t&hl=tr&gl=TR&ceid=TR:tr',
  ];

  // ─── Akaryakıt İlişki Filtresi ──────────────────────────
  // Bir haberin akaryakıtla ilgili sayılabilmesi için
  // EN AZ BİR yakıt kelimesi + EN AZ BİR bağlam kelimesi gerekir.
  //
  // Tek başına "zam" veya "artış" yetmez — "benzin zamlandı" olmalı.

  /// Yakıt türü kelimeleri — bunlardan en az biri ZORUNLU
  static const List<String> yakitKelimeleri = [
    'akaryakıt',
    'benzin',
    'motorin',
    'dizel',
    'lpg',
    'otogaz',
    'kurşunsuz',
    'mazot',
    'pompa',
    'yakıt fiyat',
    'litre fiyat',
  ];

  /// Bağlam kelimeleri — yakıt kelimesiyle birlikte aranır
  static const List<String> baglamKelimeleri = [
    'zam',
    'indirim',
    'artış',
    'düşüş',
    'fiyat',
    'zamlandı',
    'ucuzladı',
    'pahalandı',
    'yükseldi',
    'düştü',
    'arttı',
    'azaldı',
    'güncellendi',
    'değişti',
    'belirlendi',
  ];

  /// Tek başına yeterli olan çok spesifik ifadeler
  /// Bu ifadeler zaten akaryakıta özgü oldukları için ek filtre gerekmez
  static const List<String> kesinAkaryakitIfadeleri = [
    'benzin zamlandı',
    'motorin zamlandı',
    'benzin fiyatı',
    'motorin fiyatı',
    'akaryakıt zam',
    'akaryakıt indirim',
    'akaryakıt fiyat',
    'pompa fiyat',
    'litre fiyat',
    'lpg fiyat',
    'otogaz fiyat',
    'epdk fiyat',
    'benzin ne kadar',
    'motorin ne kadar',
    'mazot fiyat',
    'yakıt zamlandı',
    'yakıt ucuzladı',
    'benzin ucuzladı',
    'motorin ucuzladı',
    'kuruş zam',
    'kuruş indirim',
    'benzin arttı',
    'motorin arttı',
    'benzin düştü',
    'motorin düştü',
  ];

  /// Bu kelimeler varsa haberi REDDET (yanlış eşleşmeleri önlemek için)
  static const List<String> karaListeKelimeleri = [
    'doğalgaz fatura',
    'elektrik fatura',
    'konut kira',
    'altın fiyat',
    'bitcoin',
    'kripto',
    'borsa endeks',
    'faiz kararı',
  ];
}
