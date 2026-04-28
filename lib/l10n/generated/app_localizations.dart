import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'YakıtCep'**
  String get appTitle;

  /// No description provided for @fiyatlar.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar'**
  String get fiyatlar;

  /// No description provided for @karsilastir.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştır'**
  String get karsilastir;

  /// No description provided for @haberler.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get haberler;

  /// No description provided for @hesapla.
  ///
  /// In tr, this message translates to:
  /// **'Hesapla'**
  String get hesapla;

  /// No description provided for @ayarlar.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get ayarlar;

  /// No description provided for @ulusalOrtalama.
  ///
  /// In tr, this message translates to:
  /// **'Ulusal Ortalama'**
  String get ulusalOrtalama;

  /// No description provided for @favorilerim.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerim'**
  String get favorilerim;

  /// No description provided for @tumIller.
  ///
  /// In tr, this message translates to:
  /// **'Tüm İller'**
  String get tumIller;

  /// No description provided for @ilAra.
  ///
  /// In tr, this message translates to:
  /// **'İl ara...'**
  String get ilAra;

  /// No description provided for @benzin95.
  ///
  /// In tr, this message translates to:
  /// **'Kurşunsuz 95'**
  String get benzin95;

  /// No description provided for @motorin.
  ///
  /// In tr, this message translates to:
  /// **'Motorin'**
  String get motorin;

  /// No description provided for @motorinPremium.
  ///
  /// In tr, this message translates to:
  /// **'Motorin (Premium)'**
  String get motorinPremium;

  /// No description provided for @lpg.
  ///
  /// In tr, this message translates to:
  /// **'LPG (Otogaz)'**
  String get lpg;

  /// No description provided for @litre.
  ///
  /// In tr, this message translates to:
  /// **'Litre'**
  String get litre;

  /// No description provided for @sonGuncelleme.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {zaman}'**
  String sonGuncelleme(String zaman);

  /// No description provided for @veriYok.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get veriYok;

  /// No description provided for @tekrarDene.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tekrarDene;

  /// No description provided for @fiyatlarYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar yüklenemedi'**
  String get fiyatlarYuklenemedi;

  /// No description provided for @enUcuzNeresi.
  ///
  /// In tr, this message translates to:
  /// **'En Ucuz Neresi?'**
  String get enUcuzNeresi;

  /// No description provided for @ilSecin.
  ///
  /// In tr, this message translates to:
  /// **'İl seçin ({sayi}/{maks})'**
  String ilSecin(int sayi, int maks);

  /// No description provided for @temizle.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get temizle;

  /// No description provided for @zamBeklentisi.
  ///
  /// In tr, this message translates to:
  /// **'Zam Beklentisi'**
  String get zamBeklentisi;

  /// No description provided for @indirimBeklentisi.
  ///
  /// In tr, this message translates to:
  /// **'İndirim Beklentisi'**
  String get indirimBeklentisi;

  /// No description provided for @tumu.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get tumu;

  /// No description provided for @son24Saat.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 Saat'**
  String get son24Saat;

  /// No description provided for @buHafta.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get buHafta;

  /// No description provided for @haberAra.
  ///
  /// In tr, this message translates to:
  /// **'Haber ara...'**
  String get haberAra;

  /// No description provided for @tema.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get tema;

  /// No description provided for @acik.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get acik;

  /// No description provided for @koyu.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get koyu;

  /// No description provided for @sistem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get sistem;

  /// No description provided for @onbellekSuresi.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek Süresi'**
  String get onbellekSuresi;

  /// No description provided for @onbellegiTemizle.
  ///
  /// In tr, this message translates to:
  /// **'Önbelleği Temizle'**
  String get onbellegiTemizle;

  /// No description provided for @bildirimAyarlari.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get bildirimAyarlari;

  /// No description provided for @araclarim.
  ///
  /// In tr, this message translates to:
  /// **'Araçlarım'**
  String get araclarim;

  /// No description provided for @yakitDefteri.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Defteri'**
  String get yakitDefteri;

  /// No description provided for @dovizEtkisi.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Etkisi'**
  String get dovizEtkisi;

  /// No description provided for @fiyatHaritasi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Haritası'**
  String get fiyatHaritasi;

  /// No description provided for @yakinIstasyonlar.
  ///
  /// In tr, this message translates to:
  /// **'Yakın İstasyonlar'**
  String get yakinIstasyonlar;

  /// No description provided for @hesaplaBaslik.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Hesapla'**
  String get hesaplaBaslik;

  /// No description provided for @aracBilgileri.
  ///
  /// In tr, this message translates to:
  /// **'Araç Bilgileri'**
  String get aracBilgileri;

  /// No description provided for @tuketim.
  ///
  /// In tr, this message translates to:
  /// **'Tüketim (L/100km)'**
  String get tuketim;

  /// No description provided for @depoKapasite.
  ///
  /// In tr, this message translates to:
  /// **'Depo (Litre)'**
  String get depoKapasite;

  /// No description provided for @fiyatIli.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat ili'**
  String get fiyatIli;

  /// No description provided for @rotaSecimi.
  ///
  /// In tr, this message translates to:
  /// **'Rota Seçimi'**
  String get rotaSecimi;

  /// No description provided for @baslangicNoktasi.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç noktası seç'**
  String get baslangicNoktasi;

  /// No description provided for @varisNoktasi.
  ///
  /// In tr, this message translates to:
  /// **'Varış noktası seç'**
  String get varisNoktasi;

  /// No description provided for @haritadaSec.
  ///
  /// In tr, this message translates to:
  /// **'Haritada seç'**
  String get haritadaSec;

  /// No description provided for @listedenSec.
  ///
  /// In tr, this message translates to:
  /// **'Listeden seç'**
  String get listedenSec;

  /// No description provided for @hesaplaSonuclar.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplama Sonuçları'**
  String get hesaplaSonuclar;

  /// No description provided for @toplamMesafe.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Mesafe'**
  String get toplamMesafe;

  /// No description provided for @tahminiSure.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Süre'**
  String get tahminiSure;

  /// No description provided for @toplamYakitTuketimi.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Yakıt Tüketimi'**
  String get toplamYakitTuketimi;

  /// No description provided for @toplamMaliyet.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Maliyet'**
  String get toplamMaliyet;

  /// No description provided for @kmBasinaMaliyet.
  ///
  /// In tr, this message translates to:
  /// **'Km Başına Maliyet'**
  String get kmBasinaMaliyet;

  /// No description provided for @depoYeterliMi.
  ///
  /// In tr, this message translates to:
  /// **'Depo Yeterli mi?'**
  String get depoYeterliMi;

  /// No description provided for @paylas.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get paylas;

  /// No description provided for @internetYok.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok. Önbellek verileri gösteriliyor.'**
  String get internetYok;

  /// No description provided for @hakkinda.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get hakkinda;

  /// No description provided for @versiyon.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get versiyon;

  /// No description provided for @akaryakitHaberleri.
  ///
  /// In tr, this message translates to:
  /// **'Akaryakıt Haberleri'**
  String get akaryakitHaberleri;

  /// No description provided for @aktif.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get aktif;

  /// No description provided for @aktifYap.
  ///
  /// In tr, this message translates to:
  /// **'Aktif yap'**
  String get aktifYap;

  /// No description provided for @altiSaat.
  ///
  /// In tr, this message translates to:
  /// **'6 Saat'**
  String get altiSaat;

  /// No description provided for @arac.
  ///
  /// In tr, this message translates to:
  /// **'Araç'**
  String get arac;

  /// No description provided for @aracAdi.
  ///
  /// In tr, this message translates to:
  /// **'Araç Adı'**
  String get aracAdi;

  /// No description provided for @aracEkle.
  ///
  /// In tr, this message translates to:
  /// **'Araç Ekle'**
  String get aracEkle;

  /// No description provided for @aracEntegrasyon.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplama ve defterle entegre çalışır'**
  String get aracEntegrasyon;

  /// No description provided for @aracProfilleriYonet.
  ///
  /// In tr, this message translates to:
  /// **'Araç profilleri yönet'**
  String get aracProfilleriYonet;

  /// No description provided for @aracSec.
  ///
  /// In tr, this message translates to:
  /// **'Araç Seç'**
  String get aracSec;

  /// No description provided for @aracSecilmedi.
  ///
  /// In tr, this message translates to:
  /// **'Araç seçilmedi'**
  String get aracSecilmedi;

  /// No description provided for @araciDuzenle.
  ///
  /// In tr, this message translates to:
  /// **'Aracı Düzenle'**
  String get araciDuzenle;

  /// No description provided for @artisBekleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Artış bekleniyor'**
  String get artisBekleniyor;

  /// No description provided for @aylikHarcama.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Harcama'**
  String get aylikHarcama;

  /// No description provided for @aylikRapor.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Rapor'**
  String get aylikRapor;

  /// No description provided for @bayiMarji.
  ///
  /// In tr, this message translates to:
  /// **'Bayi Marjı'**
  String get bayiMarji;

  /// No description provided for @benzin.
  ///
  /// In tr, this message translates to:
  /// **'Benzin'**
  String get benzin;

  /// No description provided for @benzinDegisince.
  ///
  /// In tr, this message translates to:
  /// **'Benzin fiyatı değişince bildir'**
  String get benzinDegisince;

  /// No description provided for @benzinZamBildirimi.
  ///
  /// In tr, this message translates to:
  /// **'Benzin Zam Bildirimi'**
  String get benzinZamBildirimi;

  /// No description provided for @bildirimEsigi.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Eşiği'**
  String get bildirimEsigi;

  /// No description provided for @bildirimler.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get bildirimler;

  /// No description provided for @bildirimlerAcikKapali.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri Açık/Kapalı'**
  String get bildirimlerAcikKapali;

  /// No description provided for @bildirimlerAktif.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler aktif'**
  String get bildirimlerAktif;

  /// No description provided for @bildirimleriDogrula.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlerin çalıştığını doğrula'**
  String get bildirimleriDogrula;

  /// No description provided for @bilgi.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get bilgi;

  /// No description provided for @birSaat.
  ///
  /// In tr, this message translates to:
  /// **'1 Saat'**
  String get birSaat;

  /// No description provided for @buAy.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get buAy;

  /// No description provided for @buFiltredeHaberYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtrede haber bulunamadı'**
  String get buFiltredeHaberYok;

  /// No description provided for @buIlIcinVeriYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu il için fiyat verisi bulunamadı'**
  String get buIlIcinVeriYok;

  /// No description provided for @buYakitIcinVeriYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu yakıt tipi için veri yok'**
  String get buYakitIcinVeriYok;

  /// No description provided for @buYaricaptaYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu yarıçapta istasyon bulunamadı'**
  String get buYaricaptaYok;

  /// No description provided for @dagiticiBayi.
  ///
  /// In tr, this message translates to:
  /// **'Dağıtıcı+Bayi'**
  String get dagiticiBayi;

  /// No description provided for @dagiticiMarji.
  ///
  /// In tr, this message translates to:
  /// **'Dağıtıcı Marjı'**
  String get dagiticiMarji;

  /// No description provided for @depoMenzili.
  ///
  /// In tr, this message translates to:
  /// **'Depo Menzili'**
  String get depoMenzili;

  /// No description provided for @depoSayisi.
  ///
  /// In tr, this message translates to:
  /// **'Depo Sayısı'**
  String get depoSayisi;

  /// No description provided for @detay.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get detay;

  /// No description provided for @digerBildirimler.
  ///
  /// In tr, this message translates to:
  /// **'Diğer Bildirimler'**
  String get digerBildirimler;

  /// No description provided for @dilLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get dilLanguage;

  /// No description provided for @dolar.
  ///
  /// In tr, this message translates to:
  /// **'Dolar'**
  String get dolar;

  /// No description provided for @dolarDegisirse.
  ///
  /// In tr, this message translates to:
  /// **'Dolar değişirse benzin ne olur?'**
  String get dolarDegisirse;

  /// No description provided for @dovizEtkisiSimulasyonu.
  ///
  /// In tr, this message translates to:
  /// **'Döviz Etkisi Simülasyonu'**
  String get dovizEtkisiSimulasyonu;

  /// No description provided for @dususBekleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Düşüş bekleniyor'**
  String get dususBekleniyor;

  /// No description provided for @duzenle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get duzenle;

  /// No description provided for @enAz2Il.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırmak için en az 2 il seçin'**
  String get enAz2Il;

  /// No description provided for @enPahalidan.
  ///
  /// In tr, this message translates to:
  /// **'En pahalıdan ucuza'**
  String get enPahalidan;

  /// No description provided for @enUcuzdan.
  ///
  /// In tr, this message translates to:
  /// **'En ucuzdan pahalıya'**
  String get enUcuzdan;

  /// No description provided for @fark.
  ///
  /// In tr, this message translates to:
  /// **'Fark'**
  String get fark;

  /// No description provided for @fiyatAnalizi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Analizi'**
  String get fiyatAnalizi;

  /// No description provided for @fiyatBildirimleri.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Bildirimleri'**
  String get fiyatBildirimleri;

  /// No description provided for @fiyatDegisimi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Değişimi'**
  String get fiyatDegisimi;

  /// No description provided for @fiyatFarki.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Farkı'**
  String get fiyatFarki;

  /// No description provided for @fiyatGecmisi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Geçmişi'**
  String get fiyatGecmisi;

  /// No description provided for @fiyatGecmisiAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat geçmişi birkaç gün sonra burada görünecek'**
  String get fiyatGecmisiAciklama;

  /// No description provided for @fiyatKarsilastirmasi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Karşılaştırması'**
  String get fiyatKarsilastirmasi;

  /// No description provided for @fiyatOlusumuAnalizi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Oluşumu Analizi'**
  String get fiyatOlusumuAnalizi;

  /// No description provided for @fiyatTahmini.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Tahmini'**
  String get fiyatTahmini;

  /// No description provided for @fiyatlar_tab.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar'**
  String get fiyatlar_tab;

  /// No description provided for @gecersiz.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz'**
  String get gecersiz;

  /// No description provided for @gidisDonusu.
  ///
  /// In tr, this message translates to:
  /// **'Gidiş-Dönüş'**
  String get gidisDonusu;

  /// No description provided for @gonder.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get gonder;

  /// No description provided for @gorunum.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get gorunum;

  /// No description provided for @guncelVeriler.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Veriler'**
  String get guncelVeriler;

  /// No description provided for @guncelle.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get guncelle;

  /// No description provided for @haberBildirimi.
  ///
  /// In tr, this message translates to:
  /// **'Haber Bildirimi'**
  String get haberBildirimi;

  /// No description provided for @haftalikOzet.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Özet'**
  String get haftalikOzet;

  /// No description provided for @haftalikOzetAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Her Pazar 09:00 fiyat özeti'**
  String get haftalikOzetAciklama;

  /// No description provided for @hamPetrol.
  ///
  /// In tr, this message translates to:
  /// **'Ham Petrol'**
  String get hamPetrol;

  /// No description provided for @haritayaDokunun.
  ///
  /// In tr, this message translates to:
  /// **'Haritaya dokunun...'**
  String get haritayaDokunun;

  /// No description provided for @hazirArac.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Araç'**
  String get hazirArac;

  /// No description provided for @hazirAraclar.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Araçlar'**
  String get hazirAraclar;

  /// No description provided for @henuzAracYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz araç eklenmedi'**
  String get henuzAracYok;

  /// No description provided for @henuzKayitYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get henuzKayitYok;

  /// No description provided for @hesaplamaSonucu.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplama Sonucu'**
  String get hesaplamaSonucu;

  /// No description provided for @il.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get il;

  /// No description provided for @ilEkle.
  ///
  /// In tr, this message translates to:
  /// **'İl ekle'**
  String get ilEkle;

  /// No description provided for @ilOrtalamasiNotu.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar il ortalamasıdır.'**
  String get ilOrtalamasiNotu;

  /// No description provided for @ilkYakitAlimi.
  ///
  /// In tr, this message translates to:
  /// **'İlk yakıt alımınızı kaydedin'**
  String get ilkYakitAlimi;

  /// No description provided for @indirim.
  ///
  /// In tr, this message translates to:
  /// **'İndirim'**
  String get indirim;

  /// No description provided for @indirimBeklentisiTag.
  ///
  /// In tr, this message translates to:
  /// **'İndirim Beklentisi'**
  String get indirimBeklentisiTag;

  /// No description provided for @indirimGeldi.
  ///
  /// In tr, this message translates to:
  /// **'İndirim Geldi'**
  String get indirimGeldi;

  /// No description provided for @iptal.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get iptal;

  /// No description provided for @kapat.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get kapat;

  /// No description provided for @kaydet.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get kaydet;

  /// No description provided for @kayitEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt eklendi'**
  String get kayitEklendi;

  /// No description provided for @kayitSil.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Sil'**
  String get kayitSil;

  /// No description provided for @kayitSilOnay.
  ///
  /// In tr, this message translates to:
  /// **'Bu kayıt silinecek. Emin misiniz?'**
  String get kayitSilOnay;

  /// No description provided for @kayitli.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı'**
  String get kayitli;

  /// No description provided for @kdv.
  ///
  /// In tr, this message translates to:
  /// **'KDV'**
  String get kdv;

  /// No description provided for @kmSayaci.
  ///
  /// In tr, this message translates to:
  /// **'Kilometre Sayacı (opsiyonel)'**
  String get kmSayaci;

  /// No description provided for @kmSayaciNot.
  ///
  /// In tr, this message translates to:
  /// **'Tüketim hesabı için gerekli'**
  String get kmSayaciNot;

  /// No description provided for @konumBelirleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Konum belirleniyor...'**
  String get konumBelirleniyor;

  /// No description provided for @kur.
  ///
  /// In tr, this message translates to:
  /// **'Kur'**
  String get kur;

  /// No description provided for @lpgDegisince.
  ///
  /// In tr, this message translates to:
  /// **'LPG fiyatı değişince bildir'**
  String get lpgDegisince;

  /// No description provided for @lpgZamBildirimi.
  ///
  /// In tr, this message translates to:
  /// **'LPG Zam Bildirimi'**
  String get lpgZamBildirimi;

  /// No description provided for @marka.
  ///
  /// In tr, this message translates to:
  /// **'Marka'**
  String get marka;

  /// No description provided for @markaFiyatVeriYok.
  ///
  /// In tr, this message translates to:
  /// **'Marka fiyat verisi bulunamadı'**
  String get markaFiyatVeriYok;

  /// No description provided for @markalar_tab.
  ///
  /// In tr, this message translates to:
  /// **'Markalar'**
  String get markalar_tab;

  /// No description provided for @maxFavoriUyari.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 5 il favorleyebilirsiniz'**
  String get maxFavoriUyari;

  /// No description provided for @mesafe.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe'**
  String get mesafe;

  /// No description provided for @mevcut.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut'**
  String get mevcut;

  /// No description provided for @motorinDegisince.
  ///
  /// In tr, this message translates to:
  /// **'Motorin fiyatı değişince bildir'**
  String get motorinDegisince;

  /// No description provided for @motorinZamBildirimi.
  ///
  /// In tr, this message translates to:
  /// **'Motorin Zam Bildirimi'**
  String get motorinZamBildirimi;

  /// No description provided for @notOpsiyonel.
  ///
  /// In tr, this message translates to:
  /// **'Not (opsiyonel)'**
  String get notOpsiyonel;

  /// No description provided for @onbellekAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat verileri ne kadar süre saklanır'**
  String get onbellekAciklama;

  /// No description provided for @onbellekTemizlendi.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek temizlendi'**
  String get onbellekTemizlendi;

  /// No description provided for @otv.
  ///
  /// In tr, this message translates to:
  /// **'ÖTV'**
  String get otv;

  /// No description provided for @plakaOpsiyonel.
  ///
  /// In tr, this message translates to:
  /// **'Plaka (opsiyonel)'**
  String get plakaOpsiyonel;

  /// No description provided for @sabitKalmasiBekleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Sabit kalması bekleniyor'**
  String get sabitKalmasiBekleniyor;

  /// No description provided for @secilmedi.
  ///
  /// In tr, this message translates to:
  /// **'Seçilmedi'**
  String get secilmedi;

  /// No description provided for @secimSirasina.
  ///
  /// In tr, this message translates to:
  /// **'Seçim sırasına göre'**
  String get secimSirasina;

  /// No description provided for @sehirAra.
  ///
  /// In tr, this message translates to:
  /// **'Şehir ara...'**
  String get sehirAra;

  /// No description provided for @sil.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get sil;

  /// No description provided for @siralama.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get siralama;

  /// No description provided for @sonKayitlar.
  ///
  /// In tr, this message translates to:
  /// **'Son Kayıtlar'**
  String get sonKayitlar;

  /// No description provided for @sure.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get sure;

  /// No description provided for @tarih.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get tarih;

  /// No description provided for @test.
  ///
  /// In tr, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @testBildirimGonderildi.
  ///
  /// In tr, this message translates to:
  /// **'Test bildirimi gönderildi'**
  String get testBildirimGonderildi;

  /// No description provided for @testBildirimiGonder.
  ///
  /// In tr, this message translates to:
  /// **'Test Bildirimi Gönder'**
  String get testBildirimiGonder;

  /// No description provided for @toplam.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get toplam;

  /// No description provided for @toplamYakit.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Yakıt'**
  String get toplamYakit;

  /// No description provided for @toplamYakitMaliyeti.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Yakıt Maliyeti'**
  String get toplamYakitMaliyeti;

  /// No description provided for @tuketimLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tüketim'**
  String get tuketimLabel;

  /// No description provided for @tumBildirimlerKapali.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimler devre dışı'**
  String get tumBildirimlerKapali;

  /// No description provided for @tumHaberleriGoster.
  ///
  /// In tr, this message translates to:
  /// **'Tüm haberleri göster'**
  String get tumHaberleriGoster;

  /// No description provided for @tutar.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get tutar;

  /// No description provided for @ucSaat.
  ///
  /// In tr, this message translates to:
  /// **'3 Saat'**
  String get ucSaat;

  /// No description provided for @varsayilanIl.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan İl'**
  String get varsayilanIl;

  /// No description provided for @varsayilanlar.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılanlar'**
  String get varsayilanlar;

  /// No description provided for @veriBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'Veri bulunamadı'**
  String get veriBulunamadi;

  /// No description provided for @veriYonetimi.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yönetimi'**
  String get veriYonetimi;

  /// No description provided for @yakinIstasyonlarBaslik.
  ///
  /// In tr, this message translates to:
  /// **'Yakınımdaki İstasyonlar'**
  String get yakinIstasyonlarBaslik;

  /// No description provided for @yakitHesapla.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Hesapla'**
  String get yakitHesapla;

  /// No description provided for @yakitTipi.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Tipi'**
  String get yakitTipi;

  /// No description provided for @yaricapiGenislet.
  ///
  /// In tr, this message translates to:
  /// **'Yarıçapı genişlet'**
  String get yaricapiGenislet;

  /// No description provided for @yeniAracEkle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Araç Ekle'**
  String get yeniAracEkle;

  /// No description provided for @yeniKayit.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kayıt'**
  String get yeniKayit;

  /// No description provided for @yeniYakitKaydi.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Yakıt Kaydı'**
  String get yeniYakitKaydi;

  /// No description provided for @yuzdeFark.
  ///
  /// In tr, this message translates to:
  /// **'Yüzde Fark'**
  String get yuzdeFark;

  /// No description provided for @zam.
  ///
  /// In tr, this message translates to:
  /// **'Zam'**
  String get zam;

  /// No description provided for @zamBeklentisiTag.
  ///
  /// In tr, this message translates to:
  /// **'Zam Beklentisi'**
  String get zamBeklentisiTag;

  /// No description provided for @zamEsigi.
  ///
  /// In tr, this message translates to:
  /// **'Zam eşiği'**
  String get zamEsigi;

  /// No description provided for @zamEsigiAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat en az bu oranda artarsa bildirim gelir'**
  String get zamEsigiAciklama;

  /// No description provided for @zamGeldi.
  ///
  /// In tr, this message translates to:
  /// **'Zam Geldi'**
  String get zamGeldi;

  /// No description provided for @zamIndirimBildirim.
  ///
  /// In tr, this message translates to:
  /// **'Zam, indirim ve haber bildirimleri'**
  String get zamIndirimBildirim;

  /// No description provided for @zamIndirimHaberleri.
  ///
  /// In tr, this message translates to:
  /// **'Zam/indirim haberleri geldiğinde'**
  String get zamIndirimHaberleri;

  /// No description provided for @zorunlu.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu'**
  String get zorunlu;

  /// No description provided for @hosGeldiniz.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz!'**
  String get hosGeldiniz;

  /// No description provided for @bulundugunuzIliSecin.
  ///
  /// In tr, this message translates to:
  /// **'Bulunduğunuz ili seçin'**
  String get bulundugunuzIliSecin;

  /// No description provided for @yukleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get yukleniyor;

  /// No description provided for @veriKaynagi.
  ///
  /// In tr, this message translates to:
  /// **'Veri Kaynağı'**
  String get veriKaynagi;

  /// No description provided for @epDKAciklama.
  ///
  /// In tr, this message translates to:
  /// **'EPDK resmi verileri üzerinden güncel akaryakıt fiyatları'**
  String get epDKAciklama;

  /// No description provided for @harita.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get harita;

  /// No description provided for @haritaAciklama.
  ///
  /// In tr, this message translates to:
  /// **'OpenStreetMap & OSRM (açık kaynak)'**
  String get haritaAciklama;

  /// No description provided for @haberKaynaklari.
  ///
  /// In tr, this message translates to:
  /// **'Google Haberler, NTV, BloombergHT, Hürriyet, Sabah'**
  String get haberKaynaklari;

  /// No description provided for @tumKayitliVerileriSil.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtlı verileri sil'**
  String get tumKayitliVerileriSil;

  /// No description provided for @onbellekSilinecekUyari.
  ///
  /// In tr, this message translates to:
  /// **'Tüm önbelleklenmiş fiyat verileri silinecek. Veriler yeniden yüklenecektir.'**
  String get onbellekSilinecekUyari;

  /// No description provided for @varsayilanIlAra.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan il ara...'**
  String get varsayilanIlAra;

  /// No description provided for @ilVerisiOnbellekte.
  ///
  /// In tr, this message translates to:
  /// **'{count} il verisi önbellekte'**
  String ilVerisiOnbellekte(int count);

  /// No description provided for @toplamCacheKaydi.
  ///
  /// In tr, this message translates to:
  /// **'{count} toplam cache kaydı'**
  String toplamCacheKaydi(int count);

  /// No description provided for @raporIcinKayitGerekli.
  ///
  /// In tr, this message translates to:
  /// **'Rapor için en az 1 kayıt gerekli'**
  String get raporIcinKayitGerekli;

  /// No description provided for @yakitDefterineKayitEkleyin.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Defterine kayıt ekleyin'**
  String get yakitDefterineKayitEkleyin;

  /// No description provided for @ortLitreFiyat.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Litre Fiyat'**
  String get ortLitreFiyat;

  /// No description provided for @gecenAylaKarsilastirma.
  ///
  /// In tr, this message translates to:
  /// **'Geçen Ayla Karşılaştırma'**
  String get gecenAylaKarsilastirma;

  /// No description provided for @ortFiyat.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Fiyat'**
  String get ortFiyat;

  /// No description provided for @altiAylikHarcamaTrendi.
  ///
  /// In tr, this message translates to:
  /// **'6 Aylık Harcama Trendi'**
  String get altiAylikHarcamaTrendi;

  /// No description provided for @yakitTipiDagilimi.
  ///
  /// In tr, this message translates to:
  /// **'Yakıt Tipi Dağılımı'**
  String get yakitTipiDagilimi;

  /// No description provided for @ortTuketim.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Tüketim'**
  String get ortTuketim;

  /// No description provided for @haritadaBaslangicaDok.
  ///
  /// In tr, this message translates to:
  /// **'Haritada başlangıç noktasına dokunun'**
  String get haritadaBaslangicaDok;

  /// No description provided for @haritadaAraNoktayaDok.
  ///
  /// In tr, this message translates to:
  /// **'Haritada ara noktaya dokunun'**
  String get haritadaAraNoktayaDok;

  /// No description provided for @haritadaVarisaDok.
  ///
  /// In tr, this message translates to:
  /// **'Haritada varış noktasına dokunun'**
  String get haritadaVarisaDok;

  /// No description provided for @tekYon.
  ///
  /// In tr, this message translates to:
  /// **'Tek Yön'**
  String get tekYon;

  /// No description provided for @kisi.
  ///
  /// In tr, this message translates to:
  /// **'kişi'**
  String get kisi;

  /// No description provided for @rotaHesaplanamadi.
  ///
  /// In tr, this message translates to:
  /// **'Rota hesaplanamadı'**
  String get rotaHesaplanamadi;

  /// No description provided for @fiyatVerisiBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'fiyat verisi bulunamadı'**
  String get fiyatVerisiBulunamadi;

  /// No description provided for @gidisDonusuToplamMaliyet.
  ///
  /// In tr, this message translates to:
  /// **'Gidiş-Dönüş Toplam Maliyet'**
  String get gidisDonusuToplamMaliyet;

  /// No description provided for @kisiBasiMaliyet.
  ///
  /// In tr, this message translates to:
  /// **'Kişi başı'**
  String get kisiBasiMaliyet;

  /// No description provided for @depo.
  ///
  /// In tr, this message translates to:
  /// **'depo'**
  String get depo;

  /// No description provided for @fiyatBilgisiAlinamadi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat bilgisi alınamadı'**
  String get fiyatBilgisiAlinamadi;

  /// No description provided for @bildirimAciklamaMetni.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri açarak zam ve indirimlerden anında haberdar olun'**
  String get bildirimAciklamaMetni;

  /// No description provided for @hassas.
  ///
  /// In tr, this message translates to:
  /// **'hassas'**
  String get hassas;

  /// No description provided for @sadeceBuyukZamlar.
  ///
  /// In tr, this message translates to:
  /// **'sadece büyük zamlar'**
  String get sadeceBuyukZamlar;

  /// No description provided for @bildirimlerCalisiyor.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler düzgün çalışıyor!'**
  String get bildirimlerCalisiyor;

  /// No description provided for @istanbulVsAnkara.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul vs Ankara'**
  String get istanbulVsAnkara;

  /// No description provided for @ucBuyukSehir.
  ///
  /// In tr, this message translates to:
  /// **'3 Büyük Şehir'**
  String get ucBuyukSehir;

  /// No description provided for @dortBuyukSehir.
  ///
  /// In tr, this message translates to:
  /// **'4 Büyük Şehir'**
  String get dortBuyukSehir;

  /// No description provided for @verilerYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi'**
  String get verilerYuklenemedi;

  /// No description provided for @sonGunler.
  ///
  /// In tr, this message translates to:
  /// **'Son {count} gün'**
  String sonGunler(int count);

  /// No description provided for @hata.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get hata;

  /// No description provided for @fiyatOlusumuAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Akaryakıt fiyatı; ham petrol, ÖTV, KDV ve dağıtıcı marjlarından oluşur'**
  String get fiyatOlusumuAciklama;

  /// No description provided for @kaynak.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak'**
  String get kaynak;

  /// No description provided for @otvOranlariTarihi.
  ///
  /// In tr, this message translates to:
  /// **'ÖTV oranları tarihi'**
  String get otvOranlariTarihi;

  /// No description provided for @yaklasikHesapNotu.
  ///
  /// In tr, this message translates to:
  /// **'Not: Ham petrol payı yaklaşık hesaplanmıştır. Gerçek dağılım piyasa koşullarına göre değişebilir.'**
  String get yaklasikHesapNotu;

  /// No description provided for @veriYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Veri yüklenemedi'**
  String get veriYuklenemedi;

  /// No description provided for @petrolDoviz.
  ///
  /// In tr, this message translates to:
  /// **'Petrol/Döviz'**
  String get petrolDoviz;

  /// No description provided for @dovizEtkisiAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Akaryakıt fiyatları döviz kuru, ham petrol fiyatı, ÖTV, KDV, dağıtıcı ve bayi marjlarından oluşur. Dolar artışı doğrudan pompa fiyatına yansır.'**
  String get dovizEtkisiAciklama;

  /// No description provided for @orneginAileArabasi.
  ///
  /// In tr, this message translates to:
  /// **'ör: Aile Arabası'**
  String get orneginAileArabasi;

  /// No description provided for @orneginPlaka.
  ///
  /// In tr, this message translates to:
  /// **'ör: 06 ABC 123'**
  String get orneginPlaka;

  /// No description provided for @orneginNot.
  ///
  /// In tr, this message translates to:
  /// **'ör: Uzun yol öncesi'**
  String get orneginNot;

  /// No description provided for @araNokta.
  ///
  /// In tr, this message translates to:
  /// **'Ara nokta'**
  String get araNokta;

  /// No description provided for @araNoktaEkleHarita.
  ///
  /// In tr, this message translates to:
  /// **'+ Ara nokta ekle (harita)'**
  String get araNoktaEkleHarita;

  /// No description provided for @istasyonBulundu.
  ///
  /// In tr, this message translates to:
  /// **'{count} istasyon bulundu ({radius} yarıçapta)'**
  String istasyonBulundu(int count, String radius);

  /// No description provided for @akaryakitFirmasi.
  ///
  /// In tr, this message translates to:
  /// **'{count} akaryakıt firması listeleniyor'**
  String akaryakitFirmasi(int count);

  /// No description provided for @kayit.
  ///
  /// In tr, this message translates to:
  /// **'kayıt'**
  String get kayit;

  /// No description provided for @litreFiyati.
  ///
  /// In tr, this message translates to:
  /// **'Litre fiyatı'**
  String get litreFiyati;

  /// No description provided for @fiyatDagilimi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Dağılımı'**
  String get fiyatDagilimi;

  /// No description provided for @fiyat.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get fiyat;

  /// No description provided for @sabit.
  ///
  /// In tr, this message translates to:
  /// **'Sabit'**
  String get sabit;

  /// No description provided for @kucukOtomobil.
  ///
  /// In tr, this message translates to:
  /// **'Küçük Otomobil'**
  String get kucukOtomobil;

  /// No description provided for @sedan.
  ///
  /// In tr, this message translates to:
  /// **'Sedan'**
  String get sedan;

  /// No description provided for @suv.
  ///
  /// In tr, this message translates to:
  /// **'SUV'**
  String get suv;

  /// No description provided for @ticari.
  ///
  /// In tr, this message translates to:
  /// **'Ticari'**
  String get ticari;

  /// No description provided for @elektrikli.
  ///
  /// In tr, this message translates to:
  /// **'Elektrikli'**
  String get elektrikli;

  /// No description provided for @kayitSilindi.
  ///
  /// In tr, this message translates to:
  /// **'kayıt silindi'**
  String get kayitSilindi;

  /// No description provided for @testBildirimleri.
  ///
  /// In tr, this message translates to:
  /// **'Test Bildirimleri'**
  String get testBildirimleri;

  /// No description provided for @vergiler.
  ///
  /// In tr, this message translates to:
  /// **'Vergiler'**
  String get vergiler;

  /// No description provided for @tasarrufYuksekTuketim.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek tüketim! Sabit hız (90-110 km/s) ile %15\'e kadar yakıt tasarrufu sağlayabilirsiniz.'**
  String get tasarrufYuksekTuketim;

  /// No description provided for @tasarrufUzunYol.
  ///
  /// In tr, this message translates to:
  /// **'Uzun yol! Lastik basıncını kontrol edin — düşük basınç %3 daha fazla yakıt harcar.'**
  String get tasarrufUzunYol;

  /// No description provided for @tasarrufSehirDisi.
  ///
  /// In tr, this message translates to:
  /// **'Yolda yakıt alacaksanız, şehir dışında istasyonlar genellikle daha ucuzdur.'**
  String get tasarrufSehirDisi;

  /// No description provided for @tasarrufKlima.
  ///
  /// In tr, this message translates to:
  /// **'Klima kullanımı yakıt tüketimini %10-15 artırabilir, pencere açmak ise yüksek hızda aerodinamiği bozar.'**
  String get tasarrufKlima;

  /// No description provided for @motosiklet.
  ///
  /// In tr, this message translates to:
  /// **'Motosiklet'**
  String get motosiklet;

  /// No description provided for @azOnce.
  ///
  /// In tr, this message translates to:
  /// **'Az önce'**
  String get azOnce;

  /// No description provided for @dkOnce.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk önce'**
  String dkOnce(int count);

  /// No description provided for @saatOnce.
  ///
  /// In tr, this message translates to:
  /// **'{count} saat önce'**
  String saatOnce(int count);

  /// No description provided for @gunOnce.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String gunOnce(int count);

  /// No description provided for @harcamaKm.
  ///
  /// In tr, this message translates to:
  /// **'Harcama/km'**
  String get harcamaKm;

  /// No description provided for @istasyonlarYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'İstasyonlar yüklenemedi'**
  String get istasyonlarYuklenemedi;

  /// No description provided for @konumIzniReddedildi.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni reddedildi.'**
  String get konumIzniReddedildi;

  /// No description provided for @konumIzniKaliciReddedildi.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedildi. Ayarlardan açın.'**
  String get konumIzniKaliciReddedildi;

  /// No description provided for @benzinIstasyonu.
  ///
  /// In tr, this message translates to:
  /// **'Benzin İstasyonu'**
  String get benzinIstasyonu;

  /// No description provided for @paylasMetni.
  ///
  /// In tr, this message translates to:
  /// **'YakıtCep — Yakıt Hesaplama'**
  String get paylasMetni;

  /// No description provided for @paylasAylikRapor.
  ///
  /// In tr, this message translates to:
  /// **'YakıtCep — Aylık Rapor'**
  String get paylasAylikRapor;

  /// No description provided for @farkAnalizi.
  ///
  /// In tr, this message translates to:
  /// **'Fark Analizi'**
  String get farkAnalizi;

  /// No description provided for @tasarruf50L.
  ///
  /// In tr, this message translates to:
  /// **'50L Tasarruf'**
  String get tasarruf50L;

  /// No description provided for @yuzKmMaliyet.
  ///
  /// In tr, this message translates to:
  /// **'100km Maliyet'**
  String get yuzKmMaliyet;

  /// No description provided for @markaFiyatlariYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Marka fiyatları yüklenemedi'**
  String get markaFiyatlariYuklenemedi;

  /// No description provided for @dovizVerileriYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Döviz verileri yüklenemedi'**
  String get dovizVerileriYuklenemedi;

  /// No description provided for @toplamLitre.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Litre'**
  String get toplamLitre;

  /// No description provided for @kayitSayisi.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Sayısı'**
  String get kayitSayisi;

  /// No description provided for @gecenAyaGore.
  ///
  /// In tr, this message translates to:
  /// **'Geçen aya göre'**
  String get gecenAyaGore;

  /// No description provided for @depoLabel.
  ///
  /// In tr, this message translates to:
  /// **'depo'**
  String get depoLabel;

  /// No description provided for @kisiBasiLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kişi başı'**
  String get kisiBasiLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
