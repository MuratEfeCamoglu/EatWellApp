# Denge (EatWellApp)

Türk mutfağını tanıyan Flutter kalori ve beslenme takip uygulaması (Android + iOS).
Dart paketi: `denge` (`import 'package:denge/...'`).

Bu dosyanın asıl konusu **yerel veritabanı geçişi**: kullanıcının günlük kayıtları, su ve kilo
geçmişi şu an bellekte duruyor ve uygulama kapanınca kayboluyor. Hedef, bunları cihazdaki bir
SQLite veritabanında kalıcı hale getirmek. Tasarım ileride bulut senkronizasyonu eklenebilecek
şekilde yapılır, ama bu dosyadaki işlerin hiçbiri internet veya sunucu gerektirmez.

---

## 1. Teknoloji yığını

| Alan | Kullanılan |
|---|---|
| Dil / framework | Dart `^3.9.2`, Flutter stable, Material 3 |
| Durum yönetimi | `provider` + tekil `AppState` (`ChangeNotifier`, `AppState.instance`) |
| Basit ayarlar / profil | `shared_preferences` (değişmiyor) |
| **Kullanıcı kayıtları (yeni)** | **SQLite + `drift`** |
| Grafik | `fl_chart` |
| Barkod / kamera | `mobile_scanner`, `image_picker` |
| Görüntü tanıma | `google_mlkit_image_labeling` (cihaz üstü) |
| Ağ | `http` → Open Food Facts API |
| Test | `flutter_test`, `package:http/testing.dart` (`MockClient`) |
| Lint | `flutter_lints` (`analysis_options.yaml`) |

## 2. Komutlar

| İş | Komut |
|---|---|
| Kurulum | `flutter pub get` |
| Çalıştır | `flutter run` |
| Statik analiz | `flutter analyze` |
| Testler | `flutter test` |
| Tek test | `flutter test test/data/db/food_log_dao_test.dart` |
| Drift kod üretimi | `dart run build_runner build --delete-conflicting-outputs` |
| Kod üretimi (izleme) | `dart run build_runner watch --delete-conflicting-outputs` |
| Şema dökümü (migration testi için) | `dart run drift_dev make-migrations` |

Barkod ve fotoğraf özellikleri kamera kullanır, bu yüzden gerçek cihazda denenmeli.
Ortamda `flutter` yoksa komutu çalıştırmış gibi davranma, çalıştırılamadığını açıkça raporla.

---

## 3. Mevcut durum (geçişten önce)

Kaynak: `lib/data/app_state.dart`, `lib/data/models.dart`.

| Veri | Şu an nerede | Sorun |
|---|---|---|
| Profil, hedefler, ayarlar, alerjiler, KVKK onayı | `shared_preferences` | Sorun yok, olduğu gibi kalacak |
| Favori tarifler | `shared_preferences` (başlık listesi) | Başlığa bağlı, ama şimdilik kalabilir |
| Öğünler (`todaysMeals`) | **Bellek** | Uygulama kapanınca siliniyor. Öğün başına yalnızca toplam kalori ve virgülle birleştirilmiş ad metni var, yiyecekler tek tek tutulmuyor, bu yüzden silinemiyor veya düzenlenemiyor |
| Makro toplamları (`proteinConsumedG` vb.) | **Bellek** | Kayıtlardan türetilmesi gerekirken ayrı sayaç olarak tutuluyor |
| Su (`waterGlasses`) | **Bellek** | Tarih yok, gün değişince sıfırlanmıyor, kapanınca siliniyor |
| Kilo geçmişi (`weightHistory`) | **Bellek** | Her açılışta son kilodan tek nokta oluşturuluyor |
| Seri (`streakDays`) | `shared_preferences` | Hep 0, hiçbir yerde hesaplanmıyor |

Bu verileri kullanan yerler:
- `addFoodToMeal`: `search_screen.dart`, `food_detail_screen.dart`, `recipe_detail_screen.dart`
- `todaysMeals`: `home_screen.dart`, `diary_screen.dart`
- `waterGlasses` / `setWaterGlasses`: `home_screen.dart`, `progress_screen.dart`, `profile_screen.dart`
- `weightHistory` / `logWeight`: `progress_screen.dart`, `profile_screen.dart`
- `streakDays`: `home_screen.dart`, `progress_screen.dart`, `profile_screen.dart`
- `diary_screen.dart` tarihler arasında gezebiliyor ama bugün dışındaki her gün için boş gösteriyor (`showEmpty = !isToday || ...`).

---

## 4. Mimari kararlar

1. **Veritabanı:** `drift` + `drift_flutter` (SQLite). Dosya adı `denge.sqlite`, uygulamanın
   belgeler dizininde durur. `drift_flutter`'ın `driftDatabase(name: 'denge')` yardımcısı kullanılır.
2. **Katmanlar** (ekranlar veritabanını hiçbir zaman doğrudan görmez):
   ```
   Ekranlar ──► AppState ──► Repository ──► DAO ──► Drift / SQLite
   ```
   - **DAO** (`lib/data/db/daos/`): SQL sorguları. Drift tiplerini döner.
   - **Repository** (`lib/data/repositories/`): Drift satırlarını uygulama modellerine çevirir,
     UUID ve zaman damgası üretir. İleride bulut senkronizasyonu buraya eklenecek.
   - **AppState:** Ekranlara veriyi sunar, repository'yi çağırır, `notifyListeners()` yapar.
3. **Buluta hazır tasarım:** Her kullanıcı tablosu şu ortak sütunları taşır (bkz. §5.1). Bu sütunlar
   bugün kullanılmasa bile baştan eklenir, böylece ileride senkronizasyon eklemek için şema değişmez.
4. **Türetilen değerler saklanmaz:** Günlük kalori ve makro toplamları, seri ve rozetler her zaman
   kayıtlardan hesaplanır. Ayrı bir sayaç tutulmaz.
5. **Kopya, referans değil:** Günlüğe eklenen yiyeceğin adı, porsiyonu, kalori ve makroları kayıt
   anında satıra kopyalanır. Katalogdaki bir değer sonradan değişirse eski günlük kayıtları değişmez.
6. **Tarih kuralı:** Günlük kayıtlarının günü, cihazın **yerel saatine** göre `yyyy-MM-dd` metni
   olarak tutulur (`date` sütunu). Kesin zaman bilgisi ise UTC milisaniye olarak tutulur.
   Gece 23:30'da eklenen yemek o güne ait olur.
7. **Silme:** Kayıtlar fiziksel olarak silinmez, `deleted_at` doldurulur (yumuşak silme). Tüm
   okuma sorguları `deleted_at IS NULL` filtresi uygular. Bunun sebebi, ileride silme işleminin
   de diğer cihazlara senkronlanabilmesi.

---

## 5. Veri modeli

### 5.1 Tüm kullanıcı tablolarında ortak sütunlar

| Sütun | Tip | Açıklama |
|---|---|---|
| `id` | TEXT, PK | UUID v4, cihazda üretilir (`uuid` paketi) |
| `created_at` | INTEGER | Oluşturulma zamanı, UTC milisaniye |
| `updated_at` | INTEGER | Son değişiklik, UTC milisaniye. Her güncellemede yenilenir |
| `deleted_at` | INTEGER, null olabilir | Doluysa kayıt silinmiş sayılır |
| `synced_at` | INTEGER, null olabilir | Şimdilik hep `null`. Bulut eklenince kullanılacak |

Bu sütunlar Drift'te ortak bir `mixin` ile tanımlanır (`SyncColumns`), her tabloda tekrar yazılmaz.

### 5.2 `food_log_entries`: Günlüğe eklenen her yiyecek

| Sütun | Tip | Açıklama |
|---|---|---|
| *ortak sütunlar* | | §5.1 |
| `date` | TEXT | `yyyy-MM-dd`, yerel gün |
| `meal` | TEXT | `breakfast` / `lunch` / `dinner` / `snack` (`MealType.name`) |
| `food_name` | TEXT | Kopya |
| `brand` | TEXT | Kopya, boş olabilir |
| `serving_label` | TEXT | Örn. `1 porsiyon (200 g)` |
| `amount` | REAL | Porsiyon çarpanı (0.5 – 10) |
| `kcal` | INTEGER | Kayıt anındaki toplam kalori (`caloriesPer100g * amount`, yuvarlanmış) |
| `protein_g`, `carbs_g`, `fat_g` | REAL | Kayıt anındaki toplam (`* amount` uygulanmış) |
| `source` | TEXT | `catalog` / `recipe` / `barcode` / `photo` / `custom` |
| `source_ref` | TEXT, null olabilir | Barkod numarası veya `custom_foods.id` |
| `logged_at` | INTEGER | Eklenme zamanı, UTC ms (liste sıralaması için) |

İndeks: `(date, meal)` ve `(date)`.

> Not: Mevcut kodda `kcal` hesabı `food.caloriesPer100g * amount` şeklinde. Yani `amount`,
> `servingLabel` ile tanımlanan porsiyonun katı ve `caloriesPer100g` aslında porsiyon başı değer
> gibi kullanılıyor. Geçişte bu hesap **olduğu gibi** korunur, düzeltmeye kalkışma.
> Aynı mantık `FoodLogEntry.fromFood(...)` içinde tek bir yerde toplanır.

### 5.3 `water_logs`: Günlük su

| Sütun | Tip | Açıklama |
|---|---|---|
| *ortak sütunlar* | | §5.1 |
| `date` | TEXT, **UNIQUE** | Günde tek satır |
| `glasses` | INTEGER | 0 – `MockData.waterGlassesGoal` (10) |

Bardağa dokunmak o günün satırını oluşturur veya günceller (upsert).

### 5.4 `weight_entries`: Kilo geçmişi

| Sütun | Tip | Açıklama |
|---|---|---|
| *ortak sütunlar* | | §5.1 |
| `date` | TEXT | `yyyy-MM-dd` |
| `kg` | REAL | 25 – 300 arası |
| `measured_at` | INTEGER | UTC ms |

Aynı gün birden fazla kilo girilirse hepsi saklanır. Grafik her gün için **son** ölçümü kullanır.
Profildeki `user_weight` (shared_preferences) son ölçümle eşit tutulmaya devam eder.

### 5.5 `custom_foods`: Kullanıcının kendi eklediği yiyecekler

| Sütun | Tip | Açıklama |
|---|---|---|
| *ortak sütunlar* | | §5.1 |
| `name` | TEXT | Zorunlu, en az 2 karakter |
| `brand` | TEXT | Boş olabilir |
| `serving_label` | TEXT | Örn. `1 porsiyon (150 g)` |
| `kcal_per_serving` | INTEGER | |
| `protein_g`, `carbs_g`, `fat_g` | REAL | Porsiyon başı |
| `category` | TEXT | `FoodCategory.name` |
| `barcode` | TEXT, null olabilir | Barkodla bulunamayan ürün kaydedilirse |

### 5.6 Veritabanında **olmayacaklar**

- Yiyecek kataloğu (`mock_data.dart`, `extra_foods.dart`, `more_foods.dart`) ve tarifler (`recipes.dart`): kodda kalır.
- Profil, hedefler, tema, yazı boyutu, alerjiler, KVKK onayı: `shared_preferences` içinde kalır.
- Günlük toplamlar, seri, rozetler: kayıtlardan hesaplanır, saklanmaz.

---

## 6. Klasör yapısı (hedef)

```
lib/data/
├── db/
│   ├── app_database.dart        # @DriftDatabase, schemaVersion, MigrationStrategy
│   ├── app_database.g.dart      # build_runner üretir; depoya commit edilir
│   ├── tables.dart              # Tablo sınıfları + SyncColumns mixin
│   ├── date_key.dart            # DateTime <-> 'yyyy-MM-dd' çevirileri
│   └── daos/
│       ├── food_log_dao.dart
│       ├── water_dao.dart
│       ├── weight_dao.dart
│       └── custom_food_dao.dart
├── repositories/
│   ├── food_log_repository.dart
│   ├── water_repository.dart
│   ├── weight_repository.dart
│   └── custom_food_repository.dart
├── stats/
│   ├── daily_summary.dart       # Bir günün kalori/makro toplamı (saf Dart)
│   └── streak.dart              # Seri hesabı (saf Dart)
└── ... (mevcut dosyalar)

test/data/
├── db/                          # DAO testleri (bellek içi veritabanı)
├── repositories/
└── stats/
```

`app_database.g.dart` gibi üretilen dosyalar **commit edilir**. Böylece sadece `flutter pub get`
yapan biri de projeyi derleyebilir. Tablo değişince `build_runner` yeniden çalıştırılıp güncel
`.g.dart` dosyası da aynı commit'e eklenir.

---

## 7. Yapılacaklar (aşama aşama)

Her aşama kendi başına çalışır durumda bitmeli: `flutter analyze` temiz, `flutter test` yeşil,
uygulama açılıyor. Bir aşama bitmeden sonrakine geçme.

### Aşama 0: Altyapı

- [x] `pubspec.yaml` dosyasına ekle:
  - `dependencies`: `drift`, `drift_flutter`, `path_provider`, `uuid`
  - `dev_dependencies`: `drift_dev`, `build_runner`
- [x] `lib/data/db/tables.dart`: `SyncColumns` mixin'i ve §5'teki dört tablo.
- [x] `lib/data/db/app_database.dart`: `AppDatabase` sınıfı, `schemaVersion = 1`, iki constructor:
  - `AppDatabase()`: gerçek dosya (`driftDatabase(name: 'denge')`)
  - `AppDatabase.forTesting(QueryExecutor e)`: testler için (`NativeDatabase.memory()`)
- [x] `lib/data/db/date_key.dart`: `String dateKey(DateTime local)` ve `DateTime parseDateKey(String)`.
- [x] `build_runner` çalıştır, `.g.dart` dosyasını commit'le.
- [x] `main.dart`: `AppDatabase` oluştur ve `AppState`'e ver (`AppState.instance.attachDatabase(db)`
      veya `load(db: ...)`). `AppState` veritabanı olmadan da çalışabilmeli (mevcut widget testleri bozulmasın).
- [x] **Test:** Bellek içi veritabanı açılıyor, dört tablo oluşuyor. `dateKey` için gece yarısı sınır testi.

**Kabul:** Uygulama eskisi gibi açılıyor, davranış değişmedi, veritabanı dosyası oluştu.

### Aşama 1: Günlük kayıtlarını kalıcı yap (en önemli aşama)

- [x] `FoodLogEntry` modeli (`lib/data/models.dart` veya ayrı dosya): §5.2'deki alanlar ve
      `FoodLogEntry.fromFood(FoodItem food, double amount, MealType meal, DateTime now, {source})`.
- [x] `FoodLogDao`:
  - `insertEntry(...)`
  - `Stream<List<...>> watchEntriesForDate(String date)` (silinmemiş, `logged_at` sıralı)
  - `Future<List<...>> entriesForDate(String date)`
  - `Future<Set<String>> datesWithEntries({String? from, String? to})` (seri için)
- [x] `FoodLogRepository`: UUID, `created_at`/`updated_at`/`logged_at` üretimi. Drift satırı ↔ `FoodLogEntry` çevrimi.
- [x] `lib/data/stats/daily_summary.dart`: `DailySummary.fromEntries(List<FoodLogEntry>)` →
      toplam kcal, protein, karb, yağ ve öğün başına kcal ile yiyecek listesi.
- [x] `AppState` değişiklikleri:
  - `addFoodToMeal(type, food, amount)` imzası **aynı kalır** (3 ekran bunu çağırıyor), içi
    repository'ye yazacak şekilde değişir. `source` için isteğe bağlı parametre eklenebilir.
  - `todaysMeals`, `proteinConsumedG`, `carbsConsumedG`, `fatConsumedG`, `caloriesConsumedToday`
    artık bugünün kayıtlarından **türetilen getter'lar** olur. Ekranlardaki kullanım bozulmasın diye
    `todaysMeals` yine `List<MealEntry>` dönmeye devam eder (açıklama = yiyecek adları virgülle).
  - `todayEntries` (bugünün `FoodLogEntry` listesi) eklenir. `load()` sırasında ve her yazmadan sonra güncellenir.
  - Bugünün kayıtları `watchEntriesForDate` stream'i ile dinlenir. Gün değişirse (uygulama gece
    yarısını geçerek açık kalırsa) abonelik yeni güne taşınır. `now` dışarıdan verilebilir olmalı.
- [x] `diary_screen.dart`: Seçili gün için `watchEntriesForDate` stream'ini `StreamBuilder` ile
      kullan. Geçmiş günler artık boş değil, o günün kayıtları görünür. `showEmpty = !isToday` mantığını kaldır.
- [x] `home_screen.dart`: Değişiklik gerekmemeli (getter'lar aynı). Kontrol et.
- [x] **Testler:**
  - DAO: ekle → oku, başka güne ait kayıt gelmez, silinmiş kayıt gelmez.
  - `DailySummary`: boş gün, tek kayıt, çok kayıt toplamları.
  - `AppState`: `addFoodToMeal` sonrası `caloriesConsumedToday` artar. `AppState` yeniden yüklenince kayıt hâlâ orada.

**Kabul:**
- Yiyecek ekle → uygulamayı tamamen kapat → aç → kayıt ve kalori yerinde.
- Günlükte dünkü güne geçince dünkü kayıtlar görünüyor.
- Ana sayfadaki kalori halkası ve makro çubukları eskisi gibi çalışıyor.

### Aşama 2: Kayıt silme ve düzenleme

- [x] `FoodLogDao`: `softDelete(id, now)`, `restore(id, now)` (geri al için), `updateAmount(id, amount, now)`.
      Miktar değişince `kcal` ve makrolar orantılı olarak yeniden hesaplanır.
- [x] Günlük ekranında öğün kartı, içindeki yiyecekleri **ayrı satırlar** olarak listeler
      (ad, porsiyon, kcal).
- [x] Satırı sola kaydır → sil → SnackBar'da **"Geri al"** (4 sn). Geri al `restore` çağırır.
- [x] Satıra dokun → porsiyon düzenleme (food detail ekranındaki porsiyon seçiciyle aynı adımlar),
      öğünü değiştirme seçeneği.
- [x] **Testler:** silinen kayıt toplamlara girmez, geri alınca geri gelir, miktar güncellemesi makroları doğru ölçekler.

**Kabul:** Yanlış eklenen bir yiyecek silinebiliyor ve kalori anında düşüyor. Geri al çalışıyor.

### Aşama 3: Su ve kilo

- [x] `WaterDao` / `WaterRepository`: `watchGlassesForDate(date)`, `setGlasses(date, glasses, now)` (upsert).
- [x] `AppState.waterGlasses` bugünün değerinden türetilir. `setWaterGlasses` repository'ye yazar.
      Gece yarısından sonra yeni gün 0 bardakla başlar.
- [x] `WeightDao` / `WeightRepository`: `addEntry(kg, now)`, `watchHistory({from})`, `latest()`.
- [x] `AppState.weightHistory` veritabanından gelir. `logWeight` hem veritabanına hem `user_weight` tercihine yazar.
- [x] `completeSetup()`: kurulumdaki kilo ilk `weight_entries` kaydı olarak eklenir.
- [x] **Eski kullanıcıların geçişi:** `load()` sırasında `setupComplete == true` ve `weight_entries`
      boşsa, `user_weight` değerini o günün tarihiyle tek kayıt olarak ekle. Bu işlem sadece bir kez çalışmalı.
- [x] `progress_screen.dart`: haftalık/aylık grafik gerçek geçmişten çizilir. Her gün için son ölçüm alınır.
- [x] **Testler:** su upsert (aynı gün iki kez yazınca tek satır), gün değişimi, kilo geçmişi
      sıralaması, eski kullanıcı geçişinin tek sefer çalışması.

**Kabul:** Su ve kilo uygulama yeniden açılınca korunuyor. Kilo grafiği birden fazla nokta gösteriyor.

### Aşama 4: Seri ve rozetler

- [x] `lib/data/stats/streak.dart`:
      `int currentStreak(Set<String> loggedDates, DateTime now)`. Kural: Bugünden geriye doğru
      **en az bir yiyecek kaydı olan** ardışık günler sayılır. Bugün henüz kayıt yoksa seri
      dünden itibaren sayılır (bugün kayıt girilmediği için seri bozulmuş sayılmaz).
- [x] `AppState` içinde `streakDays` bu fonksiyondan türetilir. `UserProfile.streakDays` ve
      `user_streak` tercihi artık kullanılmaz (okumayı kaldır, alanı model uyumluluğu için bırakabilirsin).
- [x] Rozetler (`profile_screen.dart`) türetilmiş değerlere bağlanır:
  - *İlk adım:* en az 1 günlük kaydı var
  - *7 gün seri:* `streakDays >= 7`
  - *Su ustası:* bugün su hedefi tamam
  - *Protein avcısı:* bugün protein hedefi tamam
- [x] **Testler (sabit `now` ile):** kayıt yok → 0, sadece bugün → 1, dün + bugün → 2,
      dün var bugün yok → 1, arada boş gün → seri orada kırılır, ay/yıl geçişi.

**Kabul:** Art arda günlerde kayıt girilince seri artıyor, bir gün atlanınca sıfırlanıyor.

### Aşama 5: Kendi yiyeceğini ekle

- [ ] `CustomFoodDao` / `CustomFoodRepository`: ekle, güncelle, sil (yumuşak), `watchAll()`.
- [ ] Yeni ekran `lib/screens/food/custom_food_screen.dart` (rota `AppRoutes`'a eklenir):
      ad, marka, porsiyon etiketi, kcal, protein, karb, yağ, kategori. Doğrulama: ad zorunlu,
      sayılar 0 veya pozitif, kcal ≤ 5000.
- [ ] `search_screen.dart`: "Yiyeceği kendin ekle" butonundaki "Bu özellik yakında" SnackBar'ı
      kaldırılır ve buton yeni ekranı açar (arama metni ad alanına önceden doldurulur).
- [ ] Arama sonuçlarında kullanıcının kendi yiyecekleri katalogla birlikte, **en üstte** listelenir.
- [ ] Barkod bulunamazsa "Bu ürünü kendin ekle" seçeneği barkod numarasıyla birlikte aynı ekranı açar.
      Sonraki taramada bu barkod önce `custom_foods` içinde aranır.
- [ ] **Testler:** doğrulama kuralları, aramada kendi yiyeceğin çıkması, barkod eşleşmesi.

**Kabul:** Katalogda olmayan bir yiyecek eklenip günlüğe kaydedilebiliyor ve sonraki aramalarda çıkıyor.

### Aşama 6: Veri yönetimi ve KVKK

- [ ] Ayarlar ekranına **"Tüm verilerimi sil"**: onay diyaloğundan sonra veritabanındaki bütün
      tablolar **fiziksel olarak** boşaltılır ve `shared_preferences` temizlenir. Ardından
      karşılama ekranına dönülür. (Yumuşak silme burada uygulanmaz, kullanıcı gerçekten silinmesini istiyor.)
- [ ] Eski kayıt temizliği: `deleted_at` dolu ve 30 günden eski satırlar uygulama açılışında
      kalıcı olarak silinir. (Bulut senkronu eklendiğinde bu süre `synced_at` kontrolüne bağlanacak.)
- [ ] (İsteğe bağlı) "Verilerimi dışa aktar": günlük, su ve kiloyu JSON dosyası olarak paylaş.
- [ ] **Testler:** silme sonrası tüm tablolar boş, `AppState` ilk açılış durumunda.

---

## 8. Şema değişikliği (migration) kuralları

- Yayınlanmış bir şemayı **asla elle değiştirme**. Her değişiklikte `schemaVersion` bir artırılır
  ve `MigrationStrategy.onUpgrade` içine o sürüm için adım eklenir (`from < 2` gibi).
- Sadece ekleyici değişiklik tercih et: yeni tablo, yeni null olabilir sütun, yeni indeks.
  Sütun silme veya yeniden adlandırma gerekiyorsa önce plan yazıp onay al.
- Her sürüm için `dart run drift_dev make-migrations` ile şema dökümü (`drift_schemas/`) alınır
  ve eski sürümden yeni sürüme geçiş testi yazılır.
- Veritabanı açılırken hata olursa uygulama çökmemeli. Hata loglanır, kullanıcıya Türkçe ve
  anlaşılır bir mesaj gösterilir. Veritabanı dosyası **otomatik silinmez**.

## 9. Kod kuralları

- Kod tanımlayıcıları ve yorumlar **İngilizce**, kullanıcıya görünen metinler **Türkçe**.
- Ekranlar `drift` veya DAO import etmez. Sadece `AppState` ve modellerle konuşur.
- Repository ve DAO metotları "şimdi" değerini parametre olarak alır (`DateTime now`).
  `DateTime.now()` sadece `AppState` gibi en dış katmanda çağrılır. Böylece testler sabit tarihle yazılabilir.
- Kalori her zaman `int` olarak saklanır (`round()`), makrolar `double`.
- Yazma işlemleri `async`. Ekran yazmayı bekleyip hata olursa SnackBar ile Türkçe mesaj gösterir.
- Birden fazla tabloya dokunan işlemler `transaction` içinde yapılır.
- `print` kullanma, geçici hata ayıklama için `debugPrint` kullan ve commit'ten önce sil.
- Mevcut dosyalardaki `///` doc-comment yoğunluğunu koru, yorumlar "neden"i anlatır.
- Yeni ekranlar açık/koyu temada ve "Çok büyük" yazı boyutunda taşmadan çalışmalı.
  Renkler `context.dengeColors` ve `Theme.of(context).colorScheme` üzerinden alınır.

## 10. Test kuralları

- DAO ve repository testleri `AppDatabase.forTesting(NativeDatabase.memory())` ile yazılır ve
  her testten sonra `db.close()` çağrılır.
  Linux'ta host testleri için sistemde `libsqlite3` gerekir (`sudo apt install libsqlite3-dev`).
- `lib/data/` altındaki her yeni saf fonksiyon için birim testi zorunlu: normal durum + en az 1 sınır durumu.
- Tarih mantığı (gün değişimi, seri, ay sonu) her zaman sabit `DateTime` ile test edilir.
- `SharedPreferences` testlerinde `SharedPreferences.setMockInitialValues({})` kullan.
- Ağ çağrıları testte gerçek ağa çıkmaz, `MockClient` ile enjekte edilir.
- Test dosyaları `lib/` yapısını aynalar: `lib/data/stats/streak.dart` ↔ `test/data/stats/streak_test.dart`.

## 11. Çalışma kuralları

- Her değişiklikten sonra: `flutter analyze` (0 sorun) ve `flutter test` (hepsi yeşil).
- Bir commit = bir mantıksal adım. Conventional Commits, Türkçe açıklama. Örnekler:
  `feat(db): drift altyapısını ekle`, `feat(diary): günlük kayıtlarını kalıcı yap`,
  `test(stats): seri hesabı testleri`.
- `build/`, `.dart_tool/`, `coverage/` commit edilmez. Drift'in `.g.dart` dosyaları commit edilir.
- Davranış değişince `README.md` içindeki özellik listesi güncellenir.
- Bu dosyada (§7) bir aşama bitince ilgili kutucuklar `[x]` yapılır.

## 12. Tuzaklar

- `AppState` tekildir (`AppState.instance`) ve `main()` içinde `await AppState.instance.load()` ile
  yüklenir. Widget testlerinde de önce yüklenmelidir.
- `addFoodToMeal` imzası 3 ekran tarafından kullanılıyor, imzayı değiştirirsen hepsini güncelle.
- Tarif favorileri **başlığa** göre saklanıyor, tarif başlığını değiştirmek favoriyi kırar.
- Su hedefi `MockData.waterGlassesGoal` (10 bardak × 250 ml = 2,5 L).
- `foodImageSlug` ile `tool/fetch_food_images.py` aynı slug kuralını kullanır, birini değiştirirsen diğerini de değiştir.
- Open Food Facts isteklerinde `User-Agent` başlığı zorunlu, kaldırma.
- Kilo, alerji ve beslenme verileri KVKK'ya göre sağlık verisi sayılabilir. Bu aşamada hepsi
  yalnızca cihazda kalır. Buluta göndermeden önce açık rıza metni güncellenmelidir.

## 13. Sonraki adım (bu dosyanın kapsamı dışında): bulut senkronizasyonu

Yerel veritabanı bittikten sonra eklenecek. Tasarım şimdiden buna uygun:
- Bulut sağlayıcı (Supabase önerildi) sadece `lib/data/backend/` altında import edilir.
- `synced_at IS NULL OR updated_at > synced_at` olan satırlar gönderilecek kuyruğu oluşturur.
- Çakışma kuralı: `updated_at` değeri büyük olan kazanır.
- Uygulama her zaman yerel veritabanından okur, internet zorunlu değildir.
