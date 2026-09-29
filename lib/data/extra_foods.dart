import 'package:flutter/material.dart';

import 'models.dart';

const _breakfast = {MealType.breakfast};
const _lunch = {MealType.lunch};
const _dinner = {MealType.dinner};
const _breakfastSnack = {MealType.breakfast, MealType.snack};
const _breakfastLunch = {MealType.breakfast, MealType.lunch};
const _lunchDinner = {MealType.lunch, MealType.dinner};
const _lunchDinnerSnack = {MealType.lunch, MealType.dinner, MealType.snack};

/// Additional Turkish (and a few international) dishes that widen the
/// breakfast / lunch / dinner catalog. Values are approximate per-100 g
/// figures for typical home-style preparations.
const extraFoods = <FoodItem>[
  // Kahvaltı (breakfast).
  FoodItem(name: 'Sahanda Yumurta', brand: 'Ev yapımı', caloriesPer100g: 196, proteinG: 13.6, carbsG: 0.8, fatG: 15, servingLabel: '2 yumurta (110 g)', meals: _breakfast, icon: Icons.egg_alt_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Sucuklu Yumurta', brand: 'Ev yapımı', caloriesPer100g: 265, proteinG: 15, carbsG: 1.2, fatG: 22, servingLabel: '1 porsiyon (150 g)', meals: _breakfast, icon: Icons.egg_alt_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Pastırmalı Yumurta', brand: 'Ev yapımı', caloriesPer100g: 230, proteinG: 18, carbsG: 1, fatG: 17, servingLabel: '1 porsiyon (140 g)', meals: _breakfast, icon: Icons.egg_alt_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Omlet', brand: 'Ev yapımı', caloriesPer100g: 154, proteinG: 11, carbsG: 0.6, fatG: 12, servingLabel: '2 yumurtalı (120 g)', meals: _breakfast, icon: Icons.egg_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Çılbır', brand: 'Ev yapımı', caloriesPer100g: 170, proteinG: 9.5, carbsG: 4, fatG: 13, servingLabel: '1 porsiyon (200 g)', meals: _breakfast, icon: Icons.egg_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Kuymak', brand: 'Karadeniz usulü', caloriesPer100g: 330, proteinG: 11, carbsG: 18, fatG: 24, servingLabel: '1 porsiyon (150 g)', meals: _breakfast, icon: Icons.soup_kitchen_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Sigara Böreği', brand: 'Ev yapımı', caloriesPer100g: 310, proteinG: 9, carbsG: 28, fatG: 18, servingLabel: '3 adet (90 g)', meals: _breakfastSnack, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Su Böreği', brand: 'Ev yapımı', caloriesPer100g: 260, proteinG: 10, carbsG: 25, fatG: 13, servingLabel: '1 dilim (120 g)', meals: _breakfastLunch, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Kol Böreği', brand: 'Ev yapımı', caloriesPer100g: 295, proteinG: 8.5, carbsG: 30, fatG: 15.5, servingLabel: '1 dilim (100 g)', meals: _breakfastSnack, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Gözleme (Peynirli)', brand: 'Ev yapımı', caloriesPer100g: 240, proteinG: 9, carbsG: 30, fatG: 9, servingLabel: '1 adet (200 g)', meals: _breakfastLunch, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Pişi', brand: 'Ev yapımı', caloriesPer100g: 345, proteinG: 7, carbsG: 45, fatG: 15, servingLabel: '2 adet (80 g)', meals: _breakfast, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Poğaça', brand: 'Fırın', caloriesPer100g: 370, proteinG: 8, carbsG: 42, fatG: 19, servingLabel: '1 adet (70 g)', meals: _breakfastSnack, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Açma', brand: 'Fırın', caloriesPer100g: 390, proteinG: 7.5, carbsG: 45, fatG: 20, servingLabel: '1 adet (80 g)', meals: _breakfastSnack, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Bazlama', brand: 'Ev yapımı', caloriesPer100g: 265, proteinG: 8.5, carbsG: 52, fatG: 2.5, servingLabel: '1/2 adet (100 g)', meals: _breakfast, icon: Icons.breakfast_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Kaşarlı Tost', brand: 'Kafe', caloriesPer100g: 290, proteinG: 13, carbsG: 30, fatG: 13, servingLabel: '1 adet (150 g)', meals: _breakfastSnack, icon: Icons.breakfast_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Kaymak', brand: 'Manda kaymağı', caloriesPer100g: 560, proteinG: 2.5, carbsG: 3, fatG: 60, servingLabel: '1 yemek kaşığı (20 g)', meals: _breakfast, icon: Icons.icecream_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Tahin Pekmez', brand: 'Ev yapımı', caloriesPer100g: 450, proteinG: 8.5, carbsG: 48, fatG: 26, servingLabel: '2 yemek kaşığı (40 g)', meals: _breakfast, icon: Icons.emoji_food_beverage_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Üzüm Pekmezi', brand: 'Doğal', caloriesPer100g: 293, proteinG: 0.3, carbsG: 73, fatG: 0.1, servingLabel: '1 yemek kaşığı (20 g)', meals: _breakfast, icon: Icons.emoji_food_beverage_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Lor Peyniri', brand: 'Taze', caloriesPer100g: 98, proteinG: 11, carbsG: 3.4, fatG: 4.3, servingLabel: '3 yemek kaşığı (60 g)', meals: _breakfast, icon: Icons.brunch_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Tulum Peyniri', brand: 'Erzincan', caloriesPer100g: 360, proteinG: 24, carbsG: 1.5, fatG: 29, servingLabel: '1 dilim (30 g)', meals: _breakfast, icon: Icons.brunch_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Hellim Peyniri (Izgara)', brand: 'Kıbrıs', caloriesPer100g: 320, proteinG: 22, carbsG: 2, fatG: 25, servingLabel: '2 dilim (60 g)', meals: _breakfast, icon: Icons.brunch_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Labne', brand: 'Krem peynir', caloriesPer100g: 230, proteinG: 6, carbsG: 4, fatG: 21, servingLabel: '1 yemek kaşığı (30 g)', meals: _breakfast, icon: Icons.brunch_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Yeşil Zeytin', brand: 'Kırma', caloriesPer100g: 145, proteinG: 1, carbsG: 3.8, fatG: 15, servingLabel: '10 adet (40 g)', meals: _breakfast, icon: Icons.grain_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Acuka', brand: 'Ev yapımı', caloriesPer100g: 280, proteinG: 5, carbsG: 16, fatG: 22, servingLabel: '2 yemek kaşığı (40 g)', meals: _breakfast, icon: Icons.local_fire_department_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Ceviz', brand: 'Kabuksuz', caloriesPer100g: 654, proteinG: 15, carbsG: 14, fatG: 65, servingLabel: '3 adet (15 g)', meals: _breakfastSnack, icon: Icons.spa_rounded, category: FoodCategory.atistirmalik),
  FoodItem(name: 'Fıstık Ezmesi', brand: 'Şekersiz', caloriesPer100g: 588, proteinG: 25, carbsG: 20, fatG: 50, servingLabel: '1 yemek kaşığı (16 g)', meals: _breakfastSnack, icon: Icons.emoji_food_beverage_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Avokado', brand: 'Taze', caloriesPer100g: 160, proteinG: 2, carbsG: 8.5, fatG: 14.7, servingLabel: '1/2 adet (70 g)', meals: _breakfastSnack, icon: Icons.eco_rounded, category: FoodCategory.atistirmalik),
  FoodItem(name: 'Muz', brand: 'Taze', caloriesPer100g: 89, proteinG: 1.1, carbsG: 23, fatG: 0.3, servingLabel: '1 adet (120 g)', meals: _breakfastSnack, icon: Icons.eco_rounded, category: FoodCategory.atistirmalik),
  FoodItem(name: 'Portakal Suyu', brand: 'Taze sıkılmış', caloriesPer100g: 45, proteinG: 0.7, carbsG: 10.4, fatG: 0.2, servingLabel: '1 bardak (200 ml)', meals: _breakfastSnack, icon: Icons.local_drink_rounded, category: FoodCategory.icecek),
  FoodItem(name: 'Granola', brand: 'Fırınlanmış', caloriesPer100g: 471, proteinG: 10, carbsG: 64, fatG: 20, servingLabel: '1 kase (50 g)', meals: _breakfastSnack, icon: Icons.grain_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Pankek', brand: 'Ev yapımı', caloriesPer100g: 227, proteinG: 6.4, carbsG: 28, fatG: 9.7, servingLabel: '3 adet (120 g)', meals: _breakfast, icon: Icons.breakfast_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Krep', brand: 'Ev yapımı', caloriesPer100g: 225, proteinG: 6, carbsG: 28, fatG: 10, servingLabel: '2 adet (100 g)', meals: _breakfast, icon: Icons.breakfast_dining_rounded, category: FoodCategory.kahvaltilik),
  FoodItem(name: 'Kruvasan', brand: 'Fırın', caloriesPer100g: 406, proteinG: 8.2, carbsG: 45, fatG: 21, servingLabel: '1 adet (60 g)', meals: _breakfastSnack, icon: Icons.bakery_dining_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Türk Kahvesi', brand: 'Sade', caloriesPer100g: 12, proteinG: 0.2, carbsG: 1.9, fatG: 0.4, servingLabel: '1 fincan (70 ml)', meals: _breakfastSnack, icon: Icons.local_cafe_rounded, category: FoodCategory.icecek),

  // Çorbalar (soups).
  FoodItem(name: 'Ezogelin Çorbası', brand: 'Ev yapımı', caloriesPer100g: 85, proteinG: 4, carbsG: 13, fatG: 2, servingLabel: '1 kase (250 g)', meals: _lunchDinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),
  FoodItem(name: 'Yayla Çorbası', brand: 'Ev yapımı', caloriesPer100g: 70, proteinG: 3, carbsG: 8, fatG: 3, servingLabel: '1 kase (250 g)', meals: _lunchDinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),
  FoodItem(name: 'Tarhana Çorbası', brand: 'Ev yapımı', caloriesPer100g: 75, proteinG: 3, carbsG: 11, fatG: 2, servingLabel: '1 kase (250 g)', meals: _lunchDinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),
  FoodItem(name: 'Domates Çorbası', brand: 'Ev yapımı', caloriesPer100g: 60, proteinG: 1.5, carbsG: 8, fatG: 2.5, servingLabel: '1 kase (250 g)', meals: _lunchDinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),
  FoodItem(name: 'Tavuk Suyu Çorbası', brand: 'Ev yapımı', caloriesPer100g: 55, proteinG: 4, carbsG: 6, fatG: 1.5, servingLabel: '1 kase (250 g)', meals: _lunchDinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),
  FoodItem(name: 'İşkembe Çorbası', brand: 'Çorbacı', caloriesPer100g: 90, proteinG: 7, carbsG: 4, fatG: 5, servingLabel: '1 kase (300 g)', meals: _dinner, icon: Icons.soup_kitchen_rounded, category: FoodCategory.corba),

  // Et & tavuk (meat & chicken).
  FoodItem(name: 'Adana Kebap', brand: 'Kebapçı', caloriesPer100g: 280, proteinG: 17, carbsG: 2, fatG: 23, servingLabel: '1 şiş (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Urfa Kebap', brand: 'Kebapçı', caloriesPer100g: 270, proteinG: 17, carbsG: 2, fatG: 21.5, servingLabel: '1 şiş (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'İskender Kebap', brand: 'Kebapçı', caloriesPer100g: 195, proteinG: 11, carbsG: 12, fatG: 11.5, servingLabel: '1 porsiyon (350 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Tavuk Şiş', brand: 'Izgara', caloriesPer100g: 175, proteinG: 26, carbsG: 2, fatG: 7, servingLabel: '1 şiş (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Kuzu Şiş', brand: 'Izgara', caloriesPer100g: 245, proteinG: 24, carbsG: 1, fatG: 16, servingLabel: '1 şiş (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Tavuk Döner Dürüm', brand: 'Dönerci', caloriesPer100g: 215, proteinG: 13, carbsG: 22, fatG: 8.5, servingLabel: '1 adet (250 g)', meals: _lunch, icon: Icons.lunch_dining_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Et Döner', brand: 'Dönerci', caloriesPer100g: 250, proteinG: 18, carbsG: 3, fatG: 18.5, servingLabel: '1 porsiyon (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Tas Kebabı', brand: 'Ev yapımı', caloriesPer100g: 150, proteinG: 13, carbsG: 5, fatG: 9, servingLabel: '1 porsiyon (250 g)', meals: _lunchDinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Orman Kebabı', brand: 'Ev yapımı', caloriesPer100g: 135, proteinG: 11, carbsG: 6, fatG: 7.5, servingLabel: '1 porsiyon (250 g)', meals: _lunchDinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Kuzu Tandır', brand: 'Lokanta', caloriesPer100g: 250, proteinG: 25, carbsG: 0, fatG: 16.5, servingLabel: '1 porsiyon (200 g)', meals: _dinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'Hünkar Beğendi', brand: 'Lokanta', caloriesPer100g: 165, proteinG: 10, carbsG: 7, fatG: 11, servingLabel: '1 porsiyon (300 g)', meals: _dinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'İnegöl Köfte', brand: 'Köfteci', caloriesPer100g: 260, proteinG: 18, carbsG: 4, fatG: 19, servingLabel: '6 adet (150 g)', meals: _lunchDinner, icon: Icons.kebab_dining_rounded, category: FoodCategory.et),
  FoodItem(name: 'İçli Köfte', brand: 'Ev yapımı', caloriesPer100g: 250, proteinG: 10, carbsG: 25, fatG: 12, servingLabel: '2 adet (120 g)', meals: _lunchDinnerSnack, icon: Icons.egg_rounded, category: FoodCategory.et),
  FoodItem(name: 'Tavuk Pilav', brand: 'Seyyar', caloriesPer100g: 170, proteinG: 9, carbsG: 22, fatG: 5, servingLabel: '1 porsiyon (300 g)', meals: _lunch, icon: Icons.rice_bowl_rounded, category: FoodCategory.pilav),
  FoodItem(name: 'Fırında Tavuk Baget', brand: 'Ev yapımı', caloriesPer100g: 190, proteinG: 24, carbsG: 0.5, fatG: 10, servingLabel: '2 adet (200 g)', meals: _lunchDinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.et),

  // Hamur işi & fast food.
  FoodItem(name: 'Kıymalı Pide', brand: 'Pideci', caloriesPer100g: 245, proteinG: 11, carbsG: 30, fatG: 9, servingLabel: '1 adet (300 g)', meals: _lunchDinner, icon: Icons.local_pizza_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Kaşarlı Pide', brand: 'Pideci', caloriesPer100g: 275, proteinG: 12, carbsG: 32, fatG: 11, servingLabel: '1 adet (280 g)', meals: _lunchDinner, icon: Icons.local_pizza_rounded, category: FoodCategory.hamurIsi),
  FoodItem(name: 'Çiğ Köfte', brand: 'Etsiz', caloriesPer100g: 180, proteinG: 5, carbsG: 32, fatG: 3.5, servingLabel: '1 dürüm (200 g)', meals: _lunchDinnerSnack, icon: Icons.lunch_dining_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Balık Ekmek', brand: 'Eminönü', caloriesPer100g: 210, proteinG: 12, carbsG: 20, fatG: 9, servingLabel: '1 adet (300 g)', meals: _lunch, icon: Icons.set_meal_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Kumpir', brand: 'Ortaköy', caloriesPer100g: 165, proteinG: 5, carbsG: 20, fatG: 7.5, servingLabel: '1 adet (450 g)', meals: _lunchDinner, icon: Icons.fastfood_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Hamburger', brand: 'Restoran', caloriesPer100g: 254, proteinG: 13, carbsG: 24, fatG: 12, servingLabel: '1 adet (220 g)', meals: _lunchDinner, icon: Icons.lunch_dining_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Pizza (Margherita)', brand: 'Restoran', caloriesPer100g: 250, proteinG: 11, carbsG: 31, fatG: 9, servingLabel: '2 dilim (200 g)', meals: _lunchDinner, icon: Icons.local_pizza_rounded, category: FoodCategory.fastFood),
  FoodItem(name: 'Spagetti Bolonez', brand: 'Ev yapımı', caloriesPer100g: 160, proteinG: 8, carbsG: 20, fatG: 5, servingLabel: '1 tabak (300 g)', meals: _lunchDinner, icon: Icons.ramen_dining_rounded, category: FoodCategory.pilav),
  FoodItem(name: 'Fırın Makarna', brand: 'Ev yapımı', caloriesPer100g: 190, proteinG: 8, carbsG: 22, fatG: 8, servingLabel: '1 dilim (250 g)', meals: _lunchDinner, icon: Icons.ramen_dining_rounded, category: FoodCategory.pilav),
  FoodItem(name: 'Erişte', brand: 'Ev yapımı', caloriesPer100g: 175, proteinG: 6, carbsG: 30, fatG: 3.5, servingLabel: '1 tabak (200 g)', meals: _lunchDinner, icon: Icons.ramen_dining_rounded, category: FoodCategory.pilav),

  // Balık (fish).
  FoodItem(name: 'Hamsi Tava', brand: 'Karadeniz', caloriesPer100g: 230, proteinG: 19, carbsG: 8, fatG: 14, servingLabel: '1 porsiyon (200 g)', meals: _lunchDinner, icon: Icons.set_meal_rounded, category: FoodCategory.balik),
  FoodItem(name: 'Levrek Izgara', brand: 'Balıkçı', caloriesPer100g: 124, proteinG: 24, carbsG: 0, fatG: 2.6, servingLabel: '1 adet (250 g)', meals: _dinner, icon: Icons.set_meal_rounded, category: FoodCategory.balik),
  FoodItem(name: 'Çipura Izgara', brand: 'Balıkçı', caloriesPer100g: 135, proteinG: 23, carbsG: 0, fatG: 4.5, servingLabel: '1 adet (250 g)', meals: _dinner, icon: Icons.set_meal_rounded, category: FoodCategory.balik),
  FoodItem(name: 'Karides Güveç', brand: 'Meyhane', caloriesPer100g: 160, proteinG: 16, carbsG: 4, fatG: 9, servingLabel: '1 güveç (200 g)', meals: _dinner, icon: Icons.set_meal_rounded, category: FoodCategory.balik),

  // Sebze & zeytinyağlı (vegetables & olive-oil dishes).
  FoodItem(name: 'Yaprak Sarma', brand: 'Zeytinyağlı', caloriesPer100g: 175, proteinG: 3, carbsG: 22, fatG: 8.5, servingLabel: '6 adet (150 g)', meals: _lunchDinnerSnack, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Biber Dolması', brand: 'Etli', caloriesPer100g: 150, proteinG: 7, carbsG: 14, fatG: 7.5, servingLabel: '2 adet (250 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'İmam Bayıldı', brand: 'Zeytinyağlı', caloriesPer100g: 130, proteinG: 1.5, carbsG: 9, fatG: 10, servingLabel: '1 adet (200 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Musakka', brand: 'Ev yapımı', caloriesPer100g: 140, proteinG: 7, carbsG: 7, fatG: 9.5, servingLabel: '1 porsiyon (250 g)', meals: _dinner, icon: Icons.dinner_dining_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Türlü', brand: 'Ev yapımı', caloriesPer100g: 90, proteinG: 4, carbsG: 8, fatG: 5, servingLabel: '1 porsiyon (250 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Zeytinyağlı Taze Fasulye', brand: 'Ev yapımı', caloriesPer100g: 85, proteinG: 2, carbsG: 8, fatG: 5.5, servingLabel: '1 porsiyon (200 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Nohut Yemeği', brand: 'Ev yapımı', caloriesPer100g: 135, proteinG: 7, carbsG: 17, fatG: 4.5, servingLabel: '1 porsiyon (250 g)', meals: _lunchDinner, icon: Icons.rice_bowl_rounded, category: FoodCategory.pilav),
  FoodItem(name: 'Ispanak Yemeği', brand: 'Ev yapımı', caloriesPer100g: 70, proteinG: 4, carbsG: 5, fatG: 4, servingLabel: '1 porsiyon (250 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Mücver', brand: 'Ev yapımı', caloriesPer100g: 190, proteinG: 6, carbsG: 14, fatG: 12.5, servingLabel: '3 adet (150 g)', meals: _lunchDinnerSnack, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Zeytinyağlı Enginar', brand: 'Ev yapımı', caloriesPer100g: 95, proteinG: 2.5, carbsG: 10, fatG: 5.5, servingLabel: '2 adet (200 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.sebze),
  FoodItem(name: 'Bulgur Pilavı', brand: 'Ev yapımı', caloriesPer100g: 150, proteinG: 4, carbsG: 27, fatG: 3, servingLabel: '1 porsiyon (180 g)', meals: _lunchDinner, icon: Icons.rice_bowl_rounded, category: FoodCategory.pilav),
  FoodItem(name: 'Mercimek Köftesi', brand: 'Ev yapımı', caloriesPer100g: 160, proteinG: 7, carbsG: 26, fatG: 3.5, servingLabel: '5 adet (150 g)', meals: _lunchDinnerSnack, icon: Icons.rice_bowl_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Kısır', brand: 'Ev yapımı', caloriesPer100g: 155, proteinG: 3.5, carbsG: 24, fatG: 5, servingLabel: '1 porsiyon (150 g)', meals: _lunchDinnerSnack, icon: Icons.rice_bowl_rounded, category: FoodCategory.salata),

  // Salata & meze.
  FoodItem(name: 'Piyaz', brand: 'Ev yapımı', caloriesPer100g: 130, proteinG: 6, carbsG: 15, fatG: 5, servingLabel: '1 kase (200 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Gavurdağı Salatası', brand: 'Kebapçı', caloriesPer100g: 120, proteinG: 2.5, carbsG: 6, fatG: 10, servingLabel: '1 kase (200 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Sezar Salata', brand: 'Restoran', caloriesPer100g: 145, proteinG: 8, carbsG: 7, fatG: 10, servingLabel: '1 tabak (250 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Ton Balıklı Salata', brand: 'Ev yapımı', caloriesPer100g: 110, proteinG: 11, carbsG: 4, fatG: 5.5, servingLabel: '1 tabak (250 g)', meals: _lunchDinner, icon: Icons.eco_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Cacık', brand: 'Ev yapımı', caloriesPer100g: 55, proteinG: 3, carbsG: 4, fatG: 3, servingLabel: '1 kase (200 g)', meals: _lunchDinnerSnack, icon: Icons.local_drink_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Haydari', brand: 'Meze', caloriesPer100g: 160, proteinG: 6, carbsG: 4, fatG: 13, servingLabel: '2 yemek kaşığı (60 g)', meals: _dinner, icon: Icons.local_drink_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Humus', brand: 'Meze', caloriesPer100g: 166, proteinG: 8, carbsG: 14, fatG: 9.6, servingLabel: '3 yemek kaşığı (60 g)', meals: _lunchDinnerSnack, icon: Icons.rice_bowl_rounded, category: FoodCategory.salata),
  FoodItem(name: 'Patlıcan Salatası', brand: 'Meze', caloriesPer100g: 95, proteinG: 1.5, carbsG: 7, fatG: 7, servingLabel: '1 kase (150 g)', meals: _dinner, icon: Icons.eco_rounded, category: FoodCategory.salata),

  // Tatlılar (desserts).
  FoodItem(name: 'Baklava', brand: 'Fıstıklı', caloriesPer100g: 428, proteinG: 7, carbsG: 45, fatG: 25, servingLabel: '2 dilim (60 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Künefe', brand: 'Hatay', caloriesPer100g: 330, proteinG: 8, carbsG: 38, fatG: 16, servingLabel: '1 porsiyon (150 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Sütlaç', brand: 'Fırın', caloriesPer100g: 130, proteinG: 3.5, carbsG: 22, fatG: 3, servingLabel: '1 kase (180 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Kazandibi', brand: 'Muhallebici', caloriesPer100g: 150, proteinG: 4, carbsG: 24, fatG: 4, servingLabel: '1 dilim (150 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Tavuk Göğsü Tatlısı', brand: 'Muhallebici', caloriesPer100g: 140, proteinG: 5, carbsG: 22, fatG: 3.5, servingLabel: '1 dilim (150 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Muhallebi', brand: 'Ev yapımı', caloriesPer100g: 120, proteinG: 3.5, carbsG: 20, fatG: 3, servingLabel: '1 kase (150 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Revani', brand: 'Ev yapımı', caloriesPer100g: 320, proteinG: 5, carbsG: 55, fatG: 9, servingLabel: '1 dilim (80 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Şekerpare', brand: 'Ev yapımı', caloriesPer100g: 400, proteinG: 5, carbsG: 60, fatG: 16, servingLabel: '2 adet (60 g)', meals: _lunchDinnerSnack, icon: Icons.cookie_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Tulumba Tatlısı', brand: 'Tatlıcı', caloriesPer100g: 380, proteinG: 3.5, carbsG: 55, fatG: 16, servingLabel: '3 adet (75 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Lokma', brand: 'Tatlıcı', caloriesPer100g: 370, proteinG: 4, carbsG: 52, fatG: 16, servingLabel: '6 adet (70 g)', meals: _lunchDinnerSnack, icon: Icons.cookie_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Aşure', brand: 'Ev yapımı', caloriesPer100g: 150, proteinG: 3, carbsG: 32, fatG: 1.5, servingLabel: '1 kase (200 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Kabak Tatlısı', brand: 'Cevizli', caloriesPer100g: 190, proteinG: 1.5, carbsG: 40, fatG: 3, servingLabel: '2 dilim (150 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Trileçe', brand: 'Pastane', caloriesPer100g: 250, proteinG: 5, carbsG: 35, fatG: 10, servingLabel: '1 dilim (120 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Profiterol', brand: 'Pastane', caloriesPer100g: 330, proteinG: 5, carbsG: 30, fatG: 21, servingLabel: '1 porsiyon (120 g)', meals: _lunchDinnerSnack, icon: Icons.cake_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Maraş Dondurması', brand: 'Kaymaklı', caloriesPer100g: 210, proteinG: 4, carbsG: 28, fatG: 9, servingLabel: '2 top (100 g)', meals: _lunchDinnerSnack, icon: Icons.icecream_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Tahin Helvası', brand: 'Sade', caloriesPer100g: 516, proteinG: 12, carbsG: 55, fatG: 29, servingLabel: '1 dilim (40 g)', meals: _breakfastSnack, icon: Icons.cookie_rounded, category: FoodCategory.tatli),
  FoodItem(name: 'Lokum', brand: 'Güllü', caloriesPer100g: 350, proteinG: 0.2, carbsG: 88, fatG: 0.2, servingLabel: '3 adet (30 g)', meals: _breakfastSnack, icon: Icons.cookie_rounded, category: FoodCategory.tatli),

  // İçecekler (drinks).
  FoodItem(name: 'Ayran', brand: 'Ev yapımı', caloriesPer100g: 38, proteinG: 1.8, carbsG: 2.6, fatG: 2, servingLabel: '1 bardak (200 ml)', meals: _lunchDinnerSnack, icon: Icons.local_drink_rounded, category: FoodCategory.icecek),
  FoodItem(name: 'Şalgam Suyu', brand: 'Acılı', caloriesPer100g: 10, proteinG: 0.3, carbsG: 2, fatG: 0, servingLabel: '1 bardak (200 ml)', meals: _lunchDinner, icon: Icons.local_drink_rounded, category: FoodCategory.icecek),
];
