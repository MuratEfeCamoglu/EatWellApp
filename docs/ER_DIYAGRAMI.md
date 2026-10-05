# Denge — ER Diyagramı

Uygulamanın sunucusu ve veritabanı yoktur. Bu diyagram, `lib/data/` altındaki Dart modellerini ve `shared_preferences` anahtarlarını **mantıksal varlıklar** olarak gösterir.
Kaynak: `lib/data/models.dart`, `lib/data/app_state.dart`, `lib/data/mock_data.dart`, ISKELET.md §4.2–4.3.

Saklanma biçimi lejantı (her varlığın üstündeki açıklamada):

- **[kalıcı]** `shared_preferences`'ta saklanır, uygulama yeniden açılınca geri gelir.
- **[bellek]** Sadece çalışırken bellekte durur; uygulama kapanınca kaybolur.
- **[statik]** Koda gömülü `const` veri (katalog); kullanıcı değiştiremez.
- **[yeni]** Henüz yok; ISKELET.md §7 aşamalarında eklenecek.

Çizgi tipi: düz çizgi (`──`) = gerçek ilişki/referans, kesikli çizgi (`┄┄`) = referans tutulmaz, değerler kopyalanır veya biri diğerinden üretilir.

---

## 1. Mevcut Durum (commit `e1e4922`)

Görsel: [`er_mevcut.png`](er_mevcut.png)

```mermaid
erDiagram
    APP_SETTINGS {
        string themeMode "light | dark  [kalıcı]"
        string textScale "small | normal | large | extraLarge"
        bool reduceMotion
        string locale "tr"
    }

    SETUP_DRAFT {
        string name "[bellek] kurulum sihirbazı taslağı"
        string email
        enum gender "female | male"
        int age
        double heightCm
        double weightKg
        enum activityLevel "sedentary | light | moderate | active"
        enum goal "lose | maintain | gain"
        double weeklyPaceKg "0.25 | 0.5 | 0.75"
        double goalWeightKg "null olabilir"
    }

    USER_PROFILE {
        string name "[kalıcı] user_name"
        string initials
        string email
        int streakDays "şu an hep 0"
        int calorieGoal
        int proteinGoalG
        int carbsGoalG
        int fatGoalG
        double heightCm
        double weightKg "güncel kilo"
        double goalWeightKg
        double weeklyPaceKg
        datetime memberSince
        bool setupComplete
    }

    MEAL_ENTRY {
        enum type PK "[bellek] sadece bugün, öğün başına 1 satır"
        string title "Kahvaltı, Öğle yemeği..."
        string description "eklenen yiyecek adları virgülle"
        int calories "öğün toplamı"
        bool logged
    }

    DAILY_TOTALS {
        double proteinConsumedG "[bellek] sadece bugün"
        double carbsConsumedG
        double fatConsumedG
        int waterGlasses "0-10"
    }

    WEIGHT_ENTRY {
        datetime date "[bellek] açılışta tek nokta"
        double kg
    }

    FAVORITE_RECIPE {
        string recipeTitle FK "[kalıcı] favorite_recipes listesi"
    }

    FOOD_ITEM {
        string name PK "[statik] ~220 öğe; doğal anahtar"
        string brand
        int caloriesPer100g
        double proteinG
        double carbsG
        double fatG
        string servingLabel "100 g, 1 porsiyon (200 g)..."
        set meals "uygun öğünler"
        enum category FK
        string imageAsset "türetilir: assets/foods/slug.jpg"
    }

    BARCODE_PRODUCT {
        string barcode PK "[statik] barcodeCatalog, 5 ürün"
        string foodName FK
    }

    OFF_PRODUCT {
        string barcode PK "Open Food Facts API, kaydedilmez"
        string name
        string brand
        int caloriesPer100g
        string imageUrl
    }

    FOOD_CATEGORY {
        enum id PK "[statik] 12 kategori"
        string label "Çorbalar, Tatlılar..."
    }

    RECIPE {
        string title PK "[statik] 51 tarif; doğal anahtar"
        string description
        int minutes
        int calories "porsiyon başına"
        double proteinG
        double carbsG
        double fatG
        string tag "Kahvaltı, Çorba..."
        int servings
        enum difficulty "kolay | orta | zor"
        list ingredients
        list steps
        string imageAsset "türetilir: assets/recipes/slug.jpg"
    }

    SETUP_DRAFT ||..|| USER_PROFILE : "completeSetup() üretir"
    USER_PROFILE ||--|| APP_SETTINGS : "cihazda tek"
    USER_PROFILE ||--|{ MEAL_ENTRY : "bugünün 4 öğünü"
    USER_PROFILE ||--|| DAILY_TOTALS : "bugünün toplamları"
    USER_PROFILE ||--o{ WEIGHT_ENTRY : "kilo kaydeder"
    USER_PROFILE ||--o{ FAVORITE_RECIPE : "favoriler"
    FAVORITE_RECIPE }o--|| RECIPE : "başlıkla eşleşir"
    MEAL_ENTRY }o..o{ FOOD_ITEM : "ad + kalori kopyalanır"
    RECIPE ||..o| FOOD_ITEM : "asServing ile 1 porsiyon"
    FOOD_ITEM }o--|| FOOD_CATEGORY : "kategorisi"
    BARCODE_PRODUCT ||--|| FOOD_ITEM : "barkod eşlemesi"
    OFF_PRODUCT ||..|| FOOD_ITEM : "FoodItem'a dönüştürülür"
```

**Mevcut modeldeki sorunlar** (ISKELET.md §2 ile aynı):

- `MEAL_ENTRY` tek tek yiyecekleri tutmuyor; öğün başına yalnızca toplam kalori ve virgülle birleştirilmiş ad metni var. Bu yüzden kayıt silinemez veya düzenlenemez.
- `MEAL_ENTRY`, `DAILY_TOTALS` ve `WEIGHT_ENTRY` bellekte duruyor; tarih alanı yok, bu yüzden geçmiş günler gösterilemiyor.
- `FAVORITE_RECIPE` ve görsel yolları **ada/başlığa** bağlı: bir tarifin başlığı değişirse favori ve fotoğraf eşleşmesi kopar.

---

## 2. Hedef Model (MVP, Aşama 2–4 sonrası)

Görsel: [`er_hedef.png`](er_hedef.png)

```mermaid
erDiagram
    APP_SETTINGS {
        string themeMode "[kalıcı]"
        string textScale
        bool reduceMotion
        string locale
        int schema_version "[yeni] veri formatı sürümü"
    }

    USER_PROFILE {
        string name "[kalıcı]"
        string initials
        string email
        enum gender "[yeni] F15 profil düzenleme için"
        int age "[yeni]"
        enum activityLevel "[yeni]"
        enum goal "[yeni]"
        int calorieGoal
        int proteinGoalG
        int carbsGoalG
        int fatGoalG
        double heightCm
        double weightKg
        double goalWeightKg
        double weeklyPaceKg
        datetime memberSince
        bool setupComplete
    }

    FOOD_LOG_ENTRY {
        string id PK "[yeni][kalıcı] microsecondsSinceEpoch"
        string date "yyyy-MM-dd, yerel saat"
        enum meal FK "breakfast | lunch | dinner | snack"
        string foodName "kopya, referans değil"
        string brand
        string servingLabel
        double amount "porsiyon çarpanı 0.5-10"
        int kcal "kayıt anında sabitlenir"
        double proteinG
        double carbsG
        double fatG
        datetime loggedAt
    }

    WATER_DAY {
        string date PK "[yeni][kalıcı] water_by_day"
        int glasses "0-10, bardak = 250 ml"
    }

    WEIGHT_ENTRY {
        string date PK "[kalıcı] weight_history, günde 1"
        double kg "30-300"
    }

    BADGE_EARNED {
        string badgeId PK "[yeni][kalıcı] first_step | streak_7 | water_master | protein_hunter"
    }

    FAVORITE_RECIPE {
        string recipeTitle PK "[kalıcı]"
    }

    MEAL_TYPE {
        enum id PK "breakfast | lunch | dinner | snack"
    }

    DAY_LOG {
        string date PK "hesaplanır, saklanmaz"
        int totalKcal
        double totalProteinG
        double totalCarbsG
        double totalFatG
    }

    FOOD_ITEM {
        string name PK "[statik]"
        string brand
        int caloriesPer100g
        double proteinG
        double carbsG
        double fatG
        string servingLabel
        enum category FK
    }

    FOOD_CATEGORY {
        enum id PK "[statik] 12 kategori"
        string label
    }

    BARCODE_PRODUCT {
        string barcode PK "[statik]"
        string foodName FK
    }

    RECIPE {
        string title PK "[statik] 51 tarif"
        int calories "porsiyon başına"
        double proteinG
        double carbsG
        double fatG
        enum difficulty
    }

    USER_PROFILE ||--|| APP_SETTINGS : "cihazda tek"
    USER_PROFILE ||--o{ FOOD_LOG_ENTRY : "yediklerini kaydeder"
    USER_PROFILE ||--o{ WATER_DAY : "günlük su"
    USER_PROFILE ||--o{ WEIGHT_ENTRY : "kilo geçmişi"
    USER_PROFILE ||--o{ BADGE_EARNED : "kazanır"
    USER_PROFILE ||--o{ FAVORITE_RECIPE : "favoriler"
    FAVORITE_RECIPE }o--|| RECIPE : "başlıkla eşleşir"
    FOOD_LOG_ENTRY }o--|| MEAL_TYPE : "öğün"
    DAY_LOG ||--o{ FOOD_LOG_ENTRY : "aynı tarihtekiler"
    DAY_LOG ||--o| WATER_DAY : "aynı tarih"
    FOOD_LOG_ENTRY }o..o| FOOD_ITEM : "değerler kopyalanır"
    FOOD_LOG_ENTRY }o..o| RECIPE : "1 porsiyon kopyalanır"
    FOOD_ITEM }o--|| FOOD_CATEGORY : "kategorisi"
    FOOD_ITEM }o--|{ MEAL_TYPE : "uygun öğünler"
    BARCODE_PRODUCT ||--|| FOOD_ITEM : "barkod eşlemesi"
```

**Hedef modelde önemli kararlar:**

- **`FOOD_LOG_ENTRY` katalog öğesine referans tutmaz.** Ad, kalori ve makroların kopyasını tutar, böylece katalogdaki bir değer düzeltilse bile geçmiş kayıtlar değişmez. Aynı nedenle Open Food Facts'ten gelen ürünler de katalogda saklanmadan doğrudan günlüğe yazılabilir.
- **`DAY_LOG` saklanmaz.** Aynı tarihli `FOOD_LOG_ENTRY` kayıtlarıyla `WATER_DAY` birleştirilerek hesaplanır. Ana sayfa ve Günlük ekranındaki toplamlar buradan gelir (F8).
- **Seri (streak) saklanmaz.** Kaydı olan `FOOD_LOG_ENTRY.date` değerlerinin ardışıklığından hesaplanır (F11). Bu yüzden `USER_PROFILE.streakDays` alanı kaldırılır.
- **`WATER_DAY` ve `WEIGHT_ENTRY` için anahtar tarihtir.** Aynı güne yapılan ikinci kayıt öncekinin üzerine yazılır.
- **`USER_PROFILE`'a cinsiyet, yaş, aktivite ve hedef eklenir.** F15'te kurulum sihirbazının mevcut değerlerle açılabilmesi için bunların saklanması gerekir; şu an sadece kurulum sırasında bellekte (`SETUP_DRAFT`) duruyorlar.
- **`MEAL_ENTRY` hedef modelde yok.** Ekranlarda öğün özeti gerekiyorsa `FOOD_LOG_ENTRY` kayıtlarından türetilir.

## 3. Saklama Anahtarları Eşlemesi

| Varlık | `shared_preferences` anahtarı | Biçim |
|---|---|---|
| APP_SETTINGS | `theme_mode`, `text_scale`, `reduce_motion`, `locale`, `schema_version` | düz değerler |
| USER_PROFILE | `setup_complete`, `user_*` (`user_name`, `user_calorie_goal`, …) | düz değerler |
| FAVORITE_RECIPE | `favorite_recipes` | StringList |
| FOOD_LOG_ENTRY | `log_entries` | JSON dizi |
| WATER_DAY | `water_by_day` | JSON nesne `{tarih: bardak}` |
| WEIGHT_ENTRY | `weight_history` | JSON dizi |
| BADGE_EARNED | `badges_earned` | StringList |
