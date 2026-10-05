# Denge (EatWellApp) — Proje İskeleti ve Sınırları

> Bu dosya projenin **tek doğruluk kaynağıdır**: neyi yapıyoruz, neyi yapmıyoruz, ne zaman "bitti" diyeceğiz.
> Komutlar ve kod kuralları için `CLAUDE.md`, agent davranışı için `AGENT.md`.
> Ürün adı **Denge**; GitHub deposu `EatWellApp`; Dart paket adı `denge`; Android `applicationId` `com.denge.denge`.
> Son güncelleme: 2026-10-05 (repo durumu: commit `e1e4922`). **Mimari karar:** kullanıcı verisi bulut veritabanında tutulur; sağlayıcı (Supabase / Firebase) henüz seçilmedi → bkz. §9 D1.

---

## 1. Amaç ve Hedef Kullanıcı

- **Sorun:** Genel kalori uygulamaları (MyFitnessPal vb.) Türk mutfağını zayıf tanır; "mercimek çorbası", "menemen", "lahmacun" gibi yemekleri bulmak, porsiyonlamak ve kaydetmek zahmetlidir. Bu yüzden kullanıcı birkaç gün sonra kaydı bırakır.
- **Hedef kullanıcı:** Türkiye'de yaşayan, Türkçe konuşan, 18–60 yaş arası, kilo vermek/korumak/almak isteyen ve akıllı telefon (Android 8+ / iOS 15+) kullanan bireyler. Diyetisyen/klinik kullanımı hedef değildir.
- **Değer önerisi:** Türk yemeklerini tanıyan katalog + barkod + fotoğrafla hızlı kayıt, kişiye özel kalori/makro hedefi, hedefe uygun Türk tarifleri. Kullanıcı bir hesapla giriş yapar; profili, günlüğü, su ve kilo geçmişi **bulutta saklanır**, telefon değiştirse veya uygulamayı silip yeniden kursa da verisi kaybolmaz.
- **Başarı ölçütleri (MVP için, ölçülebilir):**
  - B1: Kurulumu tamamlamış bir kullanıcı, ana sayfadan katalogdaki bir yiyeceği **en fazla 3 dokunuşla** (klavyeyle arama yazmak hariç) bir öğüne ekleyebilir: öğün kartındaki "+" → listedeki yiyecek → "Ekle".
  - B2: Uygulama silinip yeniden kurulduğunda **veya başka bir cihazda aynı hesapla giriş yapıldığında** son 365 güne ait tüm günlük kayıtları, su ve kilo geçmişi, profil ve hedefler eksiksiz geri gelir.
  - B3: Kurulum sihirbazı (cinsiyet → sonuç ekranı) **7 ekranda** tamamlanır ve sonuçta hesaplanan kalori hedefi §3.3'teki formülle birebir aynıdır.

---

## 2. Mevcut Durum (2026-10-05 itibarıyla yapılanlar)

Uygulama Flutter ile yazılmış, **henüz arka ucu (backend) olmayan, tek cihazlı** bir prototiptir. ~13.800 satır Dart kodu, 31 ekran/bileşen dosyası. Bulut veritabanı hedeflenmiştir ama kodda henüz hiçbir bulut bağlantısı yoktur.

| Alan | Durum | Not |
|---|---|---|
| Bulut veritabanı ve gerçek hesap | ❌ Yok | Sağlayıcı seçimi bekleniyor (§9 D1). |
| Splash, karşılama (onboarding), kayıt/giriş ekranları | ⚠️ Sahte | Giriş/kayıt **sahte**: şifre doğrulanmaz, saklanmaz; sadece ad/e-posta taslağa yazılır. F18 ile gerçek kimlik doğrulamaya bağlanacak. |
| 7 adımlı kurulum sihirbazı + kişisel plan | ✅ Var | Mifflin-St Jeor + aktivite çarpanı, `AppState.completeSetup()`. Profil yalnızca cihazdaki `shared_preferences`'a yazılır; cinsiyet, yaş, aktivite ve hedef **saklanmaz** (F15 için gerekli). |
| Ana sayfa (kalori halkası, makro çubukları, su) | ✅ Var | |
| Günlük (Diary) ekranı | ⚠️ Kısmi | Sadece **bugün** bellekte tutulur; geçmiş günler her zaman boş; uygulama kapanınca günlük **silinir**; kayıt silme/düzenleme yok. Öğün başına tek satır (`MealEntry`) – tek tek yiyecekler tutulmuyor. |
| Yiyecek kataloğu | ✅ Var | `mock_data.dart` + `extra_foods.dart` + `more_foods.dart` ≈ 220 yiyecek, 12 kategori, `assets/foods/` altında 222 fotoğraf. |
| Arama ekranı | ⚠️ Kısmi | Kategori ve öğüne göre süzme var; arama sadece `toLowerCase` ile — "cilbir" yazınca "Çılbır" bulunmuyor. |
| Barkod tarama | ✅ Var | `mobile_scanner`; önce yerel `barcodeCatalog`, sonra Open Food Facts (12 sn zaman aşımı). Birim testli. |
| Fotoğrafla tanıma | ✅ Var (sezgisel) | ML Kit genel etiketleyici + İngilizce etiket→Türkçe anahtar kelime tablosu; en fazla 3 aday, kullanıcı onaylar. |
| Tarifler (51 adet) + detay + favoriler | ✅ Var | "Sana özel": kalan kaloriye sığan, proteini yüksek tarifler. Favoriler cihazda kalıcı (buluta taşınacak). |
| İlerleme (kilo grafiği, seri) | ⚠️ Kısmi | Kilo geçmişi **kalıcı değil** (her açılışta tek nokta). Seri (streak) **hiç artmıyor** (hep 0). |
| Su takibi | ⚠️ Kısmi | 10 bardak × 250 ml; **kalıcı değil**, gün değişince sıfırlanmıyor. |
| Profil + rozetler | ⚠️ Kısmi | Rozetler sadece "bugün"e bakıyor; seri 0 olduğu için "7 gün seri" hiç kazanılamıyor. |
| Ayarlar: tema, yazı boyutu, animasyon azaltma | ✅ Var | Cihazda kalıcı (cihaz tercihi olarak cihazda kalacak). |
| İşlevsiz butonlar | ❌ Boş | 17 yerde `onTap/onPressed: () {}` veya "yakında": giriş/kayıt (Google ile devam et ×2, Şifremi unuttum), profil (düzenle ikonu, Rozetler başlığındaki buton, Kişisel bilgiler, Hedefler ve makrolar, Bildirimler, Yardım ve destek), ilerleme (takvim ikonu), arama (Yiyeceği kendin ekle), ayarlar (Birimler, Şifreyi değiştir, Gizlilik ve veriler, Çıkış yap, bir ikon butonu, English). |
| Testler | ⚠️ Az | `test/product_lookup_test.dart` (9 test), `test/widget_test.dart` (1 duman testi). `flutter analyze` 0 sorun, `flutter test` 10/10 (2026-10-05, Flutter 3.47.5). |
| Depo hijyeni | ⚠️ | `android/build/reports/` ve `.claude/scheduled_tasks.lock` yanlışlıkla commit'lenmiş. |

---

## 3. Kapsam

> Yeni özellikler kullanıcı belirledikçe §3.1 tablosuna yeni F-numarasıyla (F21, F22…) ve ölçülebilir kabul kriteriyle eklenir; ilgili aşama §7'ye işlenir.

### 3.1 Kapsam İçi (MVP)

Durum sütunu: **Var** = mevcut ve kriteri karşılıyor, **Kısmi** = mevcut ama kriteri karşılamıyor, **Yok** = yazılacak.
"Bulutta saklanır" ifadesi §4 ve §4.2'deki veri katmanı üzerinden, giriş yapmış kullanıcının kendi kaydı olarak yazılması anlamına gelir.

| # | Özellik | Öncelik | Durum | Kabul Kriteri (ölçülebilir) |
|---|---|---|---|---|
| F1 | Kurulum sihirbazı ve kişisel plan | Zorunlu | Kısmi | 7 ekran (cinsiyet, yaş, boy, kilo, aktivite, hedef, sonuç) tamamlanınca `calorieGoal`, `proteinGoalG`, `carbsGoalG`, `fatGoalG` §3.3 formülüyle hesaplanır; birim testi ≥ 6 senaryoyu (2 cinsiyet × 3 hedef) doğrular (henüz yok); sihirbazın **tüm girdileri ve sonuçları** (cinsiyet, yaş, boy, kilo, hedef kilo, aktivite, hedef, tempo, 4 hedef değer) kullanıcının bulut profiline yazılır; aynı hesapla yeniden giriş yapılınca kurulum tekrar sorulmaz. |
| F2 | Kalıcı, tarih bazlı yemek günlüğü | Zorunlu | Kısmi | (a) Her eklenen yiyecek ayrı bir `FoodLogEntry` olarak bulutta saklanır; (b) uygulama zorla kapatılıp açıldığında, silinip yeniden kurulduğunda veya başka cihazda aynı hesapla giriş yapıldığında bugünkü ve geçmiş günlerin kayıtları aynen görünür; (c) Günlük ekranında herhangi bir geçmiş güne (≤ 365 gün geriye) gidildiğinde o günün kayıtları mevcut 4 öğün kartı altında (kahvaltı, öğle, akşam, ara öğün) her kayıt ayrı satır olarak — ad, miktar, kcal — listelenir; (d) gelecekteki bir güne kayıt eklenemez. |
| F3 | Günlük kaydını silme ve miktarını düzenleme | Zorunlu | Yok | Kayıt sola kaydırılınca silinir ve 4 sn boyunca "Geri al" SnackBar'ı gösterilir (Geri al'a basınca kayıt aynı öğüne geri gelir); kayda dokununca `FoodDetailScreen` düzenleme modunda açılır (buton "Güncelle"), miktar ve öğün F7 kurallarıyla değiştirilir; silme/düzenleme sonrası ana sayfa ve Günlük toplamları uygulama yeniden başlatılmadan güncel değeri gösterir (widget testiyle doğrulanır); değişiklik bulutta kalıcıdır (başka cihazda aynı sonuç görünür). |
| F4 | Yiyecek arama ve katalog | Zorunlu | Kısmi | Türkçe karakter duyarsız arama: "cilbir" → "Çılbır", "IZGARA" → "Izgara Köfte", "sut" → "Süt" bulunur (`foodImageSlug` benzeri normalize fonksiyonu, birim testli); ≈ 220 öğelik katalogda her tuş vuruşundan sonra liste ≤ 100 ms içinde güncellenir (profile build, orta sınıf cihaz – bkz. §6); kategori filtresi 12 kategorinin hepsini gösterir. Katalog uygulama içinde statik kalır, buluttan çekilmez. |
| F5 | Barkod ile ekleme | Zorunlu | Var | Yerel katalogdaki barkod ağ çağrısı yapmadan bulunur; bilinmeyen barkodda "Ürün bulunamadı" ekranı; ağ yoksa ≤ 12 sn içinde Türkçe hata mesajı; mevcut 9 birim testi geçer. |
| F6 | Fotoğrafla tanıma (öneri) | Zorunlu | Kısmi | Fotoğraf çekildikten sonra en fazla 3 aday gösterilir; kullanıcı onaylamadan hiçbir kayıt eklenmez; aday yoksa arama ekranında "Fotoğraftan ne olduğunu anlayamadık. Elle aramayı dene." SnackBar'ı çıkar (mevcut); kamera iptalinde hiçbir mesaj çıkmaz; `matchFoodLabels` için ≥ 3 birim testi vardır (eksik). Fotoğraf buluta yüklenmez. |
| F7 | Yiyecek detayı ve porsiyon | Zorunlu | Var | Porsiyon 0,5 adımla 0,5–10 aralığında ayarlanır (mevcut davranış); gösterilen kalori = `caloriesPer100g × miktar` (yuvarlanmış tam sayı); hedef öğün seçilebilir. |
| F8 | Ana sayfa özeti | Zorunlu | Kısmi | Seçili günün (bugün) tüketilen/kalan kalorisi ve 3 makro, F2 kayıtlarının toplamına eşittir (birim testli). Kalan kalori negatifse "X kcal aşıldı" yazar. |
| F9 | Kalıcı su takibi | Zorunlu | Kısmi | Bardak sayısı tarih bazlı olarak bulutta saklanır; yerel saatle gece yarısından sonra açılan uygulamada bugünkü değer 0'dır; geçmiş günlerin değeri silinmeden saklanır (F12 "Su ustası" bunu kullanır; Günlük ekranında su gösterimi MVP'de zorunlu değil); üst sınır 10 bardak (2,5 L). |
| F10 | Kalıcı kilo geçmişi ve ilerleme grafiği | Zorunlu | Kısmi | Her kilo kaydı (tarih, kg) bulutta saklanır; aynı gün ikinci kayıt öncekinin üzerine yazar; grafik "Haftalık" sekmesinde son 7 günü, "Aylık" sekmesinde son 30 günü gösterir; kilo 30–300 kg aralığı dışında reddedilir. |
| F11 | Seri (streak) hesaplama | Zorunlu | Kısmi | Seri = bugünden (bugün kayıt yoksa dünden) geriye doğru **en az 1 yiyecek kaydı olan ardışık gün** sayısı; F2 verisinden hesaplanır, ayrı saklanmaz; ≥ 5 birim testi (boş, 1 gün, boşluklu, bugün kayıtsız, ay geçişi). |
| F12 | Rozetler | İsteğe bağlı | Kısmi | 4 rozet: İlk adım (ilk kayıt yapıldı), 7 gün seri (seri ≥ 7), Su ustası (herhangi bir günde 10 bardak), Protein avcısı (herhangi bir günde protein ≥ hedef). Kazanılan rozet bulutta saklanır ve bir daha kaybedilmez. |
| F13 | Tarifler, favoriler, "Sana özel", tarifi günlüğe ekleme | Zorunlu | Kısmi | 51 tarifin hepsinin fotoğrafı yüklenir (eksik asset testi); favoriler bulutta saklanır; "Günlüğe ekle" 1 porsiyonu F2'ye `FoodLogEntry` olarak yazar. |
| F14 | Tema, yazı boyutu, animasyon azaltma | Zorunlu | Kısmi | 4 yazı boyutu (0,9/1,0/1,15/1,3) ve "Çok büyük"te hiçbir ana ekranda taşma (overflow) hatası yoktur (widget testi 320×640 dp); ayarlar cihazda saklanır ve yeniden açılışta korunur (cihaz tercihi; buluta yazılmaz). |
| F15 | Hedefleri/profili düzenleme | Zorunlu | Yok | Profil'deki düzenle ikonu, "Kişisel bilgiler" ve "Hedefler ve makrolar" satırları kurulum sihirbazını bulut profilindeki mevcut değerlerle (ad, cinsiyet, yaş, boy, güncel kilo, aktivite, hedef, tempo) önceden doldurulmuş açar; tamamlanınca yeni hedefler buluta kaydedilir, geçmiş günlük kayıtları **silinmez**. |
| F16 | Hesabı ve tüm verileri silme | Zorunlu | Yok | Ayarlar > "Gizlilik ve veriler" içinde **"Hesabımı sil"** satırı; onay diyaloğu (geri alınamaz uyarısı) sonrası kullanıcının buluttaki tüm kayıtları (profil, günlük, su, kilo, favoriler, rozetler, onay kaydı) **ve kimlik doğrulama hesabı** silinir, cihazdaki önbellek temizlenir, uygulama karşılama ekranına döner; aynı e-postayla tekrar kayıt olunduğunda eski veri görünmez. (KVKK silme hakkı ve App Store hesap silme şartı.) |
| F17 | İşlevsiz butonların temizlenmesi | Zorunlu | Yok | §2'deki 17 işlevsiz öğe için karar: **bağlananlar** — düzenle ikonu, Kişisel bilgiler, Hedefler ve makrolar → F15; Çıkış yap, Şifremi unuttum, Şifreyi değiştir → F18; Gizlilik ve veriler → F16 + F20. **Kaldırılanlar** — Google ile devam et ×2 (§9 D5 kararına kadar), Bildirimler, Yardım ve destek, Birimler, Yiyeceği kendin ekle, English seçeneği, Rozetler başlığındaki buton, ilerleme takvim ikonu, ayarlardaki işlevsiz ikon butonu. Bitti kontrolü: `grep -rnE "(onTap|onPressed): \(\) \{\}" lib/` ve `grep -rn "yakında" lib/` boş döner. |
| F18 | Gerçek hesap: kayıt, giriş, çıkış, şifre | Zorunlu | Yok | (a) Kayıt: ad + e-posta + şifre (≥ 8 karakter); geçersiz e-posta veya kısa şifrede Türkçe alan hatası; zaten kayıtlı e-postada "Bu e-posta ile bir hesap var" mesajı. (b) Giriş: yanlış şifre/e-postada tek tip "E-posta veya şifre hatalı" mesajı (hangi alanın yanlış olduğu söylenmez). (c) Oturum uygulama yeniden açıldığında korunur; geçerli oturum varsa giriş ekranı gösterilmez. (d) "Çıkış yap" onay sonrası oturumu kapatır, cihazdaki kullanıcı önbelleğini temizler, karşılama ekranına döner; buluttaki veri silinmez. (e) "Şifremi unuttum" girilen e-postaya sıfırlama bağlantısı gönderir ve e-postanın kayıtlı olup olmadığını ele vermeyen bir onay mesajı gösterir. (f) "Şifreyi değiştir" mevcut şifreyi ister. (g) Şifre uygulamada hiçbir yerde saklanmaz/loglanmaz; doğrulamayı yalnızca bulut sağlayıcının kimlik servisi yapar. |
| F19 | Bulut senkronizasyonu ve çevrimdışı çalışma | Zorunlu | Yok | (a) Giriş sonrası kullanıcının verisi buluttan indirilir ve cihazda önbelleğe alınır; ana sayfa önbellek doluysa ağ beklemeden açılır. (b) İnternet yokken yiyecek/su/kilo eklenebilir; değişiklik cihazda kuyruğa alınır, ekranda hemen görünür, bağlantı geri geldiğinde ≤ 30 sn içinde buluta yazılır; uygulama kuyruk boşalmadan kapatılsa bile değişiklik kaybolmaz (§9 D2). (c) Senkronize edilemeyen değişiklik varsa Profil'de "Senkronize ediliyor…" / "Çevrimdışı – değişiklikler kaydedilecek" göstergesi bulunur. (d) Aynı kayıt iki cihazda değiştirilirse `updatedAt` değeri en yeni olan kazanır. (e) Kullanıcı yalnızca **kendi** verisini okuyup yazabilir: başka bir kullanıcının kimliğiyle okuma/yazma denemesi sunucu tarafında reddedilir (güvenlik kuralı testiyle doğrulanır). |
| F20 | KVKK aydınlatma ve açık rıza | Zorunlu | Yok | Kayıt ekranında aydınlatma metnine bağlantı ve **işaretlenmemiş** "Sağlık verilerimin (kilo, beslenme) işlenmesine ve yurt dışındaki sunucularda saklanmasına açık rıza veriyorum" onay kutusu vardır; işaretlenmeden kayıt butonu pasiftir; onay tarihi ve metin sürümü bulut profiline yazılır; Ayarlar > "Gizlilik ve veriler" aydınlatma metnini uygulama içinde gösterir. Metnin hukuki içeriği kullanıcı tarafından sağlanır (agent hukuki metin yazmaz, yer tutucu bırakır). |

### 3.2 Sonraki Sürümler (MVP sonrası, şimdi yapılmayacak)

- İngilizce dil desteği (`flutter_localizations` + ARB dosyaları).
- Google ile giriş / Apple ile giriş (iOS'ta üçüncü taraf girişi sunulursa Apple ile giriş de zorunlu olur) — §9 D5.
- Kullanıcının kendi yiyeceğini/tarifini ekleyebilmesi (buluta kullanıcıya özel katalog tablosu gerektirir).
- Hatırlatma bildirimleri (su, öğün).
- Gün bazlı detaylı istatistik ekranı (haftalık makro ortalaması).
- Verileri JSON olarak dışa aktarma (KVKK veri taşınabilirliği için ileride gerekebilir).
- Yemeğe özel eğitilmiş görüntü tanıma modeli (TFLite).
- Apple Health / Google Health Connect entegrasyonu.
- Web paneli veya diyetisyenle paylaşım.

### 3.3 İş Kuralları (değiştirilmeden uygulanır)

- **BMR (Mifflin-St Jeor):** `10×kg + 6,25×cm − 5×yaş + (erkek ? 5 : −161)`.
- **TDEE:** `BMR × çarpan`; çarpanlar: hareketsiz 1,2 / hafif 1,375 / orta 1,55 / aktif 1,725.
- **Hedef kalori:** ver → `TDEE − haftalıkTempo×7700/7`; al → `+`; koru → `TDEE`. Sonra `[taban, 4000]` aralığına sıkıştır; taban kadın 1200, erkek 1500.
- **Makrolar:** protein = `kg × 1,8` g; yağ = `kalori × 0,27 / 9` g; karbonhidrat = kalan kalori / 4 g (0–999).
- **Haftalık tempo:** 0,25 / 0,5 / 0,75 kg seçeneklerinden biri (`setup_goal_screen.dart` `_weeklyPaceOptions`); "koru" hedefinde kullanılmaz.
- **Su:** 1 bardak = 250 ml, günlük hedef 10 bardak.
- **Gün sınırı:** cihazın yerel saat diliminde 00:00. Kayıtların `date` alanı cihazın yerel tarihidir ve buluta bu haliyle (`yyyy-MM-dd`) yazılır; sunucu saatine göre yeniden hesaplanmaz.
- **Besin değerleri:** katalogda 100 g (veya `servingLabel`) başınadır; tarif değerleri porsiyon başınadır.

---

## 4. Mimari

- **Genel yaklaşım:** Flutter istemcisi + **yönetilen bulut arka ucu (BaaS)**: Supabase (PostgreSQL + Auth) veya Firebase (Firestore + Auth) — seçim §9 D1'de bekliyor. Kendi sunucumuzu yazmıyoruz; iş mantığı (kalori hesabı, seri) istemcide kalır, bulut yalnızca **kimlik doğrulama + kullanıcı verisinin saklanması** için kullanılır.
- **Sağlayıcıdan bağımsızlık:** Uygulama kodu bulut SDK'sını doğrudan çağırmaz. Tüm erişim `lib/data/repositories/` altındaki soyut arayüzlerden (`AuthRepository`, `UserDataRepository`) geçer; Supabase veya Firebase'e özel kod yalnızca `lib/data/backend/<sağlayıcı>/` klasöründe yaşar. Böylece D1 kararı ertelenebilir ve Aşama 0–2 karar beklemeden ilerler; sağlayıcı değişirse yalnızca o klasör değişir.
- **Çevrimdışı öncelikli okuma, kuyruklu yazma:** Ekranlar veriyi cihazdaki önbellekten (`LocalStore`) okur; yazma önce önbelleğe + bekleyen değişiklik kuyruğuna gider, ardından `SyncService` buluta gönderir (F19). Firebase seçilirse Firestore'un yerleşik çevrimdışı kalıcılığı bu katmanın yerini kısmen alabilir; arayüz değişmez.
- **Durum yönetimi:** `provider` + tekil `AppState` (`ChangeNotifier`). `AppState` repository'leri kullanır; ekranlar `context.watch/select` ile dinler. Ekranlar repository veya bulut SDK'sını doğrudan çağırmaz.
- **Cihazda kalanlar:** Tema, yazı boyutu, animasyon azaltma, dil (cihaz tercihleri) `shared_preferences`'ta kalır, buluta yazılmaz. Katalog ve tarifler uygulamaya gömülü statik veridir.
- **Dış ağ çağrıları:** (1) seçilen bulut sağlayıcı (kimlik + kullanıcı verisi), (2) Open Food Facts (yalnızca barkod numarası). Başka bir servise veri gönderilmez.
- **Ortamlar:** Bulutta **iki ayrı proje**: `denge-dev` (geliştirme/test) ve `denge-prod` (gerçek kullanıcılar). Agent yalnızca `dev` ile çalışır.
- **Yönlendirme:** `lib/router.dart` içinde isimli rotalar (`AppRoutes`) + argümanlı rotalar için `push*` yardımcıları. Yeni rota buraya eklenir. Açılışta oturum durumuna göre yönlendirme: oturum yok → karşılama; oturum var, profil yok → kurulum; ikisi de var → ana sayfa.

### 4.1 Bileşenler ve sorumlulukları

| Bileşen | Dosya | Sorumluluk |
|---|---|---|
| `AppState` | `lib/data/app_state.dart` | Uygulama durumu, kurulum, ayarlar; UI'a `notifyListeners`. İş mantığını kendisi hesaplamaz, veriye doğrudan erişmez; aşağıdakilere devreder. |
| `NutritionCalculator` (yeni) | `lib/data/nutrition_calculator.dart` | §3.3 formülleri; saf fonksiyonlar, Flutter bağımlılığı yok. `AppState._bmr` ve `completeSetup` içindeki hesaplar buraya taşınır. |
| `StreakCalculator` (yeni) | `lib/data/streak.dart` | F11 seri hesabı; saf fonksiyon. |
| `AuthRepository` (yeni, arayüz) | `lib/data/repositories/auth_repository.dart` | `signUp`, `signIn`, `signOut`, `sendPasswordReset`, `changePassword`, `deleteAccount`, `currentUser`, `authStateChanges`. Hatalar `sealed AuthResult` ile döner. |
| `UserDataRepository` (yeni, arayüz) | `lib/data/repositories/user_data_repository.dart` | Profil, `FoodLogEntry`, su, kilo, favoriler, rozetler, onay kaydı için okuma/yazma/silme. |
| Fake repository'ler (yeni) | `lib/data/repositories/fake/` | Bellek içi uygulamalar; testlerde ve D1 kararı verilene kadar geliştirmede kullanılır. |
| Sağlayıcı uygulaması (yeni, D1 sonrası) | `lib/data/backend/supabase/` **veya** `lib/data/backend/firebase/` | Arayüzlerin gerçek uygulaması. Bulut SDK'sını import eden **tek** yer. |
| `LocalStore` (yeni) | `lib/data/local_store.dart` | `shared_preferences` üzerinde cihaz tercihleri + kullanıcı verisi önbelleği + bekleyen değişiklik kuyruğu; JSON serileştirme, `schema_version`. |
| `SyncService` (yeni) | `lib/data/sync_service.dart` | Kuyruğu buluta boşaltır, bağlantı gelince tekrar dener, `updatedAt` ile çakışma çözer (F19). |
| Katalog verisi | `lib/data/mock_data.dart`, `extra_foods.dart`, `more_foods.dart`, `recipes.dart` | Statik `const` yiyecek/tarif listeleri, barkod kataloğu. Buluta taşınmaz. |
| Barkod arama | `lib/data/product_lookup.dart` | Yerel katalog → Open Food Facts; `sealed` sonuç tipleri. |
| Fotoğraf tanıma | `lib/data/food_recognition.dart` | ML Kit etiketleri → katalog eşleşmesi. |
| Ekranlar | `lib/screens/<alan>/` | Sadece sunum ve kullanıcı etkileşimi. |
| Tema | `lib/theme/` | `AppTheme.light/dark`, `DengeColors` (`context.dengeColors`). |
| Ortak bileşenler | `lib/widgets/` | ≥ 2 ekranda kullanılan widget'lar. |

### 4.2 Veri Modeli

Mevcut (`lib/data/models.dart`): `UserProfile`, `FoodItem`, `FoodCategory`, `MealType`, `MealEntry`, `Recipe`, `RecipeDifficulty`, `WeightEntry`; `app_state.dart` içinde `SetupDraft`, `Gender`, `ActivityLevel`, `WeightGoal`, `TextScaleOption`.

Eklenecek / değişecek (Dart modelleri; her biri `toJson`/`fromJson` ile, sağlayıcıdan bağımsız):

```text
UserProfile (genişler)           // F1, F15, F20 — kullanıcı başına 1 kayıt
  userId: String                  // kimlik servisinin verdiği kullanıcı kimliği
  name, email: String
  gender: Gender, age: int, heightCm: double
  weightKg: double                // güncel kilo
  startWeightKg, goalWeightKg: double
  activityLevel: ActivityLevel, goal: WeightGoal, weeklyPaceKg: double
  calorieGoal, proteinGoalG, carbsGoalG, fatGoalG: int
  memberSince: DateTime
  consentVersion: String, consentAt: DateTime   // F20
  updatedAt: DateTime

FoodLogEntry                      // F2 — günlükteki tek bir kayıt
  id: String                      // istemcide üretilen UUID v4 (çevrimdışı oluşturulabilsin diye)
  userId: String
  date: String                    // 'yyyy-MM-dd', cihazın yerel tarihi
  meal: MealType
  foodName, brand, servingLabel: String
  amount: double                  // porsiyon çarpanı (0.25–10)
  kcal: int                       // kayıt anında hesaplanır, sonra katalog değişse de sabit kalır
  proteinG, carbsG, fatG: double
  loggedAt, updatedAt: DateTime

WaterLog        { userId, date: 'yyyy-MM-dd', glasses: int (0–10), updatedAt }   // F9, (userId, date) tekil
WeightEntry     { userId, date: 'yyyy-MM-dd', kg: double, updatedAt }            // F10, (userId, date) tekil
FavoriteRecipe  { userId, recipeTitle: String }                                  // F13
EarnedBadge     { userId, badgeId: String, earnedAt: DateTime }                  // F12

DayLog                            // hesaplanan görünüm, saklanmaz
  date, entries: List<FoodLogEntry>, waterGlasses: int
  totals: kcal / protein / carbs / fat
```

- `MealEntry` ekranlarda öğün özeti olarak kalabilir ama artık **`FoodLogEntry` listesinden türetilir**, ayrıca saklanmaz. Seri (`streakDays`) da saklanmaz, hesaplanır.
- `FoodLogEntry` katalog öğesine referans tutmaz; değerlerin kopyasını tutar (katalog güncellemesi geçmişi değiştirmesin diye).
- İlişkiler: `UserProfile 1 — N` her diğer tablo/koleksiyon; hepsi `userId` ile kullanıcıya bağlıdır.
- **Bulutta karşılığı (D1'e göre):**
  - Supabase: `profiles`, `food_log_entries`, `water_logs`, `weight_entries`, `favorite_recipes`, `earned_badges` tabloları; hepsinde `user_id uuid references auth.users on delete cascade`; **Row Level Security açık**, politika `user_id = auth.uid()`. Şema SQL göç dosyalarıyla `supabase/migrations/` altında sürümlenir.
  - Firebase: `users/{uid}` belgesi (profil) + `users/{uid}/food_log`, `/water`, `/weight`, `/favorites`, `/badges` alt koleksiyonları; Security Rules `request.auth.uid == uid`. Kurallar `firebase/firestore.rules` dosyasında sürümlenir.
- **Saklama süresi:** Bulutta kullanıcı hesabını silene kadar tüm geçmiş tutulur; cihaz önbelleğinde son 365 gün tutulur.

### 4.3 Cihazda Saklama Anahtarları (`shared_preferences`)

| Anahtar | Tip | İçerik |
|---|---|---|
| `theme_mode`, `text_scale`, `reduce_motion`, `locale` | — | Cihaz tercihleri; değişmez, buluta yazılmaz. |
| `setup_complete`, `user_*`, `favorite_recipes` | — | **Eski** (bulut öncesi) anahtarlar. İlk girişte buluttaki profil boşsa bu değerler profile aktarılır (tek seferlik göç), sonra silinir. |
| `schema_version` | int | Önbellek formatı; başlangıç `1`. Format değişirse artırılır ve `LocalStore.load` içinde göç yazılır. |
| `cache_user_id` | String | Önbelleğin ait olduğu kullanıcı; farklı kullanıcı giriş yaparsa önbellek temizlenir. |
| `cache_profile`, `cache_log_entries`, `cache_water_by_day`, `cache_weight_history`, `cache_favorites`, `cache_badges` | String (JSON) | Bulut verisinin cihazdaki kopyası (son 365 gün). |
| `pending_ops` | String (JSON dizi) | Henüz buluta yazılamamış değişiklikler: `{op: upsert/delete, entity, payload, queuedAt}`. |

Oturum belirteçleri (token) sağlayıcı SDK'sının kendi güvenli deposunda tutulur; `shared_preferences`'a elle yazılmaz.

### 4.4 Dış Bağımlılıklar

| Paket / servis | Amaç |
|---|---|
| `provider` ^6.1 | Durum yönetimi |
| `shared_preferences` ^2.5 | Cihaz tercihleri + önbellek + değişiklik kuyruğu |
| `fl_chart` ^0.69 | Kilo grafiği |
| `mobile_scanner` ^7.4 | Barkod tarama |
| `image_picker` ^1.2 | Kamera |
| `google_mlkit_image_labeling` ^0.15 | Cihaz üstü görüntü etiketleme |
| `http` ^1.6 | Open Food Facts |
| **Bulut SDK'sı (D1 sonrası, onayla eklenir)** | Supabase: `supabase_flutter` · Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Bağlantı durumu (gerekirse, onayla) | `connectivity_plus` — F19 kuyruğunu tetiklemek için; SDK yeterliyse eklenmez |
| Open Food Facts API v2 | `GET https://world.openfoodfacts.org/api/v2/product/<barkod>.json` — anahtar yok, `User-Agent` zorunlu |
| `tool/fetch_food_images.py` (Python 3, `requests`, `Pillow`) | Sadece geliştirme: Wikimedia'dan yiyecek/tarif fotoğrafı indirir. Uygulamaya dahil değildir. |

---

## 5. Klasör Yapısı

`(yeni)` işaretliler MVP sırasında eklenecek; diğerleri mevcuttur. `(D1)` işaretliler sağlayıcı seçimine göre yalnızca biri oluşturulur.

```
EatWellApp/
├── CLAUDE.md, ISKELET.md, AGENT.md, README.md
├── pubspec.yaml, pubspec.lock, analysis_options.yaml
├── lib/
│   ├── main.dart                 # Giriş: bulut SDK init → AppState.load() → DengeApp
│   ├── router.dart               # AppRoutes (tüm rotalar burada)
│   ├── data/                     # Model, durum, iş mantığı, veri. Saf mantık dosyaları (nutrition_calculator, streak,
│   │                             # model JSON dönüşümleri) Flutter import etmez; app_state/models/mock_data mevcut haliyle istisna
│   │   ├── models.dart
│   │   ├── app_state.dart
│   │   ├── nutrition_calculator.dart   (yeni)
│   │   ├── streak.dart                 (yeni)
│   │   ├── local_store.dart            (yeni)
│   │   ├── sync_service.dart           (yeni)
│   │   ├── repositories/               (yeni) arayüzler + fake/ bellek içi uygulamalar
│   │   ├── backend/supabase/  veya  backend/firebase/   (yeni, D1) — bulut SDK'sını import eden tek yer
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
├── supabase/migrations/*.sql     (yeni, D1=Supabase) — şema + RLS politikaları
├── firebase/firestore.rules      (yeni, D1=Firebase) — güvenlik kuralları (+ firebase.json)
├── docs/
│   ├── screenshots/*.png         # README görselleri
│   └── privacy/aydinlatma_metni.md  (yeni) — F20 metni, kullanıcı/hukukçu tarafından doldurulur
├── assets/
│   ├── foods/<slug>.jpg          # 256×256, slug = foodImageSlug(ad)
│   ├── recipes/<slug>.jpg        # 800×600
│   └── fonts/Nunito-*.ttf
├── tool/fetch_food_images.py
├── android/, ios/                # Platform kabukları — sadece izin/ayar değişikliği
```

---

## 6. Kısıtlar

- **Teknik:**
  - Flutter stable, Dart SDK `^3.9.2` (`pubspec.lock`: flutter ≥ 3.35, dart ≥ 3.11). Hedef platformlar: Android (minSdk = Flutter varsayılanı; Firebase seçilirse en az 23) ve iOS 15+.
  - Yeni paket eklemek onay gerektirir (bkz. AGENT.md). Tercih: pub.dev'de "Flutter Favorite" veya ≥ 1000 like ve son 12 ayda güncellenmiş paketler.
  - `lib/data/` altındaki iş mantığı (hesap, seri, serileştirme) Flutter widget'ı import etmez → saf Dart birim testiyle test edilir.
  - Bulut SDK'sı yalnızca `lib/data/backend/` altında import edilir.
- **Performans** (orta sınıf cihaz = Android 13, 6 GB RAM, Pixel 6a sınıfı; profile build; eşikler Aşama 0'da ve bulut bağlantısı sonrası ölçümle doğrulanır):
  - Soğuk açılıştan ana sayfanın ilk karesine ≤ 3 sn (önbellek dolu, ağ beklenmeden).
  - Arama listesi güncellemesi ≤ 100 ms; kaydırmada kare süresi ≤ 16 ms (DevTools "jank" yok).
  - `AppState.load()` 365 günlük önbellekle ≤ 300 ms.
  - Yeni cihazda girişten sonra 365 günlük verinin buluttan indirilip ana sayfanın gösterilmesi ≤ 5 sn (4G).
  - Release APK (`--split-per-abi`, arm64) ≤ 60 MB.
- **Güvenlik / gizlilik:**
  - Kişisel veri (ad, e-posta, kilo, günlük) **yalnızca seçilen bulut sağlayıcıya**, TLS üzerinden gönderilir. Analitik, reklam veya başka üçüncü tarafa gönderilmez; loglara yazılmaz. Open Food Facts'e yalnızca barkod numarası gider.
  - Şifre uygulamada saklanmaz, loglanmaz; doğrulamayı yalnızca sağlayıcının kimlik servisi yapar.
  - Her kullanıcı yalnızca kendi verisine erişir: Supabase'de tüm tablolarda RLS açık, Firebase'de Security Rules; varsayılan **erişim kapalı**. Kurallar emülatör/yerel testle doğrulanmadan prod'a uygulanmaz.
  - Yönetici anahtarları (Supabase `service_role`, Firebase Admin SDK hizmet hesabı) **uygulamaya, depoya veya loglara asla girmez**. İstemciye gömülen yapılandırma (Supabase URL + anon key / Firebase `firebase_options.dart`) gizli sayılmaz; güvenlik kurallara dayanır.
  - Kamera görüntüsü sadece cihaz üstü ML Kit'te işlenir; buluta yüklenmez, diske kalıcı kopya tutulmaz (geçici dosya hariç).
  - Kamera izni Android `AndroidManifest.xml` ve iOS `NSCameraUsageDescription` ile Türkçe gerekçeyle istenir.
- **Hukuki (KVKK):** Kilo ve beslenme verisi **sağlık verisi** sayılabilir (özel nitelikli kişisel veri). Bu yüzden: açık rıza + aydınlatma metni (F20), hesap ve veri silme (F16), veri bölgesi kararı (§9 D3). Yayından önce hukuki görüş alınır; agent hukuki metin üretmez.
- **Erişilebilirlik:** Tüm dokunma hedefleri ≥ 48×48 dp; ikon-only butonlarda `tooltip` veya `Semantics` etiketi; metin/arka plan kontrastı ≥ 4.5:1 (her iki temada).
- **Dil:** Arayüz metinleri Türkçe ve doğrudan kodda (MVP'de i18n altyapısı yok). Sağlayıcının gönderdiği e-postalar (doğrulama, şifre sıfırlama) Türkçe şablonla yapılandırılır.
- **Zaman / bütçe:** Tek geliştirici + AI agent. Bulut maliyeti MVP boyunca sağlayıcının **ücretsiz katmanında** kalmalı; ücretli plana geçiş kullanıcı kararıdır.

---

## 7. Geliştirme Aşamaları

Sıra bağımlılığa göredir; bir aşama "Bitti Kriteri" karşılanmadan sonrakine geçilmez. Aşama 0–2 bulut sağlayıcı kararını **beklemez**; Aşama 3 D1 kararı verilmeden başlayamaz.

| Aşama | İçerik | Özellikler | Bitti Kriteri |
|---|---|---|---|
| 0 — Temel ve hijyen | Flutter ortamını doğrula; `android/build/` ve `.claude/scheduled_tasks.lock`'u git'ten çıkar ve `.gitignore`'a ekle; `pubspec.yaml` `description` alanını "Denge – Türk mutfağı kalori takibi" yap; `flutter analyze`'daki tüm uyarıları sıfırla; release APK boyutunu ve soğuk açılışı ölç. | — | `flutter analyze` 0 sorun; `flutter test` yeşil; `git ls-files android/build` boş; ölçüm sonuçları §6'ya yazıldı. |
| 1 — Hesap katmanı | `NutritionCalculator` çıkar, `AppState.completeSetup` onu kullansın; birim testleri. | F1 (hesap kısmı) | `test/data/nutrition_calculator_test.dart` ≥ 6 test geçer; davranış değişmedi (aynı girdi → aynı hedef). |
| 2 — Veri katmanı (sağlayıcıdan bağımsız) | Modeller + JSON (`FoodLogEntry`, `WaterLog`, `WeightEntry`, genişleyen `UserProfile`…); `AuthRepository` / `UserDataRepository` arayüzleri + fake uygulamalar; `LocalStore` (önbellek + kuyruk + `schema_version`); `AppState` repository'leri kullanacak şekilde; Diary geçmiş günleri gösterir; ana sayfa toplamları türetilir. Bu aşama sonunda veri **cihazda** kalıcıdır. | F2 (a, c, d — cihazda), F8, F13 (günlüğe ekleme) | Serileştirme gidiş-dönüş testleri; fake repository ile `AppState` testleri; F8 kriteri; elle test: kayıt ekle → uygulamayı öldür → aç → kayıt duruyor. |
| 3 — Bulut ve hesap | **D1, D3 kararı verildikten sonra:** dev/prod bulut projeleri; şema + güvenlik kuralları (dosyada sürümlü); sağlayıcı repository uygulaması; gerçek kayıt/giriş/çıkış/şifre sıfırlama; KVKK onay kutusu; açılışta oturuma göre yönlendirme; eski `user_*` anahtarlarının göçü. | F18, F20, F1 (bulut profili) | F18, F20 kriterleri; güvenlik kuralı testi (başka kullanıcının verisi okunamaz/yazılamaz) geçer; elle test: kayıt ol → kurulum → uygulamayı sil → kur → giriş → profil geri geldi. |
| 4 — Senkronizasyon | `SyncService`, kuyruğun buluta boşaltılması, çevrimdışı ekleme, çakışma çözümü, durum göstergesi; günlük ve favoriler bulutta. | F19, F2 (b), F13 (favoriler) | F19 ve F2 kriterleri; kuyruk/çakışma birim testleri; elle test: uçak modunda kayıt ekle → uygulamayı kapat → interneti aç → aç → kayıt bulutta ve ikinci cihazda görünüyor. |
| 5 — Düzenleme, su, kilo | Silme + geri al, miktar düzenleme; su ve kilo tarih bazlı ve bulutta. | F3, F9, F10 | F3, F9, F10 kriterleri; ilgili birim/widget testleri geçer. |
| 6 — Seri, rozet, profil düzenleme | `StreakCalculator`, bulutta rozetler, hedef düzenleme. | F11, F12, F15 | F11, F12, F15 kriterleri. |
| 7 — Hesap silme, temizlik ve cila | Hesap silme, boş butonların bağlanması/kaldırılması, erişilebilirlik ve taşma testleri, F6 testleri, eksik asset testi, Türkçe e-posta şablonları. | F4, F6, F14, F16, F17 | Tüm F kriterleri; `lib/data/` satır kapsamı ≥ %70 (`flutter test --coverage`); `flutter build apk --release` ve `flutter build ios --release --no-codesign` başarılı; prod güvenlik kuralları dev ile aynı. |

---

## 8. Riskler

| # | Risk | Etki | Olasılık | Önlem |
|---|---|---|---|---|
| R1 | Cihaz önbelleği `shared_preferences`'ta büyür (365 gün × ~8 kayıt ≈ 3.000 kayıt ≈ 600 KB). | Açılış gecikmesi | Orta | 365 gün sınırı; `LocalStore` soyutlaması; ölçüm > 300 ms ise önbellek için `sqflite`'a geçiş (onay ile). |
| R2 | Format değişince veri bozulur (önbellek veya bulut şeması). | Veri kaybı | Orta | Önbellekte `schema_version` + göç testi; bulutta yalnızca geriye uyumlu (ekleyici) şema değişikliği, sürümlü göç dosyaları, önce `dev`'de denenir. |
| R3 | ML Kit genel etiketleyicisi Türk yemeklerinde yanlış/boş sonuç verir. | Kullanıcı güveni | Yüksek | Her zaman onay adımı; aday yoksa aramaya yönlendirme; özel model "Sonraki Sürümler"de. |
| R4 | Open Food Facts'te Türk ürünleri eksik veya besin değeri hatalı. | Yanlış kalori | Yüksek | Yerel barkod kataloğu önce; enerji verisi olmayan ürün "bulunamadı" sayılır; kullanıcı porsiyonu görür. |
| R5 | Katalogdaki kalori değerleri yaklaşık (kaynak belirtilmemiş). | Yanlış hedef takibi | Orta | Değerler "yaklaşık" olarak etiketlenir; düzeltmeler tek bir veri dosyasında yapılır; tıbbi iddia yok. |
| R6 | Wikimedia fotoğraflarının lisans/atıf yükümlülüğü. | Mağaza reddi / hukuki | Düşük | Mağazaya çıkmadan önce atıf listesi `docs/` altına eklenir. |
| R7 | Agent'ın çalıştığı ortamda Flutter SDK veya bulut emülatörü olmayabilir. | Doğrulanmamış kod | Orta | AGENT.md: komut çalıştırılamazsa "doğrulanmadı" diye raporlanır, iş bitti sayılmaz. (Yerel makinede Flutter 3.47.5 kurulu.) |
| R8 | Tıbbi tavsiye gibi algılanma (düşük kalori hedefleri). | Kullanıcı sağlığı | Düşük | 1200/1500 kcal tabanı; "genel bilgi" uyarısı; tıbbi iddia içeren metin yok. |
| R9 | Hatalı güvenlik kuralı/RLS → bir kullanıcı başkasının sağlık verisini okur. | Veri sızıntısı, KVKK ihlali | Orta | Varsayılan erişim kapalı; kurallar depoda sürümlü; "başka kullanıcının verisi okunamaz" testi her kural değişikliğinde çalışır; prod'a uygulama onay gerektirir. |
| R10 | KVKK: sağlık verisinin açık rızasız işlenmesi veya yurt dışına aktarımı. | Hukuki yaptırım, mağaza reddi | Orta | F20 açık rıza; F16 silme; D3 veri bölgesi kararı; yayından önce hukuki görüş. |
| R11 | Yönetici anahtarının (service_role / Admin SDK) depoya veya uygulamaya sızması. | Tüm verinin ifşası | Düşük | Yönetici anahtarı hiçbir koşulda istemcide kullanılmaz; `.gitignore`; commit öncesi anahtar taraması; sızarsa anahtar hemen yenilenir. |
| R12 | Çevrimdışı kuyruk / iki cihaz arasında çakışma → kayıt kaybı veya çift kayıt. | Yanlış günlük | Orta | İstemcide üretilen UUID ile idempotent upsert; `updatedAt` ile son yazan kazanır; kuyruk birim testleri. |
| R13 | Sağlayıcıya bağımlılık (vendor lock-in) veya ücretsiz katmanın aşılması. | Taşıma maliyeti / fatura | Düşük | Repository soyutlaması (SDK tek klasörde); sağlayıcı panelinde kota uyarısı; ücretli plana geçiş kullanıcı kararı. |
| R14 | Bulut kesintisi veya ağ yok. | Kayıt yapılamaz | Orta | Önbellekten okuma + kuyruklu yazma (F19); kullanıcıya çevrimdışı göstergesi. |

---

## 9. Açık Kararlar

Kod bu kararlara göre şekillenir; karar verilince ilgili satır "Karar:" ile güncellenir ve ilgili bölümler (§4, §4.4, §5) sadeleştirilir.

| # | Karar | Seçenekler | Etkilediği | Durum |
|---|---|---|---|---|
| D1 | Bulut sağlayıcı | **Supabase** (PostgreSQL, SQL ile sorgulama/raporlama kolay, RLS, açık kaynak, kendin barındırma mümkün; çevrimdışı kuyruğu biz yazarız) · **Firebase** (Firestore, yerleşik çevrimdışı önbellek ve senkron, olgun Flutter desteği; NoSQL, ilişkisel sorgu zayıf, kullanım başına ücret) | §4, §4.4, §5, Aşama 3–4 | ⏳ Kullanıcı karar verecek |
| D2 | Çevrimdışı davranış | Önerilen varsayılan: çevrimdışı ekleme + kuyruk (F19 b). Alternatif: çevrimdışıyken salt okuma. | F19, `SyncService` | ⏳ Varsayılan geçerli, aksi söylenene kadar |
| D3 | Veri bölgesi | Türkiye bölgesi iki sağlayıcıda da yok; en yakın AB (Frankfurt / `europe-west`). Yurt dışı aktarım için açık rıza metni (F20) buna göre yazılır. | F20, proje kurulumu | ⏳ Hukuki görüşle birlikte |
| D4 | Hesapsız (misafir) kullanım | Önerilen varsayılan: **hesap zorunlu** (kurulumdan önce kayıt/giriş). Alternatif: misafir modu + sonradan hesaba bağlama (anonim kimlik; daha karmaşık). | F18, açılış yönlendirmesi | ⏳ Varsayılan geçerli, aksi söylenene kadar |
| D5 | Sosyal giriş | MVP'de yalnızca e-posta + şifre. Google girişi eklenirse iOS'ta Apple ile giriş de gerekir. | F17, §3.2 | ⏳ MVP sonrası |
