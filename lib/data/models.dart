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
  });

  final String title;
  final String description;
  final int minutes;
  final int calories;
  final String tag;
  final List<String> ingredients;
  final List<String> steps;
}

class WeightEntry {
  const WeightEntry(this.date, this.kg);
  final DateTime date;
  final double kg;
}
