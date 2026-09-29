import 'package:flutter/material.dart';

import 'models.dart';

const _b = {MealType.breakfast};
const _bs = {MealType.breakfast, MealType.snack};
const _d = {MealType.dinner};
const _ld = {MealType.lunch, MealType.dinner};
const _lds = {MealType.lunch, MealType.dinner, MealType.snack};
const _all = {MealType.breakfast, MealType.lunch, MealType.dinner, MealType.snack};

const _kahvalti = FoodCategory.kahvaltilik;
const _corba = FoodCategory.corba;
const _et = FoodCategory.et;
const _balik = FoodCategory.balik;
const _sebze = FoodCategory.sebze;
const _pilav = FoodCategory.pilav;
const _hamur = FoodCategory.hamurIsi;
const _fast = FoodCategory.fastFood;
const _salata = FoodCategory.salata;
const _tatli = FoodCategory.tatli;
const _icecek = FoodCategory.icecek;
const _meyve = FoodCategory.atistirmalik;

/// Third batch of catalog foods, widening every category. Values are
/// approximate per-100 g figures for typical home-style preparations.
const moreFoods = <FoodItem>[
  // Kahvaltılık.
  FoodItem(name: 'Mantarlı Omlet', brand: 'Ev yapımı', caloriesPer100g: 145, proteinG: 10, carbsG: 2, fatG: 11, servingLabel: '2 yumurtalı (150 g)', meals: _b, icon: Icons.egg_rounded, category: _kahvalti),
  FoodItem(name: 'Yumurtalı Ekmek', brand: 'Ev yapımı', caloriesPer100g: 260, proteinG: 9, carbsG: 25, fatG: 14, servingLabel: '2 dilim (100 g)', meals: _b, icon: Icons.breakfast_dining_rounded, category: _kahvalti),
  FoodItem(name: 'Pastırma', brand: 'Kayseri', caloriesPer100g: 250, proteinG: 30, carbsG: 1, fatG: 14, servingLabel: '5 dilim (30 g)', meals: _b, icon: Icons.local_dining_rounded, category: _kahvalti),
  FoodItem(name: 'Kavurma', brand: 'Kasap', caloriesPer100g: 320, proteinG: 24, carbsG: 0, fatG: 25, servingLabel: '2 yemek kaşığı (50 g)', meals: _b, icon: Icons.local_dining_rounded, category: _kahvalti),
  FoodItem(name: 'Otlu Peynir', brand: 'Van', caloriesPer100g: 290, proteinG: 18, carbsG: 2, fatG: 23, servingLabel: '1 dilim (30 g)', meals: _b, icon: Icons.brunch_dining_rounded, category: _kahvalti),
  FoodItem(name: 'Dil Peyniri', brand: 'Taze', caloriesPer100g: 280, proteinG: 22, carbsG: 2, fatG: 20, servingLabel: '1 dilim (30 g)', meals: _bs, icon: Icons.brunch_dining_rounded, category: _kahvalti),
  FoodItem(name: 'Tahin', brand: 'Çifte kavrulmuş', caloriesPer100g: 595, proteinG: 17, carbsG: 21, fatG: 54, servingLabel: '1 yemek kaşığı (15 g)', meals: _b, icon: Icons.emoji_food_beverage_rounded, category: _kahvalti),
  FoodItem(name: 'Fındık Kreması', brand: 'Kakaolu', caloriesPer100g: 540, proteinG: 6, carbsG: 57, fatG: 31, servingLabel: '1 yemek kaşığı (20 g)', meals: _bs, icon: Icons.emoji_food_beverage_rounded, category: _kahvalti),
  FoodItem(name: 'Müsli', brand: 'Meyveli', caloriesPer100g: 370, proteinG: 10, carbsG: 66, fatG: 6, servingLabel: '1 kase (50 g)', meals: _bs, icon: Icons.grain_rounded, category: _kahvalti),

  // Çorbalar.
  FoodItem(name: 'Düğün Çorbası', brand: 'Ev yapımı', caloriesPer100g: 80, proteinG: 5, carbsG: 5, fatG: 4.5, servingLabel: '1 kase (250 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),
  FoodItem(name: 'Mantar Çorbası', brand: 'Kremalı', caloriesPer100g: 75, proteinG: 2, carbsG: 6, fatG: 5, servingLabel: '1 kase (250 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),
  FoodItem(name: 'Sebze Çorbası', brand: 'Ev yapımı', caloriesPer100g: 45, proteinG: 1.5, carbsG: 7, fatG: 1.5, servingLabel: '1 kase (250 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),
  FoodItem(name: 'Şehriye Çorbası', brand: 'Ev yapımı', caloriesPer100g: 60, proteinG: 2, carbsG: 9, fatG: 2, servingLabel: '1 kase (250 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),
  FoodItem(name: 'Brokoli Çorbası', brand: 'Kremalı', caloriesPer100g: 65, proteinG: 2.5, carbsG: 6, fatG: 3.5, servingLabel: '1 kase (250 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),
  FoodItem(name: 'Beyran', brand: 'Gaziantep', caloriesPer100g: 110, proteinG: 8, carbsG: 9, fatG: 5, servingLabel: '1 kase (350 g)', meals: _ld, icon: Icons.soup_kitchen_rounded, category: _corba),

  // Et yemekleri.
  FoodItem(name: 'Kuzu Pirzola', brand: 'Izgara', caloriesPer100g: 290, proteinG: 25, carbsG: 0, fatG: 21, servingLabel: '4 adet (160 g)', meals: _d, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Beyti Kebap', brand: 'Kebapçı', caloriesPer100g: 240, proteinG: 13, carbsG: 14, fatG: 15, servingLabel: '1 porsiyon (300 g)', meals: _ld, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Ali Nazik', brand: 'Gaziantep', caloriesPer100g: 170, proteinG: 11, carbsG: 6, fatG: 11.5, servingLabel: '1 porsiyon (300 g)', meals: _ld, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Testi Kebabı', brand: 'Kapadokya', caloriesPer100g: 150, proteinG: 13, carbsG: 5, fatG: 8.5, servingLabel: '1 porsiyon (300 g)', meals: _d, icon: Icons.dinner_dining_rounded, category: _et),
  FoodItem(name: 'Çöp Şiş', brand: 'Izgara', caloriesPer100g: 260, proteinG: 24, carbsG: 1, fatG: 18, servingLabel: '4 şiş (120 g)', meals: _ld, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Cağ Kebabı', brand: 'Erzurum', caloriesPer100g: 270, proteinG: 22, carbsG: 2, fatG: 19, servingLabel: '1 şiş (150 g)', meals: _ld, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Izgara Tavuk Kanat', brand: 'Izgara', caloriesPer100g: 250, proteinG: 23, carbsG: 1, fatG: 17, servingLabel: '6 adet (200 g)', meals: _ld, icon: Icons.kebab_dining_rounded, category: _et),
  FoodItem(name: 'Biftek', brand: 'Izgara', caloriesPer100g: 250, proteinG: 26, carbsG: 0, fatG: 16, servingLabel: '1 dilim (200 g)', meals: _d, icon: Icons.dinner_dining_rounded, category: _et),
  FoodItem(name: 'Kadınbudu Köfte', brand: 'Ev yapımı', caloriesPer100g: 265, proteinG: 15, carbsG: 14, fatG: 17, servingLabel: '3 adet (150 g)', meals: _ld, icon: Icons.egg_rounded, category: _et),
  FoodItem(name: 'İzmir Köfte', brand: 'Ev yapımı', caloriesPer100g: 150, proteinG: 9, carbsG: 11, fatG: 8, servingLabel: '1 porsiyon (300 g)', meals: _ld, icon: Icons.dinner_dining_rounded, category: _et),
  FoodItem(name: 'Etli Güveç', brand: 'Ev yapımı', caloriesPer100g: 130, proteinG: 11, carbsG: 6, fatG: 7, servingLabel: '1 güveç (300 g)', meals: _d, icon: Icons.dinner_dining_rounded, category: _et),

  // Balık & deniz ürünleri.
  FoodItem(name: 'Palamut Izgara', brand: 'Balıkçı', caloriesPer100g: 175, proteinG: 24, carbsG: 0, fatG: 8.5, servingLabel: '2 dilim (200 g)', meals: _d, icon: Icons.set_meal_rounded, category: _balik),
  FoodItem(name: 'Midye Dolma', brand: 'Sokak', caloriesPer100g: 180, proteinG: 8, carbsG: 22, fatG: 7, servingLabel: '6 adet (120 g)', meals: _lds, icon: Icons.set_meal_rounded, category: _balik),
  FoodItem(name: 'Kalamar Tava', brand: 'Meyhane', caloriesPer100g: 175, proteinG: 15, carbsG: 8, fatG: 9, servingLabel: '1 porsiyon (150 g)', meals: _d, icon: Icons.set_meal_rounded, category: _balik),
  FoodItem(name: 'Uskumru Izgara', brand: 'Balıkçı', caloriesPer100g: 205, proteinG: 19, carbsG: 0, fatG: 14, servingLabel: '1 adet (200 g)', meals: _d, icon: Icons.set_meal_rounded, category: _balik),
  FoodItem(name: 'Alabalık Izgara', brand: 'Balıkçı', caloriesPer100g: 150, proteinG: 21, carbsG: 0, fatG: 7, servingLabel: '1 adet (250 g)', meals: _ld, icon: Icons.set_meal_rounded, category: _balik),

  // Sebze yemekleri.
  FoodItem(name: 'Zeytinyağlı Pırasa', brand: 'Ev yapımı', caloriesPer100g: 85, proteinG: 1.5, carbsG: 10, fatG: 4.5, servingLabel: '1 porsiyon (200 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Barbunya Pilaki', brand: 'Zeytinyağlı', caloriesPer100g: 120, proteinG: 5.5, carbsG: 15, fatG: 4.5, servingLabel: '1 porsiyon (200 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Kabak Dolması', brand: 'Etli', caloriesPer100g: 110, proteinG: 6, carbsG: 10, fatG: 5, servingLabel: '3 adet (250 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Lahana Sarması', brand: 'Etli', caloriesPer100g: 120, proteinG: 6, carbsG: 12, fatG: 5.5, servingLabel: '6 adet (200 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Bamya', brand: 'Etli', caloriesPer100g: 80, proteinG: 5, carbsG: 7, fatG: 3.5, servingLabel: '1 porsiyon (250 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Bezelye Yemeği', brand: 'Ev yapımı', caloriesPer100g: 95, proteinG: 4.5, carbsG: 12, fatG: 3.5, servingLabel: '1 porsiyon (250 g)', meals: _ld, icon: Icons.eco_rounded, category: _sebze),
  FoodItem(name: 'Şakşuka', brand: 'Meze', caloriesPer100g: 140, proteinG: 1.5, carbsG: 9, fatG: 11, servingLabel: '1 kase (150 g)', meals: _lds, icon: Icons.eco_rounded, category: _sebze),

  // Pilav, makarna & baklagil.
  FoodItem(name: 'Şehriyeli Pirinç Pilavı', brand: 'Ev yapımı', caloriesPer100g: 160, proteinG: 3, carbsG: 30, fatG: 3.5, servingLabel: '1 porsiyon (180 g)', meals: _ld, icon: Icons.rice_bowl_rounded, category: _pilav),
  FoodItem(name: 'İç Pilav', brand: 'Ev yapımı', caloriesPer100g: 190, proteinG: 4, carbsG: 30, fatG: 6, servingLabel: '1 porsiyon (180 g)', meals: _d, icon: Icons.rice_bowl_rounded, category: _pilav),
  FoodItem(name: 'Perde Pilavı', brand: 'Siirt', caloriesPer100g: 240, proteinG: 8, carbsG: 30, fatG: 10, servingLabel: '1 dilim (250 g)', meals: _d, icon: Icons.rice_bowl_rounded, category: _pilav),
  FoodItem(name: 'Domates Soslu Makarna', brand: 'Ev yapımı', caloriesPer100g: 140, proteinG: 5, carbsG: 26, fatG: 2.5, servingLabel: '1 tabak (250 g)', meals: _ld, icon: Icons.ramen_dining_rounded, category: _pilav),
  FoodItem(name: 'Yeşil Mercimek Yemeği', brand: 'Ev yapımı', caloriesPer100g: 110, proteinG: 7, carbsG: 16, fatG: 2.5, servingLabel: '1 porsiyon (250 g)', meals: _ld, icon: Icons.rice_bowl_rounded, category: _pilav),

  // Hamur işleri.
  FoodItem(name: 'Etli Ekmek', brand: 'Konya', caloriesPer100g: 250, proteinG: 12, carbsG: 30, fatG: 9, servingLabel: '1 adet (300 g)', meals: _ld, icon: Icons.local_pizza_rounded, category: _hamur),
  FoodItem(name: 'Çiğ Börek', brand: 'Eskişehir', caloriesPer100g: 320, proteinG: 10, carbsG: 30, fatG: 18, servingLabel: '1 adet (120 g)', meals: _lds, icon: Icons.bakery_dining_rounded, category: _hamur),
  FoodItem(name: 'Ispanaklı Börek', brand: 'Ev yapımı', caloriesPer100g: 230, proteinG: 7, carbsG: 22, fatG: 12.5, servingLabel: '1 dilim (120 g)', meals: {MealType.breakfast, MealType.lunch, MealType.snack}, icon: Icons.bakery_dining_rounded, category: _hamur),
  FoodItem(name: 'Kete', brand: 'Kars', caloriesPer100g: 400, proteinG: 7, carbsG: 45, fatG: 21, servingLabel: '1 adet (80 g)', meals: _bs, icon: Icons.bakery_dining_rounded, category: _hamur),

  // Fast food & sokak lezzetleri.
  FoodItem(name: 'Kokoreç', brand: 'Sokak', caloriesPer100g: 290, proteinG: 15, carbsG: 15, fatG: 19, servingLabel: 'Yarım ekmek (250 g)', meals: _lds, icon: Icons.lunch_dining_rounded, category: _fast),
  FoodItem(name: 'Tantuni', brand: 'Mersin', caloriesPer100g: 210, proteinG: 13, carbsG: 20, fatG: 8.5, servingLabel: '1 dürüm (250 g)', meals: _ld, icon: Icons.lunch_dining_rounded, category: _fast),
  FoodItem(name: 'Islak Hamburger', brand: 'Taksim', caloriesPer100g: 270, proteinG: 11, carbsG: 28, fatG: 13, servingLabel: '1 adet (130 g)', meals: _lds, icon: Icons.lunch_dining_rounded, category: _fast),
  FoodItem(name: 'Kumru', brand: 'İzmir', caloriesPer100g: 280, proteinG: 13, carbsG: 27, fatG: 13, servingLabel: '1 adet (250 g)', meals: _ld, icon: Icons.lunch_dining_rounded, category: _fast),
  FoodItem(name: 'Patates Kızartması', brand: 'Restoran', caloriesPer100g: 312, proteinG: 3.4, carbsG: 41, fatG: 15, servingLabel: '1 porsiyon (150 g)', meals: _lds, icon: Icons.fastfood_rounded, category: _fast),
  FoodItem(name: 'Sosisli Sandviç', brand: 'Büfe', caloriesPer100g: 260, proteinG: 10, carbsG: 25, fatG: 13, servingLabel: '1 adet (150 g)', meals: _lds, icon: Icons.fastfood_rounded, category: _fast),

  // Salata & meze.
  FoodItem(name: 'Roka Salatası', brand: 'Ev yapımı', caloriesPer100g: 70, proteinG: 2.5, carbsG: 4, fatG: 5, servingLabel: '1 kase (150 g)', meals: _ld, icon: Icons.local_florist_rounded, category: _salata),
  FoodItem(name: 'Mevsim Salatası', brand: 'Ev yapımı', caloriesPer100g: 55, proteinG: 1.2, carbsG: 5, fatG: 3.5, servingLabel: '1 kase (200 g)', meals: _ld, icon: Icons.local_florist_rounded, category: _salata),
  FoodItem(name: 'Fava', brand: 'Meze', caloriesPer100g: 150, proteinG: 7, carbsG: 16, fatG: 6.5, servingLabel: '1 dilim (100 g)', meals: _lds, icon: Icons.rice_bowl_rounded, category: _salata),
  FoodItem(name: 'Acılı Ezme', brand: 'Kebapçı', caloriesPer100g: 90, proteinG: 1.5, carbsG: 8, fatG: 6, servingLabel: '3 yemek kaşığı (60 g)', meals: _ld, icon: Icons.local_fire_department_rounded, category: _salata),
  FoodItem(name: 'Semizotu Salatası', brand: 'Yoğurtlu', caloriesPer100g: 60, proteinG: 3, carbsG: 4, fatG: 3.5, servingLabel: '1 kase (150 g)', meals: _ld, icon: Icons.local_florist_rounded, category: _salata),
  FoodItem(name: 'Rus Salatası', brand: 'Meze', caloriesPer100g: 190, proteinG: 3, carbsG: 11, fatG: 15, servingLabel: '3 yemek kaşığı (80 g)', meals: _lds, icon: Icons.local_florist_rounded, category: _salata),
  FoodItem(name: 'Patates Salatası', brand: 'Ev yapımı', caloriesPer100g: 120, proteinG: 2, carbsG: 16, fatG: 5.5, servingLabel: '1 kase (150 g)', meals: _ld, icon: Icons.local_florist_rounded, category: _salata),

  // Tatlılar.
  FoodItem(name: 'Güllaç', brand: 'Ramazan', caloriesPer100g: 160, proteinG: 4, carbsG: 28, fatG: 3.5, servingLabel: '1 dilim (150 g)', meals: _lds, icon: Icons.cake_rounded, category: _tatli),
  FoodItem(name: 'Keşkül', brand: 'Muhallebici', caloriesPer100g: 170, proteinG: 4.5, carbsG: 22, fatG: 7, servingLabel: '1 kase (150 g)', meals: _lds, icon: Icons.icecream_rounded, category: _tatli),
  FoodItem(name: 'Supangle', brand: 'Muhallebici', caloriesPer100g: 180, proteinG: 4, carbsG: 28, fatG: 6, servingLabel: '1 kase (150 g)', meals: _lds, icon: Icons.icecream_rounded, category: _tatli),
  FoodItem(name: 'Tel Kadayıf', brand: 'Tatlıcı', caloriesPer100g: 420, proteinG: 5, carbsG: 55, fatG: 20, servingLabel: '1 dilim (80 g)', meals: _lds, icon: Icons.cake_rounded, category: _tatli),
  FoodItem(name: 'Katmer', brand: 'Gaziantep', caloriesPer100g: 450, proteinG: 9, carbsG: 45, fatG: 26, servingLabel: '1/4 adet (100 g)', meals: {MealType.breakfast, MealType.snack}, icon: Icons.cake_rounded, category: _tatli),
  FoodItem(name: 'Ayva Tatlısı', brand: 'Kaymaklı', caloriesPer100g: 180, proteinG: 0.8, carbsG: 38, fatG: 3, servingLabel: '1/2 ayva (180 g)', meals: _lds, icon: Icons.cake_rounded, category: _tatli),
  FoodItem(name: 'İrmik Helvası', brand: 'Ev yapımı', caloriesPer100g: 330, proteinG: 5, carbsG: 50, fatG: 12, servingLabel: '1 kase (100 g)', meals: _lds, icon: Icons.cookie_rounded, category: _tatli),
  FoodItem(name: 'Cheesecake', brand: 'Pastane', caloriesPer100g: 320, proteinG: 5.5, carbsG: 26, fatG: 22, servingLabel: '1 dilim (120 g)', meals: _lds, icon: Icons.cake_rounded, category: _tatli),

  // İçecekler.
  FoodItem(name: 'Kefir', brand: 'Sade', caloriesPer100g: 55, proteinG: 3.3, carbsG: 4.5, fatG: 2.5, servingLabel: '1 bardak (200 ml)', meals: _all, icon: Icons.local_drink_rounded, category: _icecek),
  FoodItem(name: 'Limonata', brand: 'Ev yapımı', caloriesPer100g: 45, proteinG: 0.1, carbsG: 11, fatG: 0, servingLabel: '1 bardak (250 ml)', meals: {MealType.lunch, MealType.snack}, icon: Icons.local_drink_rounded, category: _icecek),
  FoodItem(name: 'Salep', brand: 'Tarçınlı', caloriesPer100g: 95, proteinG: 3, carbsG: 16, fatG: 2.5, servingLabel: '1 fincan (200 ml)', meals: {MealType.snack}, icon: Icons.local_cafe_rounded, category: _icecek),
  FoodItem(name: 'Boza', brand: 'Leblebili', caloriesPer100g: 110, proteinG: 1, carbsG: 25, fatG: 0.5, servingLabel: '1 bardak (200 ml)', meals: {MealType.snack}, icon: Icons.local_drink_rounded, category: _icecek),
  FoodItem(name: 'Maden Suyu', brand: 'Sade', caloriesPer100g: 0, proteinG: 0, carbsG: 0, fatG: 0, servingLabel: '1 şişe (200 ml)', meals: _all, icon: Icons.local_drink_rounded, category: _icecek),

  // Meyve & atıştırmalık.
  FoodItem(name: 'Elma', brand: 'Taze', caloriesPer100g: 52, proteinG: 0.3, carbsG: 14, fatG: 0.2, servingLabel: '1 adet (150 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Portakal', brand: 'Taze', caloriesPer100g: 47, proteinG: 0.9, carbsG: 12, fatG: 0.1, servingLabel: '1 adet (180 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Çilek', brand: 'Taze', caloriesPer100g: 32, proteinG: 0.7, carbsG: 7.7, fatG: 0.3, servingLabel: '1 kase (150 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Karpuz', brand: 'Taze', caloriesPer100g: 30, proteinG: 0.6, carbsG: 7.6, fatG: 0.2, servingLabel: '1 dilim (300 g)', meals: _lds, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Üzüm', brand: 'Taze', caloriesPer100g: 69, proteinG: 0.7, carbsG: 18, fatG: 0.2, servingLabel: '1 salkım (150 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Kuru İncir', brand: 'Aydın', caloriesPer100g: 249, proteinG: 3.3, carbsG: 64, fatG: 0.9, servingLabel: '3 adet (40 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Fındık', brand: 'Giresun', caloriesPer100g: 628, proteinG: 15, carbsG: 17, fatG: 61, servingLabel: '1 avuç (30 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Badem', brand: 'Çiğ', caloriesPer100g: 579, proteinG: 21, carbsG: 22, fatG: 50, servingLabel: '1 avuç (30 g)', meals: _bs, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Leblebi', brand: 'Sarı', caloriesPer100g: 380, proteinG: 22, carbsG: 58, fatG: 6, servingLabel: '1 avuç (40 g)', meals: {MealType.snack}, icon: Icons.spa_rounded, category: _meyve),
  FoodItem(name: 'Kabak Çekirdeği', brand: 'Kavrulmuş', caloriesPer100g: 559, proteinG: 30, carbsG: 11, fatG: 49, servingLabel: '1 avuç (30 g)', meals: {MealType.snack}, icon: Icons.spa_rounded, category: _meyve),
];
