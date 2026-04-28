// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YakıtCep';

  @override
  String get fiyatlar => 'Prices';

  @override
  String get karsilastir => 'Compare';

  @override
  String get haberler => 'News';

  @override
  String get hesapla => 'Calculate';

  @override
  String get ayarlar => 'Settings';

  @override
  String get ulusalOrtalama => 'National Average';

  @override
  String get favorilerim => 'My Favorites';

  @override
  String get tumIller => 'All Provinces';

  @override
  String get ilAra => 'Search province...';

  @override
  String get benzin95 => 'Gasoline 95';

  @override
  String get motorin => 'Diesel';

  @override
  String get motorinPremium => 'Diesel (Premium)';

  @override
  String get lpg => 'LPG (Autogas)';

  @override
  String get litre => 'Liter';

  @override
  String sonGuncelleme(String zaman) {
    return 'Last update: $zaman';
  }

  @override
  String get veriYok => 'No data';

  @override
  String get tekrarDene => 'Try Again';

  @override
  String get fiyatlarYuklenemedi => 'Prices could not be loaded';

  @override
  String get enUcuzNeresi => 'Cheapest Where?';

  @override
  String ilSecin(int sayi, int maks) {
    return 'Select province ($sayi/$maks)';
  }

  @override
  String get temizle => 'Clear';

  @override
  String get zamBeklentisi => 'Price Hike Expected';

  @override
  String get indirimBeklentisi => 'Price Cut Expected';

  @override
  String get tumu => 'All';

  @override
  String get son24Saat => 'Last 24 Hours';

  @override
  String get buHafta => 'This Week';

  @override
  String get haberAra => 'Search news...';

  @override
  String get tema => 'Theme';

  @override
  String get acik => 'Light';

  @override
  String get koyu => 'Dark';

  @override
  String get sistem => 'System';

  @override
  String get onbellekSuresi => 'Cache Duration';

  @override
  String get onbellegiTemizle => 'Clear Cache';

  @override
  String get bildirimAyarlari => 'Notification Settings';

  @override
  String get araclarim => 'My Vehicles';

  @override
  String get yakitDefteri => 'Fuel Log';

  @override
  String get dovizEtkisi => 'Currency Impact';

  @override
  String get fiyatHaritasi => 'Price Map';

  @override
  String get yakinIstasyonlar => 'Nearby Stations';

  @override
  String get hesaplaBaslik => 'Fuel Calculator';

  @override
  String get aracBilgileri => 'Vehicle Info';

  @override
  String get tuketim => 'Consumption (L/100km)';

  @override
  String get depoKapasite => 'Tank (Liters)';

  @override
  String get fiyatIli => 'Price province';

  @override
  String get rotaSecimi => 'Route Selection';

  @override
  String get baslangicNoktasi => 'Select starting point';

  @override
  String get varisNoktasi => 'Select destination';

  @override
  String get haritadaSec => 'Select on map';

  @override
  String get listedenSec => 'Select from list';

  @override
  String get hesaplaSonuclar => 'Calculation Results';

  @override
  String get toplamMesafe => 'Total Distance';

  @override
  String get tahminiSure => 'Estimated Duration';

  @override
  String get toplamYakitTuketimi => 'Total Fuel Consumption';

  @override
  String get toplamMaliyet => 'Total Cost';

  @override
  String get kmBasinaMaliyet => 'Cost per km';

  @override
  String get depoYeterliMi => 'Is Tank Enough?';

  @override
  String get paylas => 'Share';

  @override
  String get internetYok => 'No internet connection. Showing cached data.';

  @override
  String get hakkinda => 'About';

  @override
  String get versiyon => 'Version';

  @override
  String get akaryakitHaberleri => 'Fuel News';

  @override
  String get aktif => 'Active';

  @override
  String get aktifYap => 'Set Active';

  @override
  String get altiSaat => '6 Hours';

  @override
  String get arac => 'Vehicle';

  @override
  String get aracAdi => 'Vehicle Name';

  @override
  String get aracEkle => 'Add Vehicle';

  @override
  String get aracEntegrasyon => 'Integrates with calculator and fuel log';

  @override
  String get aracProfilleriYonet => 'Manage vehicle profiles';

  @override
  String get aracSec => 'Select Vehicle';

  @override
  String get aracSecilmedi => 'No vehicle selected';

  @override
  String get araciDuzenle => 'Edit Vehicle';

  @override
  String get artisBekleniyor => 'Increase expected';

  @override
  String get aylikHarcama => 'Monthly Spending';

  @override
  String get aylikRapor => 'Monthly Report';

  @override
  String get bayiMarji => 'Dealer Margin';

  @override
  String get benzin => 'Gasoline';

  @override
  String get benzinDegisince => 'Notify when gasoline price changes';

  @override
  String get benzinZamBildirimi => 'Gasoline Price Alert';

  @override
  String get bildirimEsigi => 'Notification Threshold';

  @override
  String get bildirimler => 'Notifications';

  @override
  String get bildirimlerAcikKapali => 'Notifications On/Off';

  @override
  String get bildirimlerAktif => 'Notifications active';

  @override
  String get bildirimleriDogrula => 'Verify notifications work';

  @override
  String get bilgi => 'Info';

  @override
  String get birSaat => '1 Hour';

  @override
  String get buAy => 'This Month';

  @override
  String get buFiltredeHaberYok => 'No news found with this filter';

  @override
  String get buIlIcinVeriYok => 'No price data for this province';

  @override
  String get buYakitIcinVeriYok => 'No data for this fuel type';

  @override
  String get buYaricaptaYok => 'No stations in this radius';

  @override
  String get dagiticiBayi => 'Distributor+Dealer';

  @override
  String get dagiticiMarji => 'Distributor Margin';

  @override
  String get depoMenzili => 'Tank Range';

  @override
  String get depoSayisi => 'Tank Fills';

  @override
  String get detay => 'Detail';

  @override
  String get digerBildirimler => 'Other Notifications';

  @override
  String get dilLanguage => 'Language';

  @override
  String get dolar => 'Dollar';

  @override
  String get dolarDegisirse => 'What if the dollar changes?';

  @override
  String get dovizEtkisiSimulasyonu => 'Currency Impact Simulation';

  @override
  String get dususBekleniyor => 'Decrease expected';

  @override
  String get duzenle => 'Edit';

  @override
  String get enAz2Il => 'Select at least 2 provinces';

  @override
  String get enPahalidan => 'Most expensive first';

  @override
  String get enUcuzdan => 'Cheapest first';

  @override
  String get fark => 'Diff';

  @override
  String get fiyatAnalizi => 'Price Analysis';

  @override
  String get fiyatBildirimleri => 'Price Notifications';

  @override
  String get fiyatDegisimi => 'Price Change';

  @override
  String get fiyatFarki => 'Price Difference';

  @override
  String get fiyatGecmisi => 'Price History';

  @override
  String get fiyatGecmisiAciklama =>
      'Price history will appear here in a few days';

  @override
  String get fiyatKarsilastirmasi => 'Price Comparison';

  @override
  String get fiyatOlusumuAnalizi => 'Price Composition Analysis';

  @override
  String get fiyatTahmini => 'Price Forecast';

  @override
  String get fiyatlar_tab => 'Prices';

  @override
  String get gecersiz => 'Invalid';

  @override
  String get gidisDonusu => 'Round Trip';

  @override
  String get gonder => 'Send';

  @override
  String get gorunum => 'Appearance';

  @override
  String get guncelVeriler => 'Current Data';

  @override
  String get guncelle => 'Update';

  @override
  String get haberBildirimi => 'News Notification';

  @override
  String get haftalikOzet => 'Weekly Summary';

  @override
  String get haftalikOzetAciklama => 'Price summary every Sunday 09:00';

  @override
  String get hamPetrol => 'Crude Oil';

  @override
  String get haritayaDokunun => 'Tap on map...';

  @override
  String get hazirArac => 'Preset Vehicle';

  @override
  String get hazirAraclar => 'Preset Vehicles';

  @override
  String get henuzAracYok => 'No vehicles added yet';

  @override
  String get henuzKayitYok => 'No entries yet';

  @override
  String get hesaplamaSonucu => 'Calculation Result';

  @override
  String get il => 'Province';

  @override
  String get ilEkle => 'Add province';

  @override
  String get ilOrtalamasiNotu => 'Prices are provincial averages.';

  @override
  String get ilkYakitAlimi => 'Record your first refueling';

  @override
  String get indirim => 'Cut';

  @override
  String get indirimBeklentisiTag => 'Cut Expected';

  @override
  String get indirimGeldi => 'Price Cut';

  @override
  String get iptal => 'Cancel';

  @override
  String get kapat => 'Close';

  @override
  String get kaydet => 'Save';

  @override
  String get kayitEklendi => 'Entry added';

  @override
  String get kayitSil => 'Delete Entry';

  @override
  String get kayitSilOnay => 'This entry will be deleted. Are you sure?';

  @override
  String get kayitli => 'Saved';

  @override
  String get kdv => 'VAT';

  @override
  String get kmSayaci => 'Odometer (optional)';

  @override
  String get kmSayaciNot => 'Required for consumption calculation';

  @override
  String get konumBelirleniyor => 'Locating...';

  @override
  String get kur => 'Rate';

  @override
  String get lpgDegisince => 'Notify when LPG price changes';

  @override
  String get lpgZamBildirimi => 'LPG Price Alert';

  @override
  String get marka => 'Brand';

  @override
  String get markaFiyatVeriYok => 'No brand price data';

  @override
  String get markalar_tab => 'Brands';

  @override
  String get maxFavoriUyari => 'You can favorite up to 5 provinces';

  @override
  String get mesafe => 'Distance';

  @override
  String get mevcut => 'Current';

  @override
  String get motorinDegisince => 'Notify when diesel price changes';

  @override
  String get motorinZamBildirimi => 'Diesel Price Alert';

  @override
  String get notOpsiyonel => 'Note (optional)';

  @override
  String get onbellekAciklama => 'How long price data is cached';

  @override
  String get onbellekTemizlendi => 'Cache cleared';

  @override
  String get otv => 'Excise Tax';

  @override
  String get plakaOpsiyonel => 'License Plate (optional)';

  @override
  String get sabitKalmasiBekleniyor => 'Expected to stay stable';

  @override
  String get secilmedi => 'Not selected';

  @override
  String get secimSirasina => 'Selection order';

  @override
  String get sehirAra => 'Search city...';

  @override
  String get sil => 'Delete';

  @override
  String get siralama => 'Sort';

  @override
  String get sonKayitlar => 'Recent Entries';

  @override
  String get sure => 'Duration';

  @override
  String get tarih => 'Date';

  @override
  String get test => 'Test';

  @override
  String get testBildirimGonderildi => 'Test notification sent';

  @override
  String get testBildirimiGonder => 'Send Test Notification';

  @override
  String get toplam => 'Total';

  @override
  String get toplamYakit => 'Total Fuel';

  @override
  String get toplamYakitMaliyeti => 'Total Fuel Cost';

  @override
  String get tuketimLabel => 'Consumption';

  @override
  String get tumBildirimlerKapali => 'All notifications disabled';

  @override
  String get tumHaberleriGoster => 'Show all news';

  @override
  String get tutar => 'Amount';

  @override
  String get ucSaat => '3 Hours';

  @override
  String get varsayilanIl => 'Default Province';

  @override
  String get varsayilanlar => 'Defaults';

  @override
  String get veriBulunamadi => 'No data found';

  @override
  String get veriYonetimi => 'Data Management';

  @override
  String get yakinIstasyonlarBaslik => 'Nearby Stations';

  @override
  String get yakitHesapla => 'Calculate Fuel';

  @override
  String get yakitTipi => 'Fuel Type';

  @override
  String get yaricapiGenislet => 'Expand radius';

  @override
  String get yeniAracEkle => 'Add New Vehicle';

  @override
  String get yeniKayit => 'New Entry';

  @override
  String get yeniYakitKaydi => 'New Fuel Entry';

  @override
  String get yuzdeFark => 'Percentage Diff';

  @override
  String get zam => 'Hike';

  @override
  String get zamBeklentisiTag => 'Hike Expected';

  @override
  String get zamEsigi => 'Price change threshold';

  @override
  String get zamEsigiAciklama => 'Notify when price rises by this percentage';

  @override
  String get zamGeldi => 'Price Hike';

  @override
  String get zamIndirimBildirim => 'Price change and news notifications';

  @override
  String get zamIndirimHaberleri => 'When price change news arrives';

  @override
  String get zorunlu => 'Required';

  @override
  String get hosGeldiniz => 'Welcome!';

  @override
  String get bulundugunuzIliSecin => 'Select your province';

  @override
  String get yukleniyor => 'Loading...';

  @override
  String get veriKaynagi => 'Data Source';

  @override
  String get epDKAciklama => 'Current fuel prices via EPDK official data';

  @override
  String get harita => 'Map';

  @override
  String get haritaAciklama => 'OpenStreetMap & OSRM (open source)';

  @override
  String get haberKaynaklari =>
      'Google News, NTV, BloombergHT, Hurriyet, Sabah';

  @override
  String get tumKayitliVerileriSil => 'Delete all saved data';

  @override
  String get onbellekSilinecekUyari =>
      'All cached price data will be deleted. Data will be reloaded.';

  @override
  String get varsayilanIlAra => 'Search default province...';

  @override
  String ilVerisiOnbellekte(int count) {
    return '$count province data cached';
  }

  @override
  String toplamCacheKaydi(int count) {
    return '$count total cache records';
  }

  @override
  String get raporIcinKayitGerekli => 'At least 1 record required for report';

  @override
  String get yakitDefterineKayitEkleyin => 'Add an entry to Fuel Log';

  @override
  String get ortLitreFiyat => 'Avg. Liter Price';

  @override
  String get gecenAylaKarsilastirma => 'Compare with Last Month';

  @override
  String get ortFiyat => 'Avg. Price';

  @override
  String get altiAylikHarcamaTrendi => '6-Month Spending Trend';

  @override
  String get yakitTipiDagilimi => 'Fuel Type Distribution';

  @override
  String get ortTuketim => 'Avg. Consumption';

  @override
  String get haritadaBaslangicaDok => 'Tap map for starting point';

  @override
  String get haritadaAraNoktayaDok => 'Tap map for waypoint';

  @override
  String get haritadaVarisaDok => 'Tap map for destination';

  @override
  String get tekYon => 'One Way';

  @override
  String get kisi => 'person';

  @override
  String get rotaHesaplanamadi => 'Route calculation failed';

  @override
  String get fiyatVerisiBulunamadi => 'price data not found';

  @override
  String get gidisDonusuToplamMaliyet => 'Round Trip Total Cost';

  @override
  String get kisiBasiMaliyet => 'Per person';

  @override
  String get depo => 'tank';

  @override
  String get fiyatBilgisiAlinamadi => 'Price info not available';

  @override
  String get bildirimAciklamaMetni =>
      'Enable notifications to stay informed about price changes';

  @override
  String get hassas => 'sensitive';

  @override
  String get sadeceBuyukZamlar => 'large changes only';

  @override
  String get bildirimlerCalisiyor => 'Notifications are working!';

  @override
  String get istanbulVsAnkara => 'Istanbul vs Ankara';

  @override
  String get ucBuyukSehir => '3 Major Cities';

  @override
  String get dortBuyukSehir => '4 Major Cities';

  @override
  String get verilerYuklenemedi => 'Data could not be loaded';

  @override
  String sonGunler(int count) {
    return 'Last $count days';
  }

  @override
  String get hata => 'Error';

  @override
  String get fiyatOlusumuAciklama =>
      'Fuel price consists of crude oil, excise tax, VAT, and distributor margins';

  @override
  String get kaynak => 'Source';

  @override
  String get otvOranlariTarihi => 'Excise tax rates date';

  @override
  String get yaklasikHesapNotu =>
      'Note: Crude oil share is approximate. Actual distribution may vary by market conditions.';

  @override
  String get veriYuklenemedi => 'Data could not be loaded';

  @override
  String get petrolDoviz => 'Oil/Currency';

  @override
  String get dovizEtkisiAciklama =>
      'Fuel prices consist of exchange rate, crude oil, excise tax, VAT, distributor and dealer margins. Dollar increase directly affects pump prices.';

  @override
  String get orneginAileArabasi => 'e.g. Family Car';

  @override
  String get orneginPlaka => 'e.g. 06 ABC 123';

  @override
  String get orneginNot => 'e.g. Before long trip';

  @override
  String get araNokta => 'Waypoint';

  @override
  String get araNoktaEkleHarita => '+ Add waypoint (map)';

  @override
  String istasyonBulundu(int count, String radius) {
    return '$count stations found ($radius radius)';
  }

  @override
  String akaryakitFirmasi(int count) {
    return '$count fuel companies listed';
  }

  @override
  String get kayit => 'entry';

  @override
  String get litreFiyati => 'Price per liter';

  @override
  String get fiyatDagilimi => 'Price Distribution';

  @override
  String get fiyat => 'Price';

  @override
  String get sabit => 'Stable';

  @override
  String get kucukOtomobil => 'Compact Car';

  @override
  String get sedan => 'Sedan';

  @override
  String get suv => 'SUV';

  @override
  String get ticari => 'Commercial';

  @override
  String get elektrikli => 'Electric';

  @override
  String get kayitSilindi => 'entries deleted';

  @override
  String get testBildirimleri => 'Test Notifications';

  @override
  String get vergiler => 'Taxes';

  @override
  String get tasarrufYuksekTuketim =>
      'High consumption! Steady speed (90-110 km/h) can save up to 15% fuel.';

  @override
  String get tasarrufUzunYol =>
      'Long trip! Check tire pressure — low pressure uses 3% more fuel.';

  @override
  String get tasarrufSehirDisi =>
      'If refueling on the road, stations outside cities are usually cheaper.';

  @override
  String get tasarrufKlima =>
      'AC usage increases fuel consumption 10-15%, and open windows reduce aerodynamics at high speed.';

  @override
  String get motosiklet => 'Motorcycle';

  @override
  String get azOnce => 'Just now';

  @override
  String dkOnce(int count) {
    return '$count min ago';
  }

  @override
  String saatOnce(int count) {
    return '$count hours ago';
  }

  @override
  String gunOnce(int count) {
    return '$count days ago';
  }

  @override
  String get harcamaKm => 'Cost/km';

  @override
  String get istasyonlarYuklenemedi => 'Stations could not be loaded';

  @override
  String get konumIzniReddedildi => 'Location permission denied.';

  @override
  String get konumIzniKaliciReddedildi =>
      'Location permission permanently denied. Enable in Settings.';

  @override
  String get benzinIstasyonu => 'Gas Station';

  @override
  String get paylasMetni => 'YakıtCep — Fuel Calculator';

  @override
  String get paylasAylikRapor => 'YakıtCep — Monthly Report';

  @override
  String get farkAnalizi => 'Difference Analysis';

  @override
  String get tasarruf50L => '50L Savings';

  @override
  String get yuzKmMaliyet => '100km Cost';

  @override
  String get markaFiyatlariYuklenemedi => 'Brand prices could not be loaded';

  @override
  String get dovizVerileriYuklenemedi => 'Currency data could not be loaded';

  @override
  String get toplamLitre => 'Total Liters';

  @override
  String get kayitSayisi => 'Entry Count';

  @override
  String get gecenAyaGore => 'Compared to last month';

  @override
  String get depoLabel => 'tank';

  @override
  String get kisiBasiLabel => 'Per person';
}
