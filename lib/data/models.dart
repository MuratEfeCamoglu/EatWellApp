/// Shared mock-data model classes used across Denge's screens.
/// This app has no backend; all data is static/local mock data that
/// mirrors the numbers shown in the design.
library;

import 'package:flutter/material.dart' show IconData, Icons;

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

  UserProfile copyWith({double? weightKg, int? streakDays}) {
    return UserProfile(
      name: name,
      initials: initials,
      email: email,
      streakDays: streakDays ?? this.streakDays,
      calorieGoal: calorieGoal,
      proteinGoalG: proteinGoalG,
      carbsGoalG: carbsGoalG,
      fatGoalG: fatGoalG,
      heightCm: heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalWeightKg: goalWeightKg,
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
