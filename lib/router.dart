import 'package:flutter/material.dart';

import 'data/models.dart';
import 'screens/auth/health_consent_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/diary/barcode_screen.dart';
import 'screens/food/food_detail_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/recipes/recipe_detail_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/language_accessibility_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/setup/setup_activity_screen.dart';
import 'screens/setup/setup_age_screen.dart';
import 'screens/setup/setup_gender_screen.dart';
import 'screens/setup/setup_goal_screen.dart';
import 'screens/setup/setup_height_screen.dart';
import 'screens/setup/setup_result_screen.dart';
import 'screens/setup/setup_weight_screen.dart';
import 'screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signUp = '/sign-up';
  static const login = '/login';
  static const healthConsent = '/health-consent';
  static const setupGender = '/setup/gender';
  static const setupAge = '/setup/age';
  static const setupHeight = '/setup/height';
  static const setupWeight = '/setup/weight';
  static const setupActivity = '/setup/activity';
  static const setupGoal = '/setup/goal';
  static const setupResult = '/setup/result';
  static const main = '/main';
  static const search = '/search';
  static const barcode = '/barcode';
  static const foodDetail = '/food-detail';
  static const recipeDetail = '/recipe-detail';
  static const settings = '/settings';
  static const languageAccessibility = '/settings/language-accessibility';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        signUp: (_) => const SignUpScreen(),
        login: (_) => const LoginScreen(),
        healthConsent: (_) => const HealthConsentScreen(),
        setupGender: (_) => const SetupGenderScreen(),
        setupAge: (_) => const SetupAgeScreen(),
        setupHeight: (_) => const SetupHeightScreen(),
        setupWeight: (_) => const SetupWeightScreen(),
        setupActivity: (_) => const SetupActivityScreen(),
        setupGoal: (_) => const SetupGoalScreen(),
        setupResult: (_) => const SetupResultScreen(),
        main: (_) => const MainShell(),
        search: (_) => const SearchScreen(),
        barcode: (_) => const BarcodeScreen(),
      };

  /// Routes that require arguments are pushed with [Navigator.push] and a
  /// [MaterialPageRoute] directly (see [pushFoodDetail], [pushRecipeDetail])
  /// rather than through the named-route table above.
  static Route<void> pushFoodDetail(
    FoodItem food, {
    MealType? initialMeal,
    FoodLogSource source = FoodLogSource.catalog,
    String? sourceRef,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: foodDetail),
      builder: (_) => FoodDetailScreen(
        food: food,
        initialMeal: initialMeal,
        source: source,
        sourceRef: sourceRef,
      ),
    );
  }

  /// Pushes the food search screen, optionally pre-targeting [initialMeal]
  /// (e.g. tapping "+" on the Diary's breakfast card) instead of always
  /// defaulting to whichever meal fits the current time of day.
  static Route<void> pushSearch({MealType? initialMeal}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: search),
      builder: (_) => SearchScreen(initialMeal: initialMeal),
    );
  }

  static Route<void> pushBarcode({MealType? initialMeal}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: barcode),
      builder: (_) => BarcodeScreen(initialMeal: initialMeal),
    );
  }

  static Route<void> pushLanguageAccessibility() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: languageAccessibility),
      builder: (_) => const LanguageAccessibilityScreen(),
    );
  }

  static Route<void> pushRecipeDetail(Recipe recipe, {String? heroTag}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: recipeDetail),
      builder: (_) => RecipeDetailScreen(recipe: recipe, heroTag: heroTag),
    );
  }

  static Route<void> pushSettings() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: settings),
      builder: (_) => const SettingsScreen(),
    );
  }
}
