# YakıtTakip v2.0 — Yeni Özellikler Uygulama Planı

## Context
Mevcut uygulama 5 sekmeli (Fiyatlar, Karşılaştır, Haberler, Hesapla, Ayarlar) çalışan bir akaryakıt takip uygulaması. Kullanıcı 11 yeni özellik istiyor. Bu plan, özellikleri 6 faza bölerek bağımlılık sırasına göre uygulamayı hedefler.

---

## Faz 1 — Veri Altyapısı + Yakınımdaki İstasyonlar
**Süre tahmini: Büyük | Bağımlılık: Yok**

### 1A. Yakınımdaki İstasyonlar (Özellik #1)
**Açıklama:** GPS ile konumu al, OpenStreetMap Overpass API ile en yakın benzinlikleri haritada göster.

**API:** Overpass API (ücretsiz, auth yok)
```
https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="fuel"](around:5000,{lat},{lon});out body;
```

**Yeni dosyalar:**
```
lib/features/istasyonlar/
├── data/
│   └── datasources/
│       └── overpass_datasource.dart      # Overpass API client
├── domain/
│   └── entities/
│       └── yakin_istasyon.dart           # İstasyon entity (ad, marka, mesafe, konum)
└── presentation/
    ├── providers/
    │   └── istasyon_provider.dart        # GPS + API provider
    └── screens/
        └── yakin_istasyonlar_screen.dart # Harita + liste görünümü
```

**Değiştirilecek dosyalar:**
- `pubspec.yaml` → `geolocator: ^13.0.1` (GPS)
- `app/router.dart` → yeni rota: `/fiyatlar/yakin-istasyonlar`
- `anasayfa_screen.dart` → "Yakınımdaki İstasyonlar" butonu eklenir
- `AndroidManifest.xml` → `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`

**Ekran tasarımı:**
- Üst: FlutterMap (kullanıcı konumu mavi nokta, istasyonlar marker)
- Alt: Kaydırılabilir liste (marka ikonu, ad, mesafe, fiyat bilgisi varsa)
- Filtre: Yarıçap seçici (1km / 3km / 5km / 10km)

---

### 1B. Döviz/Petrol Etkisi Grafiği (Özellik #6)
**Açıklama:** USD/TL kuru + Brent petrol fiyatı vs benzin fiyatı korelasyon grafiği.

**API:** Ücretsiz döviz API
```
https://api.exchangerate.host/timeseries?start_date=X&end_date=Y&base=USD&symbols=TRY
```
Brent petrol için alternatif: basit web scrape veya sabit mock data

**Yeni dosyalar:**
```
lib/features/fiyatlar/data/datasources/
    └── doviz_datasource.dart            # Döviz kuru API
lib/features/fiyatlar/presentation/screens/
    └── doviz_etki_screen.dart           # Korelasyon grafik ekranı
```

**Değiştirilecek dosyalar:**
- `anasayfa_screen.dart` → "Döviz Etkisi" kartı/butonu
- `fiyat_provider.dart` → doviz provider

---

## Faz 2 — Yakıt Takip Defteri + Çoklu Araç
**Süre tahmini: Orta | Bağımlılık: Yok**

### 2A. Yakıt Takip Defteri (Özellik #3)
**Açıklama:** Her depo dolumunu kaydet → aylık harcama grafiği, ortalama tüketim.

**Veri saklama:** SharedPreferences (JSON listesi) — basit ve mevcut altyapıyla uyumlu. Büyürse sqflite'a geçilebilir.

**Yeni dosyalar:**
```
lib/features/yakit_defteri/
├── data/
│   └── datasources/
│       └── yakit_kayit_datasource.dart  # SharedPrefs CRUD
├── domain/
│   └── entities/
│       ├── yakit_kayit.dart             # Kayıt entity (tarih, litre, km, tutar, yakitTipi, not)
│       └── yakit_istatistik.dart        # Hesaplanmış istatistikler
└── presentation/
    ├── providers/
    │   └── yakit_defteri_provider.dart  # StateNotifier + istatistik hesaplama
    └── screens/
        ├── yakit_defteri_screen.dart    # Ana liste + grafik
        └── yakit_kayit_ekle_screen.dart # Yeni kayıt formu
```

**Değiştirilecek dosyalar:**
- `app/router.dart` → `/fiyatlar/yakit-defteri` rotası
- `anasayfa_screen.dart` → "Yakıt Defteri" kartı
- `app_constants.dart` → max kayıt limiti

**Ekran tasarımı — Liste:**
- Son kayıtlar (tarih, litre, tutar, km)
- Aylık toplam harcama kartı
- Ortalama tüketim kartı (L/100km)
- Line chart: aylık harcama grafiği (fl_chart)

**Ekran tasarımı — Kayıt Ekleme:**
- Tarih seçici (DatePicker)
- Litre input
- Tutar input (₺)
- Kilometre sayacı input
- Yakıt tipi seçici
- İsteğe bağlı not
- "Kaydet" butonu

### 2B. Çoklu Araç Profili (Özellik #7)
**Açıklama:** Birden fazla araç profili kaydet, hesaplamada hızlı seç.

**Yeni dosyalar:**
```
lib/features/arac_profili/
├── domain/
│   └── entities/
│       └── arac_profil.dart             # Profil entity (ad, yakitTipi, tuketim, depo, plaka)
└── presentation/
    ├── providers/
    │   └── arac_profil_provider.dart    # CRUD + aktif araç seçimi
    └── screens/
        └── arac_profil_screen.dart      # Profil listesi + ekleme
```

**Değiştirilecek dosyalar:**
- `ayarlar_screen.dart` → "Araçlarım" menü öğesi
- `hesaplama_screen.dart` → Araç seçici (presetler yerine gerçek profiller)
- `yakit_defteri_screen.dart` → Araç bazlı filtreleme

---

## Faz 3 — Fiyat Tahmini + ÖTV Hesaplayıcı
**Süre tahmini: Orta | Bağımlılık: Faz 1B (döviz verisi)**

### 3A. Fiyat Tahmini (Özellik #5)
**Açıklama:** Son 30 gün fiyat trendine göre basit tahmin: "Önümüzdeki hafta benzin artabilir ↑"

**Yöntem:** Basit lineer regresyon (son N günün fiyat geçmişi) — cache_manager'daki price history verisini kullanır.

**Yeni dosyalar:**
```
lib/features/fiyatlar/domain/usecases/
    └── fiyat_tahmin.dart               # Tahmin algoritması (lineer regresyon)
lib/features/fiyatlar/presentation/widgets/
    └── tahmin_karti.dart               # Tahmin gösterge widget'ı
```

**Değiştirilecek dosyalar:**
- `il_detay_screen.dart` → Fiyat kartlarının altına tahmin kartı
- `anasayfa_screen.dart` → Ulusal ortalama altına genel tahmin

**Tahmin gösterimi:**
- Yeşil ↓ "Düşüş bekleniyor (%X olasılık)"
- Kırmızı ↑ "Artış bekleniyor (%X olasılık)"
- Gri → "Sabit kalması bekleniyor"
- Alt not: "Son X günlük trend analizi"

### 3B. ÖTV Hesaplayıcı (Özellik #8)
**Açıklama:** Fiyatın kaçı vergi, kaçı ham petrol — pasta grafiği.

**Veri:** Sabit oran verisi (EPDK yayınları baz alınarak güncellenen JSON)
```
assets/data/otv_oranlari.json
{
  "benzin95": { "otv": 7.52, "kdv_oran": 20, "dagitici_marj": ~2.5, "bayi_marj": ~0.7 },
  "motorin": { "otv": 5.35, "kdv_oran": 20, ... }
}
```

**Yeni dosyalar:**
```
lib/features/fiyatlar/presentation/screens/
    └── otv_hesaplayici_screen.dart     # Pasta grafik + detay tablo
```
**Değiştirilecek dosyalar:**
- `il_detay_screen.dart` → "Fiyat Analizi" butonu
- `assets/data/otv_oranlari.json` → ÖTV/KDV oranları

---

## Faz 4 — Türkiye Isı Haritası + Aylık Rapor
**Süre tahmini: Büyük | Bağımlılık: Faz 2A (yakıt defteri)**

### 4A. Türkiye Isı Haritası (Özellik #10)
**Açıklama:** SVG harita üzerinde illeri fiyata göre renklendir.

**Yöntem:** `flutter_svg` + Türkiye il SVG dosyası. Her il'e `path id` ile erişip renk atanır.

**Yeni paket:** `flutter_svg: ^2.0.10`

**Yeni dosyalar:**
```
assets/images/turkiye_iller.svg          # Türkiye il haritası SVG
lib/features/fiyatlar/presentation/screens/
    └── isi_haritasi_screen.dart         # SVG render + renklendirme
lib/features/fiyatlar/presentation/providers/
    └── isi_haritasi_provider.dart       # Tüm illerin fiyatlarını toplar
```

**Değiştirilecek dosyalar:**
- `anasayfa_screen.dart` → "Isı Haritası" butonu
- `pubspec.yaml` → flutter_svg eklenir, assets kaydedilir

**Renk skalası:** Min fiyat → Yeşil, Orta → Sarı, Max fiyat → Kırmızı

### 4B. Aylık Rapor (Özellik #9)
**Açıklama:** Yakıt defteri verisinden aylık harcama raporu.

**Yeni dosyalar:**
```
lib/features/yakit_defteri/presentation/screens/
    └── aylik_rapor_screen.dart         # Aylık özet + grafikler
```

**İçerik:**
- Toplam harcama kartı (₺)
- Toplam litre
- Ortalama km/L
- Geçen ayla karşılaştırma (%değişim)
- Harcama grafiği (günlük/haftalık bar chart)
- Yakıt tipi dağılımı (pasta grafik)

---

## Faz 5 — Ana Ekran Widget + Paylaş + i18n
**Süre tahmini: Orta | Bağımlılık: Yok**

### 5A. Android Ana Ekran Widget'ı (Özellik #4)
**Açıklama:** Android home screen'de favori ilin benzin/motorin fiyatını gösteren widget.

**Yöntem:** `home_widget: ^0.7.0` paketi — native Android widget + Flutter data bridge.

**Yeni paket:** `home_widget: ^0.7.0`

**Yeni dosyalar:**
```
# Dart tarafı
lib/core/utils/home_widget_manager.dart  # Widget güncelleme logic

# Android native tarafı
android/app/src/main/java/.../FiyatWidgetProvider.java   # AppWidgetProvider
android/app/src/main/res/layout/fiyat_widget.xml         # Widget layout XML
android/app/src/main/res/xml/fiyat_widget_info.xml       # Widget metadata
```

**Değiştirilecek dosyalar:**
- `AndroidManifest.xml` → widget receiver kaydı
- `main.dart` → widget güncellemesi (fiyat çekildikten sonra)
- `pubspec.yaml` → home_widget eklenir

**Widget gösterimi:**
```
┌─────────────────────┐
│ ⛽ YakıtTakip       │
│ Ankara              │
│ Benzin: 97.17₺     │
│ Motorin: 72.18₺    │
│ Son: 2 dk önce      │
└─────────────────────┘
```

### 5B. Paylaş Butonu (Fiyatlar) (Özellik #11)
**Açıklama:** İl fiyatlarını metin olarak paylaş.

**Değiştirilecek dosyalar:**
- `il_detay_screen.dart` → AppBar'a paylaş ikonu
- `karsilastirma_screen.dart` → Sonuç tablosu altına paylaş butonu
- `anasayfa_screen.dart` → Ulusal ortalama kartına paylaş

**Paylaş formatı:**
```
YakitTakip - Ankara Fiyatlari
Benzin 95: 97.17 TL
Motorin: 72.18 TL
LPG: 31.15 TL
Son guncelleme: 22.03.2026
```

### 5C. Dil Desteği / i18n (Özellik #12)
**Açıklama:** Türkçe + İngilizce dil desteği.

**Yöntem:** Flutter'ın `intl` + `flutter_localizations` + ARB dosyaları

**Yeni dosyalar:**
```
lib/l10n/
├── app_tr.arb                          # Türkçe çeviriler
└── app_en.arb                          # İngilizce çeviriler
lib/core/l10n/
    └── l10n.dart                       # Lokalizasyon helper
```

**Değiştirilecek dosyalar:**
- `pubspec.yaml` → `generate: true`, `flutter_localizations`
- `app.dart` → `localizationsDelegates`, `supportedLocales`
- `ayarlar_screen.dart` → Dil seçici (Türkçe / English)
- Tüm ekranlar → hardcoded string'ler → `AppLocalizations.of(context).xxx`

---

## Faz 6 — Entegrasyon + Son Dokunuşlar
**Süre tahmini: Küçük | Bağımlılık: Tüm fazlar**

- Tüm yeni özelliklerin bildirim entegrasyonu
- Home widget'ın WorkManager ile periyodik güncellenmesi
- Yakıt defteri verisiyle tahmin algoritmasının iyileştirilmesi
- Final test + hata düzeltme
- `flutter analyze` + `flutter build apk --release`

---

## Faz Özeti

| Faz | Özellikler | Yeni Paketler | Zorluk |
|-----|-----------|---------------|--------|
| 1 | Yakınımdaki İstasyonlar + Döviz Etkisi | geolocator | Büyük |
| 2 | Yakıt Defteri + Çoklu Araç | — | Orta |
| 3 | Fiyat Tahmini + ÖTV Hesaplayıcı | — | Orta |
| 4 | Isı Haritası + Aylık Rapor | flutter_svg | Büyük |
| 5 | Ana Ekran Widget + Paylaş + i18n | home_widget | Orta |
| 6 | Entegrasyon + Test | — | Küçük |

## Doğrulama (Her faz sonrası)
1. `flutter analyze` — 0 hata
2. `flutter build apk --debug` — başarılı build
3. Her yeni ekran açılır, veri yüklenir
4. Mevcut özellikler hala çalışır (regresyon yok)
5. Pull-to-refresh + yenile butonu çalışır
