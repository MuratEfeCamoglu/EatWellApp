# Denge (EatWellApp) — Proje İskeleti ve Sınırları

> Bu dosya projenin **tek doğruluk kaynağıdır**: neyi yapıyoruz, neyi yapmıyoruz, ne zaman "bitti" diyeceğiz.
> Komutlar ve kod kuralları için `CLAUDE.md`, agent davranışı için `AGENT.md`.
> Ürün adı **Denge**; GitHub deposu `EatWellApp`; Dart paket adı `denge`; Android `applicationId` `com.denge.denge`.
> Son güncelleme: 2026-10-05 (repo durumu: commit `434d1c4`).

---

## 1. Amaç ve Hedef Kullanıcı

- **Sorun:** Genel kalori uygulamaları (MyFitnessPal vb.) Türk mutfağını zayıf tanır; "mercimek çorbası", "menemen", "lahmacun" gibi yemekleri bulmak, porsiyonlamak ve kaydetmek zahmetlidir. Bu yüzden kullanıcı birkaç gün sonra kaydı bırakır.
- **Hedef kullanıcı:** Türkiye'de yaşayan, Türkçe konuşan, 18–60 yaş arası, kilo vermek/korumak/almak isteyen ve akıllı telefon (Android 8+ / iOS 15+) kullanan bireyler. Diyetisyen/klinik kullanımı hedef değildir.
- **Değer önerisi:** Türk yemeklerini tanıyan katalog + barkod + fotoğrafla hızlı kayıt, kişiye özel kalori/makro hedefi, hedefe uygun Türk tarifleri. Tamamen cihaz üzerinde, hesap/sunucu gerektirmeden çalışır.
- **Başarı ölçütleri (MVP için, ölçülebilir):**
  - B1: Kurulumu tamamlamış bir kullanıcı, ana sayfadan katalogdaki bir yiyeceği **en fazla 3 dokunuşla** (klavyeyle arama yazmak hariç) bir öğüne ekleyebilir: öğün kartındaki "+" → listedeki yiyecek → "Ekle".
  - B2: Uygulama kapatılıp açıldığında **son 365 güne ait tüm günlük kayıtları, su ve kilo geçmişi** eksiksiz geri gelir.
  - B3: Kurulum sihirbazı (cinsiyet → sonuç ekranı) **7 ekranda** tamamlanır ve sonuçta hesaplanan kalori hedefi §3.3'teki formülle birebir aynıdır.

---

## 2. Mevcut Durum (2026-10-05 itibarıyla yapılanlar)

Uygulama Flutter ile yazılmış, **arka uç (backend) olmayan, tek cihazlı** bir prototiptir. ~13.800 satır Dart kodu, 31 ekran/bileşen dosyası.

| Alan | Durum | Not |
|---|---|---|
| Splash, karşılama (onboarding), kayıt/giriş ekranları | ✅ Var | Giriş/kayıt **sahte**: şifre doğrulanmaz, saklanmaz; sadece ad/e-posta taslağa yazılır. |
| 7 adımlı kurulum sihirbazı + kişisel plan | ✅ Var | Mifflin-St Jeor + aktivite çarpanı, `AppState.completeSetup()`. Profil `shared_preferences`'a yazılır. |
| Ana sayfa (kalori halkası, makro çubukları, su) | ✅ Var | |
| Günlük (Diary) ekranı | ⚠️ Kısmi | Sadece **bugün** bellekte tutulur; geçmiş günler her zaman boş; uygulama kapanınca günlük **silinir**; kayıt silme/düzenleme yok. Öğün başına tek satır (`MealEntry`) – tek tek yiyecekler tutulmuyor. |
| Yiyecek kataloğu | ✅ Var | `mock_data.dart` + `extra_foods.dart` + `more_foods.dart` ≈ 220 yiyecek, 12 kategori, `assets/foods/` altında 222 fotoğraf. |
| Arama ekranı | ⚠️ Kısmi | Kategori ve öğüne göre süzme var; arama sadece `toLowerCase` ile — "cilbir" yazınca "Çılbır" bulunmuyor. |
| Barkod tarama | ✅ Var | `mobile_scanner`; önce yerel `barcodeCatalog`, sonra Open Food Facts (12 sn zaman aşımı). Birim testli. |
| Fotoğrafla tanıma | ✅ Var (sezgisel) | ML Kit genel etiketleyici + İngilizce etiket→Türkçe anahtar kelime tablosu; en fazla 3 aday, kullanıcı onaylar. |
| Tarifler (51 adet) + detay + favoriler | ✅ Var | "Sana özel": kalan kaloriye sığan, proteini yüksek tarifler. Favoriler kalıcı. |
| İlerleme (kilo grafiği, seri) | ⚠️ Kısmi | Kilo geçmişi **kalıcı değil** (her açılışta tek nokta). Seri (streak) **hiç artmıyor** (hep 0). |
| Su takibi | ⚠️ Kısmi | 10 bardak × 250 ml; **kalıcı değil**, gün değişince sıfırlanmıyor. |
| Profil + rozetler | ⚠️ Kısmi | Rozetler sadece "bugün"e bakıyor; seri 0 olduğu için "7 gün seri" hiç kazanılamıyor. |
| Ayarlar: tema, yazı boyutu, animasyon azaltma | ✅ Var | Kalıcı. |
| İşlevsiz butonlar | ❌ Boş | 17 yerde `onTap/onPressed: () {}` veya "yakında": giriş/kayıt (Google ile devam et ×2, Şifremi unuttum), profil (düzenle ikonu, Rozetler başlığındaki buton, Kişisel bilgiler, Hedefler ve makrolar, Bildirimler, Yardım ve destek), ilerleme (takvim ikonu), arama (Yiyeceği kendin ekle), ayarlar (Birimler, Şifreyi değiştir, Gizlilik ve veriler, Çıkış yap, bir ikon butonu, English). |
| Testler | ⚠️ Az | `test/product_lookup_test.dart` (9 test), `test/widget_test.dart` (1 duman testi). |
| Depo hijyeni | ⚠️ | `android/build/reports/` ve `.claude/scheduled_tasks.lock` yanlışlıkla commit'lenmiş. |

---

## 3. Kapsam

> Yeni özellikler kullanıcı belirledikçe §3.1 tablosuna yeni F-numarasıyla (F18, F19…) ve ölçülebilir kabul kriteriyle eklenir; ilgili aşama §7'ye işlenir.

### 3.1 Kapsam İçi (MVP)

Durum sütunu: **Var** = mevcut ve kriteri karşılıyor, **Kısmi** = mevcut ama kriteri karşılamıyor, **Yok** = yazılacak.

| # | Özellik | Öncelik | Durum | Kabul Kriteri (ölçülebilir) |
|---|---|---|---|---|
| F1 | Kurulum sihirbazı ve kişisel plan | Zorunlu | Kısmi | 7 ekran (cinsiyet, yaş, boy, kilo, aktivite, hedef, sonuç) tamamlanınca `calorieGoal`, `proteinGoalG`, `carbsGoalG`, `fatGoalG` §3.3 formülüyle hesaplanır; birim testi ≥ 6 senaryoyu (2 cinsiyet × 3 hedef) doğrular (henüz yok); uygulama yeniden açılınca kurulum tekrar sorulmaz. |
| F2 | Kalıcı, tarih bazlı yemek günlüğü | Zorunlu | Kısmi | (a) Her eklenen yiyecek ayrı bir `FoodLogEntry` olarak kaydedilir; (b) uygulama zorla kapatılıp açıldığında bugünkü ve geçmiş günlerin kayıtları aynen görünür; (c) Günlük ekranında herhangi bir geçmiş güne (≤ 365 gün geriye) gidildiğinde o günün kayıtları mevcut 4 öğün kartı altında (kahvaltı, öğle, akşam, ara öğün) her kayıt ayrı satır olarak — ad, miktar, kcal — listelenir; (d) gelecekteki bir güne kayıt eklenemez. |
| F3 | Günlük kaydını silme ve miktarını düzenleme | Zorunlu | Yok | Kayıt sola kaydırılınca silinir ve 4 sn boyunca "Geri al" SnackBar'ı gösterilir (Geri al'a basınca kayıt aynı öğüne geri gelir); kayda dokununca `FoodDetailScreen` düzenleme modunda açılır (buton "Güncelle"), miktar ve öğün F7 kurallarıyla değiştirilir; silme/düzenleme sonrası ana sayfa ve Günlük toplamları uygulama yeniden başlatılmadan güncel değeri gösterir (widget testiyle doğrulanır); değişiklik kalıcıdır. |
| F4 | Yiyecek arama ve katalog | Zorunlu | Kısmi | Türkçe karakter duyarsız arama: "cilbir" → "Çılbır", "IZGARA" → "Izgara Köfte", "sut" → "Süt" bulunur (`foodImageSlug` benzeri normalize fonksiyonu, birim testli); ≈ 220 öğelik katalogda her tuş vuruşundan sonra liste ≤ 100 ms içinde güncellenir (profile build, orta sınıf cihaz – bkz. §6); kategori filtresi 12 kategorinin hepsini gösterir. |
| F5 | Barkod ile ekleme | Zorunlu | Var | Yerel katalogdaki barkod ağ çağrısı yapmadan bulunur; bilinmeyen barkodda "Ürün bulunamadı" ekranı; ağ yoksa ≤ 12 sn içinde Türkçe hata mesajı; mevcut 9 birim testi geçer. |
| F6 | Fotoğrafla tanıma (öneri) | Zorunlu | Kısmi | Fotoğraf çekildikten sonra en fazla 3 aday gösterilir; kullanıcı onaylamadan hiçbir kayıt eklenmez; aday yoksa arama ekranında "Fotoğraftan ne olduğunu anlayamadık. Elle aramayı dene." SnackBar'ı çıkar (mevcut); kamera iptalinde hiçbir mesaj çıkmaz; `matchFoodLabels` için ≥ 3 birim testi vardır (eksik). |
| F7 | Yiyecek detayı ve porsiyon | Zorunlu | Var | Porsiyon 0,5 adımla 0,5–10 aralığında ayarlanır (mevcut davranış); gösterilen kalori = `caloriesPer100g × miktar` (yuvarlanmış tam sayı); hedef öğün seçilebilir. |
| F8 | Ana sayfa özeti | Zorunlu | Kısmi | Seçili günün (bugün) tüketilen/kalan kalorisi ve 3 makro, F2 kayıtlarının toplamına eşittir (birim testli). Kalan kalori negatifse "X kcal aşıldı" yazar. |
| F9 | Kalıcı su takibi | Zorunlu | Kısmi | Bardak sayısı tarih bazlı saklanır; yerel saatle gece yarısından sonra açılan uygulamada bugünkü değer 0'dır; geçmiş günlerin değeri silinmeden saklanır (F12 "Su ustası" bunu kullanır; Günlük ekranında su gösterimi MVP'de zorunlu değil); üst sınır 10 bardak (2,5 L). |
| F10 | Kalıcı kilo geçmişi ve ilerleme grafiği | Zorunlu | Kısmi | Her kilo kaydı (tarih, kg) saklanır; aynı gün ikinci kayıt öncekinin üzerine yazar; grafik "Haftalık" sekmesinde son 7 günü, "Aylık" sekmesinde son 30 günü gösterir; kilo 30–300 kg aralığı dışında reddedilir. |
| F11 | Seri (streak) hesaplama | Zorunlu | Kısmi | Seri = bugünden (bugün kayıt yoksa dünden) geriye doğru **en az 1 yiyecek kaydı olan ardışık gün** sayısı; F2 verisinden hesaplanır, ayrı saklanmaz; ≥ 5 birim testi (boş, 1 gün, boşluklu, bugün kayıtsız, ay geçişi). |
| F12 | Rozetler | İsteğe bağlı | Kısmi | 4 rozet: İlk adım (ilk kayıt yapıldı, kalıcı), 7 gün seri (seri ≥ 7), Su ustası (herhangi bir günde 10 bardak), Protein avcısı (herhangi bir günde protein ≥ hedef). Kazanılan rozet bir daha kaybedilmez. |
| F13 | Tarifler, favoriler, "Sana özel", tarifi günlüğe ekleme | Zorunlu | Kısmi | 51 tarifin hepsinin fotoğrafı yüklenir (eksik asset testi); favori kalıcıdır; "Günlüğe ekle" 1 porsiyonu F2'ye `FoodLogEntry` olarak yazar. |
| F14 | Tema, yazı boyutu, animasyon azaltma | Zorunlu | Kısmi | 4 yazı boyutu (0,9/1,0/1,15/1,3) ve "Çok büyük"te hiçbir ana ekranda taşma (overflow) hatası yoktur (widget testi 320×640 dp); ayarlar yeniden açılışta korunur. |
| F15 | Hedefleri/profili düzenleme | Zorunlu | Yok | Profil'deki düzenle ikonu, "Kişisel bilgiler" ve "Hedefler ve makrolar" satırları kurulum sihirbazını mevcut değerlerle (ad, cinsiyet, yaş, boy, güncel kilo, aktivite, hedef, tempo) önceden doldurulmuş açar; tamamlanınca yeni hedefler kaydedilir, geçmiş günlük kayıtları **silinmez**. |
| F16 | Verileri sil / sıfırla ("Çıkış yap" yerine) | Zorunlu | Yok | Ayarlar'daki "Çıkış yap" butonu **"Tüm verileri sil"** olarak yeniden adlandırılır; onay diyaloğundan sonra tüm `shared_preferences` anahtarları silinir ve uygulama karşılama ekranına döner; sonrasında açılışta kurulum tekrar istenir. |
| F17 | İşlevsiz butonların temizlenmesi | Zorunlu | Yok | §2'deki 17 işlevsiz öğe için karar: F15'e bağlananlar (düzenle ikonu, Kişisel bilgiler, Hedefler ve makrolar), F16'ya bağlanan (Çıkış yap), **kaldırılanlar** (Google ile devam et ×2, Şifremi unuttum, Şifreyi değiştir, Bildirimler, Yardım ve destek, Birimler, Gizlilik ve veriler, Yiyeceği kendin ekle, English seçeneği, Rozetler başlığındaki buton, ilerleme takvim ikonu, ayarlardaki işlevsiz ikon butonu). Bitti kontrolü: `grep -rnE "(onTap|onPressed): \(\) \{\}" lib/` ve `grep -rn "yakında" lib/` boş döner. |

### 3.2 Sonraki Sürümler (MVP sonrası, şimdi yapılmayacak)

- İngilizce dil desteği (`flutter_localizations` + ARB dosyaları).
- Kullanıcının kendi yiyeceğini/tarifini ekleyebilmesi.
- Hatırlatma bildirimleri (su, öğün).
- Gün bazlı detaylı istatistik ekranı (haftalık makro ortalaması).
- Yerel veriyi JSON olarak dışa/içe aktarma (yedekleme).
- Yemeğe özel eğitilmiş görüntü tanıma modeli (TFLite).
- Apple Health / Google Health Connect entegrasyonu.

### 3.3 İş Kuralları (değiştirilmeden uygulanır)

- **BMR (Mifflin-St Jeor):** `10×kg + 6,25×cm − 5×yaş + (erkek ? 5 : −161)`.
- **TDEE:** `BMR × çarpan`; çarpanlar: hareketsiz 1,2 / hafif 1,375 / orta 1,55 / aktif 1,725.
- **Hedef kalori:** ver → `TDEE − haftalıkTempo×7700/7`; al → `+`; koru → `TDEE`. Sonra `[taban, 4000]` aralığına sıkıştır; taban kadın 1200, erkek 1500.
- **Makrolar:** protein = `kg × 1,8` g; yağ = `kalori × 0,27 / 9` g; karbonhidrat = kalan kalori / 4 g (0–999).
- **Haftalık tempo:** 0,25 / 0,5 / 0,75 kg seçeneklerinden biri (`setup_goal_screen.dart` `_weeklyPaceOptions`); "koru" hedefinde kullanılmaz.
- **Su:** 1 bardak = 250 ml, günlük hedef 10 bardak.
- **Gün sınırı:** cihazın yerel saat diliminde 00:00.
- **Besin değerleri:** katalogda 100 g (veya `servingLabel`) başınadır; tarif değerleri porsiyon başınadır.

---

## 4. Mimari

- **Genel yaklaşım:** Çevrimdışı öncelikli, tek modüllü (monolit) Flutter istemcisi. Sunucu yok. Tek dış ağ çağrısı Open Food Facts (salt okuma, API anahtarsız).
- **Durum yönetimi:** `provider` + tekil `AppState` (`ChangeNotifier`). Ekranlar `context.watch/select` ile dinler.
- **Kalıcılık:** `shared_preferences`. Ayarlar ve profil düz anahtarlarda; **tarih bazlı veriler (günlük, su, kilo) JSON olarak** saklanır (bkz. veri modeli). Depolama erişimi yeni bir `LocalStore` sınıfı arkasında toplanır ki ileride `sqflite`'a geçiş tek dosyayı etkilesin.
- **Yönlendirme:** `lib/router.dart` içinde isimli rotalar (`AppRoutes`) + argümanlı rotalar için `push*` yardımcıları. Yeni rota buraya eklenir.

### 4.1 Bileşenler ve sorumlulukları

| Bileşen | Dosya | Sorumluluk |
|---|---|---|
| `AppState` | `lib/data/app_state.dart` | Uygulama durumu, kurulum, ayarlar; UI'a `notifyListeners`. İş mantığını kendisi hesaplamaz, aşağıdakilere devreder. |
| `NutritionCalculator` (yeni) | `lib/data/nutrition_calculator.dart` | §3.3 formülleri; saf fonksiyonlar, Flutter bağımlılığı yok. `AppState._bmr` ve `completeSetup` içindeki hesaplar buraya taşınır. |
| `LocalStore` (yeni) | `lib/data/local_store.dart` | `shared_preferences` üzerinden günlük/su/kilo okuma-yazma, JSON serileştirme, şema sürümü. |
| `StreakCalculator` (yeni) | `lib/data/streak.dart` | F11 seri hesabı; saf fonksiyon. |
| Katalog verisi | `lib/data/mock_data.dart`, `extra_foods.dart`, `more_foods.dart`, `recipes.dart` | Statik `const` yiyecek/tarif listeleri, barkod kataloğu. |
| Barkod arama | `lib/data/product_lookup.dart` | Yerel katalog → Open Food Facts; `sealed` sonuç tipleri. |
| Fotoğraf tanıma | `lib/data/food_recognition.dart` | ML Kit etiketleri → katalog eşleşmesi. |
| Ekranlar | `lib/screens/<alan>/` | Sadece sunum ve kullanıcı etkileşimi. |
| Tema | `lib/theme/` | `AppTheme.light/dark`, `DengeColors` (`context.dengeColors`). |
| Ortak bileşenler | `lib/widgets/` | ≥ 2 ekranda kullanılan widget'lar. |

### 4.2 Veri Modeli

Mevcut (`lib/data/models.dart`): `UserProfile`, `FoodItem`, `FoodCategory`, `MealType`, `MealEntry`, `Recipe`, `RecipeDifficulty`, `WeightEntry`; `app_state.dart` içinde `SetupDraft`, `Gender`, `ActivityLevel`, `WeightGoal`, `TextScaleOption`.

Eklenecek / değişecek:

```text
FoodLogEntry                      // F2 — günlükteki tek bir kayıt
  id: String                      // microsecondsSinceEpoch.toString()
  date: String                    // 'yyyy-MM-dd', yerel saat
  meal: MealType
  foodName: String
  brand: String
  servingLabel: String
  amount: double                  // porsiyon çarpanı (0.25–10)
  kcal: int                       // kayıt anında hesaplanır, sonra katalog değişse de sabit kalır
  proteinG, carbsG, fatG: double
  loggedAt: DateTime

DayLog                            // hesaplanan görünüm, saklanmaz
  date, entries: List<FoodLogEntry>, waterGlasses: int
  totals: kcal / protein / carbs / fat

WeightEntry                       // mevcut sınıf; JSON serileştirme eklenir
  date: String ('yyyy-MM-dd'), kg: double
```

- `MealEntry` ekranlarda öğün özeti olarak kalabilir ama artık **`FoodLogEntry` listesinden türetilir**, ayrıca saklanmaz.
- İlişkiler: `UserProfile 1 — N FoodLogEntry` (tek kullanıcı), `DayLog 1 — N FoodLogEntry`, `UserProfile 1 — N WeightEntry`. `FoodLogEntry` katalog öğesine referans tutmaz; değerlerin kopyasını tutar (katalog güncellemesi geçmişi değiştirmesin diye).

### 4.3 Saklama Anahtarları (`shared_preferences`)

| Anahtar | Tip | İçerik |
|---|---|---|
| Mevcut `theme_mode`, `text_scale`, `reduce_motion`, `locale`, `setup_complete`, `user_*`, `favorite_recipes` | — | Değişmez (geriye uyumluluk). |
| `schema_version` | int | Başlangıç `1`. Format değişirse artırılır ve `LocalStore.load` içinde göç yazılır. |
| `log_entries` | String (JSON dizi) | Tüm `FoodLogEntry` kayıtları. 365 günden eski kayıtlar açılışta silinir. |
| `water_by_day` | String (JSON nesne) | `{"2026-10-05": 6, ...}` |
| `weight_history` | String (JSON dizi) | `[{"date":"2026-10-05","kg":71.2}, ...]` |
| `badges_earned` | StringList | Kazanılmış rozet kimlikleri (F12). |

### 4.4 Dış Bağımlılıklar

| Paket / servis | Amaç |
|---|---|
| `provider` ^6.1 | Durum yönetimi |
| `shared_preferences` ^2.5 | Yerel depolama |
| `fl_chart` ^0.69 | Kilo grafiği |
| `mobile_scanner` ^7.4 | Barkod tarama |
| `image_picker` ^1.2 | Kamera |
| `google_mlkit_image_labeling` ^0.15 | Cihaz üstü görüntü etiketleme |
| `http` ^1.6 | Open Food Facts |
| Open Food Facts API v2 | `GET https://world.openfoodfacts.org/api/v2/product/<barkod>.json` — anahtar yok, `User-Agent` zorunlu |
| `tool/fetch_food_images.py` (Python 3, `requests`, `Pillow`) | Sadece geliştirme: Wikimedia'dan yiyecek/tarif fotoğrafı indirir. Uygulamaya dahil değildir. |

---

## 5. Klasör Yapısı

`(yeni)` işaretliler MVP sırasında eklenecek; diğerleri mevcuttur.

```
EatWellApp/
├── CLAUDE.md, ISKELET.md, AGENT.md, README.md
├── pubspec.yaml, pubspec.lock, analysis_options.yaml
├── lib/
│   ├── main.dart                 # Giriş: AppState.load() → DengeApp
│   ├── router.dart               # AppRoutes (tüm rotalar burada)
│   ├── data/                     # Model, durum, iş mantığı, veri. Saf mantık dosyaları (nutrition_calculator, streak,
│   │                             # model JSON dönüşümleri) Flutter import etmez; app_state/models/mock_data mevcut haliyle istisna
│   │   ├── models.dart
│   │   ├── app_state.dart
│   │   ├── nutrition_calculator.dart   (yeni)
│   │   ├── local_store.dart            (yeni)
│   │   ├── streak.dart                 (yeni)
│   │   ├── mock_data.dart, extra_foods.dart, more_foods.dart, recipes.dart
│   │   ├── product_lookup.dart
│   │   └── food_recognition.dart
│   ├── screens/<alan>/<ad>_screen.dart  # auth, diary, food, home, onboarding, profile,
│   │                                    # progress, recipes, search, settings, setup, splash
│   │   └── main_shell.dart       # Alt sekme çubuğu
│   ├── theme/                    # app_colors.dart, app_theme.dart
│   └── widgets/                  # Paylaşılan widget'lar
├── test/                         # lib/ yapısını aynalar: lib/data/x.dart → test/data/x_test.dart
│   ├── product_lookup_test.dart  # (mevcut; taşınması zorunlu değil)
│   └── widget_test.dart
├── assets/
│   ├── foods/<slug>.jpg          # 256×256, slug = foodImageSlug(ad)
│   ├── recipes/<slug>.jpg        # 800×600
│   └── fonts/Nunito-*.ttf
├── tool/fetch_food_images.py
├── docs/screenshots/*.png        # README görselleri
├── android/, ios/                # Platform kabukları — sadece izin/ayar değişikliği
```

---

## 6. Kısıtlar

- **Teknik:**
  - Flutter stable, Dart SDK `^3.9.2` (`pubspec.lock`: flutter ≥ 3.35, dart ≥ 3.11). Hedef platformlar: Android (minSdk = Flutter varsayılanı) ve iOS 15+.
  - Yeni paket eklemek onay gerektirir (bkz. AGENT.md). Tercih: pub.dev'de "Flutter Favorite" veya ≥ 1000 like ve son 12 ayda güncellenmiş paketler.
  - `lib/data/` altındaki iş mantığı (hesap, seri, serileştirme) Flutter widget'ı import etmez → saf Dart birim testiyle test edilir.
- **Performans** (orta sınıf cihaz = Android 13, 6 GB RAM, Pixel 6a sınıfı; profile build; eşikler Aşama 0'da ilk ölçümle doğrulanır):
  - Soğuk açılıştan ana sayfanın ilk karesine ≤ 3 sn.
  - Arama listesi güncellemesi ≤ 100 ms; kaydırmada kare süresi ≤ 16 ms (DevTools "jank" yok).
  - `AppState.load()` 365 günlük veriyle ≤ 300 ms.
  - Release APK (`--split-per-abi`, arm64) ≤ 60 MB.
- **Güvenlik / gizlilik:**
  - Şifre hiçbir yerde saklanmaz, loglanmaz.
  - Kişisel veri (ad, e-posta, kilo, günlük) cihaz dışına gönderilmez. Open Food Facts'e **yalnızca barkod numarası** gider.
  - Kamera görüntüsü sadece cihaz üstü ML Kit'te işlenir; diske kalıcı kopya tutulmaz (geçici dosya hariç).
  - Kamera izni Android `AndroidManifest.xml` ve iOS `NSCameraUsageDescription` ile Türkçe gerekçeyle istenir.
- **Erişilebilirlik:** Tüm dokunma hedefleri ≥ 48×48 dp; ikon-only butonlarda `tooltip` veya `Semantics` etiketi; metin/arka plan kontrastı ≥ 4.5:1 (her iki temada).
- **Dil:** Arayüz metinleri Türkçe ve doğrudan kodda (MVP'de i18n altyapısı yok).
- **Zaman / bütçe:** Tek geliştirici + AI agent; sıfır altyapı maliyeti (sunucu yok). MVP için hedef: §7'deki 6 aşama.

---

## 7. Geliştirme Aşamaları

Sıra bağımlılığa göredir; bir aşama "Bitti Kriteri" karşılanmadan sonrakine geçilmez.

| Aşama | İçerik | Özellikler | Bitti Kriteri |
|---|---|---|---|
| 0 — Temel ve hijyen | Flutter ortamını doğrula; `android/build/` ve `.claude/scheduled_tasks.lock`'u git'ten çıkar ve `.gitignore`'a ekle; `pubspec.yaml` `description` alanını "Denge – Türk mutfağı kalori takibi" yap; `flutter analyze`'daki tüm uyarıları sıfırla; release APK boyutunu ve soğuk açılışı ölç. | — | `flutter analyze` 0 sorun; `flutter test` yeşil; `git ls-files android/build` boş; ölçüm sonuçları §6'ya yazıldı. |
| 1 — Hesap katmanı | `NutritionCalculator` çıkar, `AppState.completeSetup` onu kullansın; birim testleri. | F1 | F1 kabul kriteri; `test/data/nutrition_calculator_test.dart` ≥ 6 test geçer; davranış değişmedi (aynı girdi → aynı hedef). |
| 2 — Kalıcı günlük | `FoodLogEntry`, `LocalStore`, `schema_version`; `addFoodToMeal` yeni modele; Diary geçmiş günleri gösterir; ana sayfa toplamları türetilir. | F2, F8, F13 (günlüğe ekleme) | F2 ve F8 kriterleri; serileştirme gidiş-dönüş testi; elle test: kayıt ekle → uygulamayı öldür → aç → kayıt duruyor. |
| 3 — Düzenleme, su, kilo | Silme + geri al, miktar düzenleme; su ve kilo tarih bazlı ve kalıcı. | F3, F9, F10 | F3, F9, F10 kriterleri; ilgili birim/widget testleri geçer. |
| 4 — Seri, rozet, profil düzenleme | `StreakCalculator`, kalıcı rozetler, hedef düzenleme. | F11, F12, F15 | F11, F12, F15 kriterleri. |
| 5 — Ayar temizliği ve cila | "Tüm verileri sil", boş butonların kaldırılması, erişilebilirlik ve taşma testleri, F6 testleri, eksik asset testi. | F4, F6, F14, F16, F17 | Tüm F kriterleri; `lib/data/` satır kapsamı ≥ %70 (`flutter test --coverage`); `flutter build apk --release` ve `flutter build ios --release --no-codesign` başarılı. |

---

## 8. Riskler

| # | Risk | Etki | Olasılık | Önlem |
|---|---|---|---|---|
| R1 | `shared_preferences` büyük JSON ile yavaşlar (365 gün × ~8 kayıt ≈ 3.000 kayıt ≈ 600 KB). | Açılış gecikmesi | Orta | 365 gün sınırı; `LocalStore` soyutlaması; ölçüm > 300 ms ise `sqflite`'a geçiş (onay ile). |
| R2 | Mevcut kullanıcıların verisi format değişince bozulur. | Veri kaybı | Orta | `schema_version` + göç fonksiyonu + göç testi; mevcut anahtarlar değiştirilmez. |
| R3 | ML Kit genel etiketleyicisi Türk yemeklerinde yanlış/boş sonuç verir. | Kullanıcı güveni | Yüksek | Her zaman onay adımı; aday yoksa aramaya yönlendirme; özel model "Sonraki Sürümler"de. |
| R4 | Open Food Facts'te Türk ürünleri eksik veya besin değeri hatalı. | Yanlış kalori | Yüksek | Yerel barkod kataloğu önce; enerji verisi olmayan ürün "bulunamadı" sayılır; kullanıcı porsiyonu görür. |
| R5 | Katalogdaki kalori değerleri yaklaşık (kaynak belirtilmemiş). | Yanlış hedef takibi | Orta | Değerler "yaklaşık" olarak etiketlenir; düzeltmeler tek bir veri dosyasında yapılır; tıbbi iddia yok. |
| R6 | Wikimedia fotoğraflarının lisans/atıf yükümlülüğü. | Mağaza reddi / hukuki | Düşük | Mağazaya çıkmadan önce atıf listesi `docs/` altına eklenir (Sonraki Sürümler öncesi kontrol). |
| R7 | Bu bulut ortamında Flutter SDK kurulu değil; agent testleri çalıştıramayabilir. | Doğrulanmamış kod | Yüksek | AGENT.md: komut çalıştırılamazsa "doğrulanmadı" diye raporlanır, iş bitti sayılmaz; SessionStart hook ile Flutter kurulumu önerilir. |
| R8 | Tıbbi tavsiye gibi algılanma (düşük kalori hedefleri). | Kullanıcı sağlığı | Düşük | 1200/1500 kcal tabanı; "genel bilgi" uyarısı; tıbbi iddia içeren metin yok. |

