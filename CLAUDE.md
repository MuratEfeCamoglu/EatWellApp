# Denge (EatWellApp)

Türk mutfağını tanıyan Flutter kalori ve beslenme takip uygulaması (Android + iOS).
Dart paketi: `denge` (`import 'package:denge/...'`).

Kullanıcının günlük kayıtları, su ve kilo geçmişi ile kendi yiyecekleri cihazdaki SQLite
veritabanında (`drift`) saklanır. Tasarım ileride bulut senkronizasyonu eklenebilecek şekilde
yapılmıştır (bkz. §13); bugün hiçbir veri cihazdan çıkmaz.

---

## 2. Komutlar

| İş | Komut |
|---|---|
| Drift kod üretimi | `dart run build_runner build --delete-conflicting-outputs` |
| Kod üretimi (izleme) | `dart run build_runner watch --delete-conflicting-outputs` |
| Şema dökümü (migration testi için) | `dart run drift_dev make-migrations` |

Barkod ve fotoğraf özellikleri kamera kullanır, bu yüzden gerçek cihazda denenmeli.
Ortamda `flutter` yoksa komutu çalıştırmış gibi davranma, çalıştırılamadığını açıkça raporla.

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

### 5.2 Tablolar

Şema `lib/data/db/tables.dart` içinde (`food_log_entries`, `water_logs`, `weight_entries`,
`custom_foods`). Koddan anlaşılmayan kurallar:

- `kcal` hesabı `food.caloriesPer100g * amount`. Yani `amount`, `servingLabel` porsiyonunun katı
  ve `caloriesPer100g` aslında porsiyon başı değer gibi kullanılıyor. Bu hesap **olduğu gibi**
  korunur, düzeltmeye kalkışma. Tek yeri `FoodLogEntry.fromFood(...)`.
- Su: günde tek satır (`date` UNIQUE), bardağa dokunmak upsert yapar.
- Kilo: aynı gün birden fazla ölçüm saklanır, grafik her günün **son** ölçümünü kullanır.
  Profildeki `user_weight` (shared_preferences) son ölçümle eşit tutulur.

### 5.6 Veritabanında **olmayacaklar**

- Yiyecek kataloğu (`mock_data.dart`, `extra_foods.dart`, `more_foods.dart`) ve tarifler (`recipes.dart`): kodda kalır.
- Profil, hedefler, tema, yazı boyutu, alerjiler, KVKK onayı: `shared_preferences` içinde kalır.
- Günlük toplamlar, seri, rozetler: kayıtlardan hesaplanır, saklanmaz.

---

## 7. Yapılacaklar

Aşama 0–6 (yerel veritabanı geçişi) tamamlandı; ayrıntılar git geçmişinde.

- [ ] (İsteğe bağlı) "Verilerimi dışa aktar": günlük, su ve kiloyu JSON dosyası olarak paylaş.
      Paylaşım için yeni bir paket (`share_plus`) gerekiyor.

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
- Bu dosyada (§7, §13.3, §13.6) bir aşama bitince ilgili kutucuklar `[x]` yapılır.

## 12. Tuzaklar

- `AppState` tekildir (`AppState.instance`) ve `main()` içinde `await AppState.instance.load()` ile
  yüklenir. Widget testlerinde de önce yüklenmelidir.
- `addFoodToMeal` imzası 3 ekran tarafından kullanılıyor, imzayı değiştirirsen hepsini güncelle.
- Tarif favorileri **başlığa** göre saklanıyor, tarif başlığını değiştirmek favoriyi kırar.
- Su hedefi `MockData.waterGlassesGoal` (10 bardak × 250 ml = 2,5 L).
- `foodImageSlug` ile `tool/fetch_food_images.py` aynı slug kuralını kullanır, birini değiştirirsen diğerini de değiştir.
- Open Food Facts isteklerinde `User-Agent` başlığı zorunlu, kaldırma.
- Kilo, alerji ve beslenme verileri KVKK'ya göre sağlık verisi sayılabilir. Bulut rızası (§13.5)
  verilmeden hiçbir veri cihazdan çıkmaz.

## 13. Bulut senkronizasyonu (Supabase)

Amaç: kullanıcı isterse hesap açar; günlük, su, kilo, kendi yiyecekleri ve profili buluta yedeklenir
ve başka bir cihazda aynı hesapla açınca geri gelir. **Uygulama her zaman yerel veritabanından okur**;
bulut yalnızca arka planda eşitlenen bir kopyadır. Hesap açmak isteğe bağlıdır, hesapsız kullanım
bugünkü gibi tamamen yerel çalışmaya devam eder.

### 13.1 Kararlar

1. **Sağlayıcı:** Supabase (PostgreSQL + Auth + Row Level Security). Bölge **AB (Frankfurt,
   `eu-central-1`)**. Paket: `supabase_flutter`.
2. **Sınır:** `supabase_flutter` sadece `lib/data/backend/` altında import edilir. Senkron mantığı
   `lib/data/sync/` altında saf Dart'tır ve sunucuyla bir arayüz (`SyncBackend`) üzerinden konuşur;
   testler sahte bir backend kullanır. Ekranlar Supabase'i hiç görmez (§9 ile aynı kural).
3. **Anahtarlar:** `SUPABASE_URL` ve `SUPABASE_PUBLISHABLE_KEY` koda yazılmaz, `--dart-define` ile verilir
   (`flutter run --dart-define-from-file=env/dev.json`; `env/` git'e girmez, `env/example.json` girer).
   Publishable key istemcide durabilir, güvenliği RLS sağlar. **Secret key (`sb_secret_...`, eski adıyla `service_role`) asla uygulamaya
   veya depoya girmez.**
4. **Zaman:** Sunucudaki sütunlar yerelle aynı biçimde tutulur (UTC milisaniye, `bigint`), dönüşüm
   gerekmez. Telefon saatleri yanlış olabileceği için "neyi henüz çekmedim" sorusu **sunucunun**
   koyduğu `server_updated_at` ile cevaplanır; istemcinin `updated_at` değeri yalnızca çakışma
   kuralında kullanılır.
5. **Çakışma kuralı:** Son yazan kazanır (`updated_at` büyük olan). Sunucuda bir trigger, gelen
   satırın `updated_at` değeri mevcuttan küçükse güncellemeyi yok sayar; böylece eski bir cihaz
   yeni veriyi ezemez.
6. **Hesap ve cihaz:** Bir cihazda aynı anda tek hesap. Hesapsız kullanırken biriken kayıtlar ilk
   girişte o hesaba yüklenir. Oturum kapatılırken önce bekleyen her şey gönderilir, sonra yerel
   veritabanı temizlenir (başka biri aynı telefonda kendi hesabıyla girebilsin).
7. **Gönderilmeyenler:** Yemek kataloğu ve tarifler (kodda), tema / yazı boyutu / hareket azaltma,
   bildirim tercihleri (cihaza özgü), tarif favorileri (şimdilik).

### 13.2 Sunucu şeması

Migration dosyaları `supabase/migrations/` altında. Docker olmadığı için uygulama yöntemi:
`npx supabase db query --linked --project-ref <ref> -f <migration>.sql`, ardından
`npx supabase migration repair <sürüm> --status applied --linked --project-ref <ref>`. Sunucu şeması da yerel şema gibi elle değiştirilmez, her değişiklik yeni bir
migration dosyasıdır.

- **Kullanıcı tabloları:** `food_log_entries`, `water_logs`, `weight_entries`, `custom_foods`.
  Yereldeki sütunların aynısı, artı:
  - `user_id uuid not null references auth.users on delete cascade`
  - `server_updated_at bigint not null` (trigger doldurur, istemci yazamaz)
  - Birincil anahtar `id` (istemcinin ürettiği UUID). `synced_at` sunucuda tutulmaz.
- **`water_logs`:** `unique (user_id, date)`. İki cihaz aynı gün için farklı `id` üretebilir; bu
  yüzden su `upsert_water(date, glasses, updated_at)` RPC'siyle yazılır, sunucu `(user_id, date)`
  üzerinde son yazan kazanır kuralını uygular ve kazanan satırı (sunucudaki `id` ile) döner.
- **`profiles`:** `user_id` birincil anahtar; ad, e-posta, cinsiyet, yaş, boy, aktivite düzeyi,
  hedef türü, hedef kilo, haftalık tempo, kalori ve makro hedefleri, alerjiler, KVKK rıza sürümü ve
  zamanı, `updated_at`, `server_updated_at`. Bugün `shared_preferences`'ta duran profil verisinin
  bulut karşılığı; yerelde yine `shared_preferences`'ta kalır.
- **Trigger'lar (her tabloda):**
  - `server_updated_at := (extract(epoch from clock_timestamp()) * 1000)::bigint` (insert + update)
  - Update'te `NEW.updated_at < OLD.updated_at` ise `OLD` döndür (eski yazma yok sayılır).
- **RLS:** Her tabloda açık; `select / insert / update` için `user_id = auth.uid()`. `delete`
  politikası **yok**: silme her zaman yumuşaktır (`deleted_at`), fiziksel silme yalnızca hesap
  silme fonksiyonunda olur.
- **`delete_my_account()`:** `security definer` fonksiyon; kullanıcının tüm satırlarını ve
  `auth.users` kaydını siler. İstemci yalnızca bunu çağırır.
- **İndeks:** her tabloda `(user_id, server_updated_at)`.

### 13.3 Yerel değişiklikler (şema sürümü 2)

- [x] `schemaVersion = 2`. `onUpgrade` içinde `from < 2`: dört tabloya null olabilir
      `server_updated_at INTEGER` sütunu ve `sync_state` tablosu eklenir.
- [x] `sync_state (entity TEXT PRIMARY KEY, pulled_until INTEGER NOT NULL)`: her tablo için en
      son çekilen `server_updated_at`. Kullanıcı verisi değil, bu yüzden `SyncColumns` taşımaz.
- [x] `dart run drift_dev make-migrations` ile `drift_schemas/` dökümü ve 1 → 2 geçiş testi (§8).
- [x] Açılıştaki 30 günlük temizlik (`purgeSoftDeleted`): oturum açıksa yalnızca
      `synced_at >= deleted_at` olan, yani silinmesi buluta ulaşmış satırları siler.

### 13.4 Senkron algoritması (`lib/data/sync/sync_engine.dart`)

Bir senkron turu sırayla: **profil → gönder → çek**. Aynı anda tek tur çalışır (kilit).

- **Gönder:** Her tablo için `synced_at IS NULL OR updated_at > synced_at` olan satırlar, en fazla
  100'lük gruplar halinde `upsert` edilir (su için `upsert_water`). Başarılı her grup için yerelde
  `synced_at = gönderim anı` ve `server_updated_at` yazılır. Su RPC'si farklı bir `id` dönerse yerel
  satır o `id` ile değiştirilir (aynı gün için tek satır kuralı korunur).
- **Çek:** `server_updated_at > pulled_until` olan satırlar `server_updated_at` sırasıyla, 500'lük
  sayfalarla alınır. Her satır için:
  - Yerelde yoksa eklenir.
  - Yerelde varsa ve gelen `updated_at` ≥ yerel `updated_at` ise üzerine yazılır; yerel satır daha
    yeniyse dokunulmaz (bir sonraki gönderimde o kazanır).
  - `deleted_at` dolu gelen satır yerelde de yumuşak silinir.
  - Yazılan her satırda `synced_at = updated_at` olur, böylece geri gönderilmez.
  - Sayfa bitince `pulled_until` güncellenir. Hepsi tek `transaction` içinde (§9).
- **Ne zaman:** uygulama açılınca, öne gelince, her yazmadan 5 sn sonra (art arda yazmalar
  birleşir) ve Ayarlar'daki **"Şimdi eşitle"** ile. Ağ hatasında sessizce vazgeçilir, bir sonraki
  tetikte tekrar denenir (üstel bekleme, en fazla 15 dk).
- **Durum:** `AppState.syncStatus` (`kapalı / eşitleniyor / güncel / hata`) ve son başarılı eşitleme
  zamanı; Ayarlar'da Türkçe gösterilir ("Son eşitleme: bugün 14:32").
- Repository'ler değişmez: senkron, DAO seviyesinde ayrı sorgular kullanır (`dirtyRows`,
  `applyRemote`, `markSynced`).

### 13.5 KVKK

- Sağlık verisi (kilo, alerji, beslenme) **yurt dışına (AB) aktarılacağı** için ayrı ve açık rıza
  gerekir. Rıza metni güncellenir ve `kConsentVersion` artırılır. Rıza verilmeden **hiçbir veri
  gönderilmez**; kullanıcı hesap açsa bile reddederse uygulama yerel çalışmaya devam eder.
- Rıza geri alınabilir (Ayarlar): senkron durur ve kullanıcıya buluttaki verisini silme seçeneği
  sunulur.
- "Tüm verilerimi sil", oturum açıksa önce `delete_my_account()` çağırır, sonra yereli siler.
  Sunucu silmesi başarısız olursa yerel silme yapılmaz ve kullanıcıya söylenir.
- Gizlilik metninde: hangi veriler, nerede (Supabase, AB), ne kadar süre, nasıl silinir.

### 13.6 Aşamalar

Her aşama kendi başına çalışır durumda biter (§7'deki kurallarla aynı): `flutter analyze` temiz,
`flutter test` yeşil, hesapsız kullanım bozulmamış.

#### Aşama B1: Supabase projesi ve sunucu şeması

- [x] Supabase projesi (AB bölgesi), `supabase/` klasörü, `supabase/config.toml`.
- [x] §13.2'deki tablolar, trigger'lar, RLS politikaları, `upsert_water` ve `delete_my_account`
      migration olarak.
- [x] `env/example.json` ve `.gitignore`'a `env/*.json` (örnek hariç).
- [x] **Testler:** `supabase/tests/rls_test.sql`. Docker gerektirmez: gerçek projede tek bir
      transaction içinde iki geçici kullanıcıyla çalışır ve `ROLLBACK` ile biter, iz bırakmaz.
      `npx supabase db query --linked --project-ref <ref> -f supabase/tests/rls_test.sql` →
      `ALL PASSED`. Kapsam: başka kullanıcının satırı okunamıyor/yazılamıyor, istemci fiziksel
      silme yapamıyor, eski `updated_at` yok sayılıyor, aynı gün iki su yazması tek satır,
      anon hiçbir şeye erişemiyor, `delete_my_account` yalnızca çağıranın verisini siliyor.
      Her yeni migration'dan sonra bu betik ve `npx supabase db advisors --type security`
      tekrar çalıştırılır. Advisors'ın `delete_my_account` için verdiği "SECURITY DEFINER"
      uyarısı bilinçlidir (fonksiyon yalnızca `auth.uid()`'i siler).

**Kabul:** İki test kullanıcısıyla, birinin verisi diğerinden görünmüyor.

#### Aşama B2: Hesap (kimlik doğrulama)

- [x] `supabase_flutter`; `main.dart`'ta `--dart-define` değerleri yoksa Supabase hiç başlatılmaz
      (geliştirme ve testler hesapsız çalışır).
- [x] `lib/data/auth.dart` (`AuthService` arayüzü, Türkçe `AuthFailure`) ve
      `lib/data/backend/supabase_auth_service.dart`: e-posta + şifre ile kayıt, giriş, çıkış, şifre
      sıfırlama; oturum cihazda saklanır. E-posta doğrulaması ve şifre sıfırlama bağlantıları
      `com.denge.denge://login-callback` deep link'iyle uygulamayı açar; bu adres Supabase
      panelinde Authentication → URL Configuration → Redirect URLs listesinde olmalı.
- [x] Var olan `sign_up_screen.dart` ve `login_screen.dart` gerçek işlemlere bağlanır. Hatalar
      Türkçe ("E-posta veya şifre hatalı", "Bu e-posta zaten kayıtlı", "İnternet bağlantısı yok").
- [x] Karşılama akışında "Hesapsız devam et" seçeneği kalır.
- [x] **Testler:** sahte auth ile ekran akışları; hata mesajları.

**Kabul:** Kayıt ol → çık → giriş yap çalışıyor; hesapsız kullanım değişmedi.

#### Aşama B3: Yerel şema v2, rıza ve profil senkronu

- [x] §13.3'teki yerel şema değişikliği ve geçiş testi.
- [x] Bulut rızası (§13.5): `CloudConsentScreen`, sürümü `AppState.kCloudConsentVersion`.
      Karar: sağlık verisi rızasının (`kConsentVersion`) sürümünü artırmak yerine **ayrı ve
      isteğe bağlı** bir bulut rızası. Böylece mevcut kullanıcılar sağlık rızasını yeniden
      vermek zorunda kalmaz ve bulutu reddetmek uygulamanın hiçbir yerini kapatmaz. Giriş ve
      kayıttan sonra sorulur, Ayarlar → Bulut yedekleme'den geri alınır.
- [x] `profiles` için gönder/çek (son yazan kazanır), giriş yapınca profil ve hedefler gelir.
      `lib/data/sync/profile_snapshot.dart` (`decideProfileSync`), `SyncBackend` arayüzü,
      `SupabaseSyncBackend`. Sunucuya `profiles.weight_kg` eklendi (migration
      `20261008090000`); kilo geçmişinin kendisi B5'te gelir.
- [x] **Testler:** 1 → 2 geçişi veri kaybetmiyor; rıza yokken hiçbir istek gitmiyor.

**Kabul:** Başka bir cihazda aynı hesapla giriş yapınca profil ve hedefler geliyor.

#### Aşama B4: Gönderme (yedekleme)

- [ ] `SyncBackend` arayüzü, `SupabaseSyncBackend` uygulaması, `SyncEngine.push()`.
- [ ] Tetikleyiciler (§13.4) ve Ayarlar'da durum + "Şimdi eşitle".
- [ ] İlk girişte hesapsız biriken kayıtların yüklenmesi.
- [ ] **Testler (sahte backend, sabit saat):** kirli satırlar gidiyor ve `synced_at` doluyor; ağ
      hatasında hiçbir satır "gönderildi" sayılmıyor; 250 satır 3 grup halinde gidiyor; su `id`
      değişimi yerelde uygulanıyor.

**Kabul:** İnternet kapalıyken yiyecek ekle → interneti aç → kayıt Supabase tablosunda görünüyor.

#### Aşama B5: Çekme ve çoklu cihaz

- [ ] `SyncEngine.pull()`, `sync_state`, sayfalama.
- [ ] Silmelerin yayılması; 30 gün temizliğinin `synced_at` koşulu.
- [ ] **Testler:** yeni satır ekleniyor; eski `updated_at` yerel yeni veriyi ezmiyor; silme
      yayılıyor; yarıda kesilen çekme bir sonraki turda kaldığı yerden devam ediyor; aynı gün iki
      cihazdan su tek satıra iniyor.

**Kabul:** İki telefonda aynı hesap: birinde eklenen, düzenlenen ve silinen yiyecek diğerinde de
aynı oluyor; su ve kilo da eşitleniyor.

#### Aşama B6: Oturum kapatma ve hesap silme

- [ ] Çıkış: önce gönder, sonra yereli temizle; gönderilemeyen veri varsa uyar.
- [ ] "Tüm verilerimi sil" ve "Hesabımı sil": `delete_my_account()` + yerel silme (§13.5).
- [ ] README ve gizlilik metni güncellenir.
- [ ] **Testler:** gönderilmemiş veri varken çıkış uyarısı; sunucu silmesi başarısızsa yerel veri
      duruyor.

**Kabul:** Hesap silinince Supabase'te o kullanıcıya ait satır kalmıyor ve uygulama karşılama
ekranına dönüyor.

### 13.7 Tuzaklar

- Yeni bir tablo eklerken RLS'yi açmayı unutmak, tüm kullanıcıların verisini açığa çıkarır. Her
  migration'da RLS testi şart.
- `server_updated_at`'i istemci yazamaz; çekme imleci istemcinin saatine **asla** dayanmaz.
- `date` sütunları cihazın yerel gününe göre (§4.6). Kullanıcı saat dilimi değiştirince geçmiş
  günler kaymaz; bu bilinçli bir karardır.
- Senkron turu "Tüm verilerimi sil" veya çıkış sırasında çalışmamalı (kilit ile engellenir).
- Supabase istemcisi testlerde gerçek ağa çıkmaz (§10); senkron testleri sahte `SyncBackend` ile.
