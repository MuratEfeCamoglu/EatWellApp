/// Shared mock-data model classes used across Denge's screens.
/// This app has no backend; all data is static/local mock data that
/// mirrors the numbers shown in the design.
library;

import 'package:flutter/material.dart' show IconData, Icons;

import 'db/date_key.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initials,
    required this.email,
    required this.streakDays,
    required this.calorieGoal,
    required this.proteinGoalG,
    required this.carbsGoalG,
    required this.fatGoalG,
    required this.heightCm,
    required this.weightKg,
    required this.goalWeightKg,
  });

  final String name;
  final String initials;
  final String email;
  final int streakDays;
  final int calorieGoal;
  final int proteinGoalG;
  final int carbsGoalG;
  final int fatGoalG;
  final double heightCm;
  final double weightKg;
  final double goalWeightKg;

  UserProfile copyWith({
    String? name,
    String? initials,
    String? email,
    double? weightKg,
    int? streakDays,
    int? calorieGoal,
    int? proteinGoalG,
    int? carbsGoalG,
    int? fatGoalG,
    double? heightCm,
    double? goalWeightKg,
  }) {
    return UserProfile(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      streakDays: streakDays ?? this.streakDays,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoalG: proteinGoalG ?? this.proteinGoalG,
      carbsGoalG: carbsGoalG ?? this.carbsGoalG,
      fatGoalG: fatGoalG ?? this.fatGoalG,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
    );
  }

  /// Placeholder shown before onboarding has produced a real profile —
  /// no name/photo/goals invented on the user's behalf.
  static const empty = UserProfile(
    name: '',
    initials: '',
    email: '',
    streakDays: 0,
    calorieGoal: 0,
    proteinGoalG: 0,
    carbsGoalG: 0,
    fatGoalG: 0,
    heightCm: 0,
    weightKg: 0,
    goalWeightKg: 0,
  );
}

enum MealType { breakfast, lunch, dinner, snack }

/// Dish family used to group the food catalog into browsable sections.
/// Declaration order is the order sections appear in.
enum FoodCategory {
  kahvaltilik('Kahvaltılık', Icons.egg_alt_rounded),
  corba('Çorbalar', Icons.soup_kitchen_rounded),
  et('Et Yemekleri', Icons.kebab_dining_rounded),
  balik('Balık & Deniz Ürünleri', Icons.set_meal_rounded),
  sebze('Sebze Yemekleri', Icons.eco_rounded),
  pilav('Pilav, Makarna & Baklagil', Icons.rice_bowl_rounded),
  hamurIsi('Hamur İşleri & Ekmek', Icons.bakery_dining_rounded),
  fastFood('Fast Food & Sokak Lezzetleri', Icons.lunch_dining_rounded),
  salata('Salata & Meze', Icons.local_florist_rounded),
  tatli('Tatlılar', Icons.cake_rounded),
  icecek('İçecekler', Icons.local_cafe_rounded),
  atistirmalik('Meyve & Atıştırmalık', Icons.spa_rounded);

  const FoodCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class MealEntry {
  const MealEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.calories,
    this.logged = true,
  });

  final MealType type;
  final String title;
  final String description;
  final int calories;
  final bool logged;

  MealEntry copyWith({
    String? title,
    String? description,
    int? calories,
    bool? logged,
  }) {
    return MealEntry(
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      logged: logged ?? this.logged,
    );
  }
}

class FoodItem {
  const FoodItem({
    required this.name,
    required this.brand,
    required this.caloriesPer100g,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.servingLabel = '100 g',
    this.meals = const {
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snack,
    },
    this.icon = Icons.restaurant_rounded,
    this.category = FoodCategory.atistirmalik,
  });

  final String name;
  final String brand;
  final int caloriesPer100g;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String servingLabel;

  /// Which meals this item makes sense for, so e.g. searching "kahvaltı"
  /// only surfaces breakfast-appropriate foods instead of the whole catalog.
  final Set<MealType> meals;

  /// A food-specific icon (rather than one cycled arbitrarily by list
  /// position) so visually similar items are recognizable at a glance.
  final IconData icon;

  /// Which catalog section this food is listed under.
  final FoodCategory category;

  /// Bundled photo for this food, derived from its name. Callers fall back
  /// to [icon] when no such asset exists (e.g. barcode-catalog products).
  String get imageAsset => 'assets/foods/${foodImageSlug(name)}.jpg';
}

/// ASCII file-name slug for a food name, e.g. 'Çılbır' -> 'cilbir'.
/// Kept in sync with tool/fetch_food_images.py.
String foodImageSlug(String name) {
  const map = {
    'ç': 'c', 'Ç': 'c', 'ğ': 'g', 'Ğ': 'g', 'ı': 'i', 'I': 'i', 'İ': 'i',
    'ö': 'o', 'Ö': 'o', 'ş': 's', 'Ş': 's', 'ü': 'u', 'Ü': 'u',
  };
  final ascii = name.split('').map((c) => map[c] ?? c).join().toLowerCase();
  return ascii.replaceAll(RegExp('[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
}

enum RecipeDifficulty {
  kolay('Kolay'),
  orta('Orta'),
  zor('Zor');

  const RecipeDifficulty(this.label);
  final String label;
}

class Recipe {
  const Recipe({
    required this.title,
    required this.description,
    required this.minutes,
    required this.calories,
    required this.tag,
    required this.ingredients,
    required this.steps,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.servings = 2,
    this.difficulty = RecipeDifficulty.kolay,
  });

  final String title;
  final String description;
  final int minutes;

  /// Calories and macros are per serving.
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  final String tag;
  final int servings;
  final RecipeDifficulty difficulty;
  final List<String> ingredients;
  final List<String> steps;

  /// Bundled 4:3 photo, derived from the title (see tool/fetch_food_images.py).
  String get imageAsset => 'assets/recipes/${foodImageSlug(title)}.jpg';

  /// One serving of this recipe as a loggable food, so it can be added to
  /// a meal through the same path as catalog foods.
  FoodItem get asServing => FoodItem(
        name: title,
        brand: 'Tarif',
        caloriesPer100g: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        servingLabel: '1 porsiyon',
      );
}

class WeightEntry {
  const WeightEntry(this.date, this.kg);
  final DateTime date;
  final double kg;
}

/// Where a diary entry came from; stored as its `name`.
enum FoodLogSource { catalog, recipe, barcode, photo, custom }

/// One food in the diary, with its name, serving and nutrition copied at
/// log time so later catalog changes never rewrite past days.
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.date,
    required this.meal,
    required this.foodName,
    this.brand = '',
    required this.servingLabel,
    required this.amount,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.source = FoodLogSource.catalog,
    this.sourceRef,
    required this.loggedAt,
  });

  /// [amount] servings of [food] eaten as [meal] at [now]. The single place
  /// the diary's nutrition maths lives: `caloriesPer100g` is (as everywhere
  /// else in the app) treated as the value of one `servingLabel` serving,
  /// and [amount] multiplies it.
  factory FoodLogEntry.fromFood(
    FoodItem food,
    double amount,
    MealType meal,
    DateTime now, {
    FoodLogSource source = FoodLogSource.catalog,
    String? sourceRef,
  }) {
    return FoodLogEntry(
      id: '',
      date: dateKey(now),
      meal: meal,
      foodName: food.name,
      brand: food.brand,
      servingLabel: food.servingLabel,
      amount: amount,
      kcal: (food.caloriesPer100g * amount).round(),
      proteinG: food.proteinG * amount,
      carbsG: food.carbsG * amount,
      fatG: food.fatG * amount,
      source: source,
      sourceRef: sourceRef,
      loggedAt: now.toUtc(),
    );
  }

  /// UUID; empty until the entry has been saved.
  final String id;

  /// Local day, `yyyy-MM-dd`.
  final String date;
  final MealType meal;
  final String foodName;
  final String brand;
  final String servingLabel;

  /// Multiplier of [servingLabel].
  final double amount;

  /// Totals for [amount] servings.
  final int kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final FoodLogSource source;

  /// Barcode or custom food id, depending on [source].
  final String? sourceRef;

  /// When it was added (UTC); orders entries within a day.
  final DateTime loggedAt;

  /// One serving's worth as a [FoodItem], so the food detail screen's
  /// serving picker can edit this entry.
  FoodItem get asServingFood => FoodItem(
        name: foodName,
        brand: brand,
        caloriesPer100g: (kcal / amount).round(),
        proteinG: proteinG / amount,
        carbsG: carbsG / amount,
        fatG: fatG / amount,
        servingLabel: servingLabel,
      );

  /// This entry with [newAmount] servings; kcal and macros scale by
  /// `newAmount / amount`, mirroring `FoodLogDao.updateAmount`.
  FoodLogEntry withAmount(double newAmount) {
    final factor = newAmount / amount;
    return copyWith(
      amount: newAmount,
      kcal: (kcal * factor).round(),
      proteinG: proteinG * factor,
      carbsG: carbsG * factor,
      fatG: fatG * factor,
    );
  }

  FoodLogEntry copyWith({
    String? id,
    MealType? meal,
    double? amount,
    int? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) {
    return FoodLogEntry(
      id: id ?? this.id,
      date: date,
      meal: meal ?? this.meal,
      foodName: foodName,
      brand: brand,
      servingLabel: servingLabel,
      amount: amount ?? this.amount,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      source: source,
      sourceRef: sourceRef,
      loggedAt: loggedAt,
    );
  }
}
