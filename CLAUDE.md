# Denge (EatWellApp)

## Proje
Türk mutfağını tanıyan, çevrimdışı çalışan Flutter kalori ve beslenme takip uygulaması (Android + iOS).
Kullanıcı kişisel kalori/makro hedefini hesaplatır; yediklerini arama, barkod veya fotoğrafla kaydeder; su, kilo ve tarifleri takip eder.
Sunucu ve gerçek hesap yoktur; tüm veri cihazda (`shared_preferences`) tutulur.

- Kapsam, kabul kriterleri, veri modeli, aşamalar: **@ISKELET.md** (tek doğruluk kaynağı)
- Agent yetkileri ve görev döngüsü: **@AGENT.md**
- Adlar: ürün **Denge**, Dart paketi `denge` (`import 'package:denge/...'`), Android `com.denge.denge`.

## Teknoloji Yığını
- Dil: Dart `^3.9.2`, Flutter stable (lock: flutter ≥ 3.35, dart ≥ 3.11)
- UI: Material 3, `lib/theme/` (Nunito yazı tipi gömülü)
- Durum: `provider` + tekil `AppState` (`ChangeNotifier`)
- Depolama: `shared_preferences` (tarih bazlı veri JSON olarak, bkz. ISKELET §4.3)
- Grafik: `fl_chart` · Barkod: `mobile_scanner` · Kamera: `image_picker`
- Görüntü tanıma: `google_mlkit_image_labeling` (cihaz üstü)
- Ağ: `http` → yalnızca Open Food Facts API v2
- Test: `flutter_test`, `package:http/testing.dart` (`MockClient`)
- Lint: `flutter_lints` ^5 (`analysis_options.yaml`)

## Komutlar
| İş | Komut |
|---|---|
| Kurulum | `flutter pub get` |
| Çalıştır (cihaz/emülatör) | `flutter run` |
| Statik analiz (lint) | `flutter analyze` |
| Format (sadece değiştirdiğin dosyalar) | `dart format <dosyalar>` |
| Tüm testler | `flutter test` |
| Tek test dosyası | `flutter test test/data/streak_test.dart` |
| Kapsam | `flutter test --coverage` → `coverage/lcov.info` |
| Android build | `flutter build apk --release --split-per-abi` |
| iOS build (imzasız) | `flutter build ios --release --no-codesign` |
| Yiyecek fotoğrafı indir (geliştirme) | `python tool/fetch_food_images.py` (gerekli: `requests`, `Pillow`) |

Barkod ve fotoğraf özellikleri kamera ister → gerçek cihazda dene; emülatörde test edilmiş sayılmaz.
Ortamda `flutter` yoksa komutu çalıştırmış gibi davranma; AGENT.md "Doğrulanamayan iş" kuralını uygula.

## Klasör Kuralları
Yapı ISKELET.md §5 ile birebir aynıdır.
- `lib/data/` → model, `AppState`, iş mantığı, katalog verisi. Buradaki hesap/serileştirme kodu widget import etmez (saf Dart, birim testli).
- `lib/screens/<alan>/<ad>_screen.dart` → bir ekran = bir dosya, sınıf adı `<Ad>Screen`.
- `lib/widgets/` → yalnızca ≥ 2 ekranda kullanılan widget'lar. Tek ekrana özel widget o ekran dosyasında `_Private` sınıf olarak kalır.
- `lib/theme/` → renkler `context.dengeColors` ve `Theme.of(context).colorScheme` üzerinden; ekranlarda sabit `Color(0x...)` yazma.
- `test/` → `lib/` yapısını aynalar: `lib/data/x.dart` ↔ `test/data/x_test.dart`.
- Yeni rota → `lib/router.dart` içindeki `AppRoutes`'a ekle (sabit + gerekirse `push<Ad>` yardımcısı).
- Yeni yiyecek/tarif fotoğrafı → `assets/foods/<slug>.jpg` / `assets/recipes/<slug>.jpg`; slug `foodImageSlug(ad)` ile üretilir.

## Kod Kuralları
- İsimlendirme: Dart standardı (`UpperCamelCase` sınıf, `lowerCamelCase` üye, `snake_case.dart` dosya).
- Kod tanımlayıcıları ve yorumlar **İngilizce**; kullanıcıya görünen metinler **Türkçe** (MVP'de i18n yok).
- Mümkün olan her widget `const`. `AppState`'i ekranda `context.watch` yerine dar kapsamlı `context.select` ile dinlemeyi tercih et.
- `AppState` alanlarını ekrandan doğrudan değiştirme; `AppState` metodu ekle (değiştir → `notifyListeners()` → `_prefs` yaz sırası).
- İş kuralları (BMR, makro, seri, su) yalnızca ISKELET §3.3'te tanımlandığı gibi; sayıları "iyileştirme" adına değiştirme.
- Hata yönetimi: ağ/kamera/ML Kit hataları `sealed` sonuç tipi veya sonuç nesnesiyle döner (bkz. `product_lookup.dart`, `food_recognition.dart`); UI'a Türkçe, eyleme dönük mesaj gösterilir. Exception yutulacaksa nedeni yorumla yazılır.
- `print` kullanma (`avoid_print`); geçici hata ayıklama için `debugPrint` ve commit öncesi sil.
- Yorumlar "neden"i anlatır, mevcut dosyalardaki `///` doc-comment yoğunluğunu koru.
- Kalıcı veri formatını değiştirirsen `schema_version` artır ve göç + test yaz (ISKELET §4.3, R2).
- Yeni ekranlar hem açık hem koyu temada ve "Çok büyük" yazı boyutunda taşmasız olmalı.

## Test Kuralları
- `lib/data/` altındaki her yeni saf fonksiyon/sınıf için birim testi zorunlu (en az: normal durum + 1 sınır durumu).
- Ağ çağrıları testte asla gerçek ağa çıkmaz → `MockClient` ile enjekte et.
- `SharedPreferences` testlerinde `SharedPreferences.setMockInitialValues({})` kullan.
- Tarih bağımlı mantıkta "şimdi"yi parametre olarak al (`DateTime now`), testte sabit tarih ver.

## Çalışma Kuralları
- Her değişiklikten sonra: `flutter analyze` (0 sorun) + `flutter test` (hepsi yeşil).
- Bir görev = ISKELET'teki bir F-özelliği veya aşama adımı. ISKELET'te tanımlı olmayan bir özelliğe ihtiyaç doğarsa uygulama, rapora yaz; yeni özellikler kullanıcı söyledikçe ISKELET'e eklenir.
- Geliştirme dalı: oturumda belirtilen dal; `main`'e doğrudan push yok.
- Commit: Conventional Commits, Türkçe açıklama. Örn. `feat(diary): günlük kayıtlarını kalıcı yap`, `fix(search): Türkçe karakter eşleşmesi`, `test: seri hesabı testleri`, `chore: build çıktısını git'ten çıkar`.
- Commit başına tek mantıksal değişiklik; üretilmiş dosya (`build/`, `.dart_tool/`, `coverage/`) commit'lenmez.
- README'deki özellik listesi davranış değiştiğinde güncellenir.

## Önemli Notlar / Tuzaklar
- `AppState` tekildir (`AppState.instance`), `main()`'de `await AppState.instance.load()` ile yüklenir; widget testlerinde de önce yüklenmelidir.
- `todaysMeals`, su ve kilo geçmişi şu an **bellekte**; kalıcı hale getirmek Aşama 2–3 işidir (ISKELET §2).
- Kullanıcı seri (`streakDays`) şu an hiç artmıyor; F11 ile türetilen değere dönüşecek.
- Tarif favorileri **başlığa** göre saklanır → tarif başlığını değiştirmek favorileri kırar.
- `foodImageSlug` ile `tool/fetch_food_images.py` aynı slug kuralını kullanır; birini değiştirirsen diğerini de değiştir.
- Kurulum sihirbazı adımları 7 ekrandır (cinsiyet → sonuç); `SetupDraft` oturum boyunca bellekte yaşar.
- Open Food Facts isteklerinde `User-Agent` başlığı zorunludur; kaldırma.
- Gizli anahtar, `.env` veya API anahtarı yoktur ve eklenmemelidir.
