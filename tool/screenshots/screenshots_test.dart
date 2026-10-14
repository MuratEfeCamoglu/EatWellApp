// Renders the app's main screens with sample data into PNG files for the
// presentation mockups (docs/mockups/). Not part of the regular test suite:
//
//   flutter test tool/screenshots/screenshots_test.dart --update-goldens
//
// Output: tool/screenshots/raw/<name>.png (1170×2532, iPhone-sized), then
// `python3 tool/screenshots/frame.py tool/screenshots/raw docs/mockups`.
//
// `flutter test` normally replaces every font without an explicit family
// (button labels, RichText) with box glyphs. For readable output the
// docs/mockups images were rendered with a Flutter SDK whose test runner
// omits `--use-test-fonts` (packages/flutter_tools/lib/src/test/
// flutter_tester_device.dart) and Roboto installed as the system sans-serif.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:denge/data/app_state.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:denge/data/more_foods.dart';
import 'package:denge/data/extra_foods.dart';
import 'package:denge/data/mock_data.dart';
import 'package:denge/data/recipes.dart';
import 'package:denge/screens/auth/cloud_consent_screen.dart';
import 'package:denge/screens/auth/health_consent_screen.dart';
import 'package:denge/screens/auth/sign_up_screen.dart';
import 'package:denge/screens/food/custom_food_screen.dart';
import 'package:denge/screens/food/food_detail_screen.dart';
import 'package:denge/screens/main_shell.dart';
import 'package:denge/screens/onboarding/onboarding_screen.dart';
import 'package:denge/screens/profile/goals_screen.dart';
import 'package:denge/screens/profile/notifications_screen.dart';
import 'package:denge/screens/recipes/recipe_detail_screen.dart';
import 'package:denge/screens/search/search_screen.dart';
import 'package:denge/screens/settings/settings_screen.dart';
import 'package:denge/screens/setup/setup_activity_screen.dart';
import 'package:denge/screens/setup/setup_goal_screen.dart';
import 'package:denge/screens/setup/setup_result_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final nunito = FontLoader('Nunito');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
    nunito.addFont(rootBundle.load('assets/fonts/Nunito-$w.ttf'));
  }
  await nunito.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
  await iconLoader.load();
  // Styles that name Roboto explicitly; family-less ones use the system
  // default (see the note at the top).
  for (final family in ['Roboto']) {
    final roboto = FontLoader(family);
    for (final w in ['Regular', 'Medium', 'Bold', 'Black']) {
      final f = File('$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-$w.ttf');
      roboto.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
    await roboto.load();
  }
}

FoodItem _food(String name) =>
    [...MockData.searchResults, ...extraFoods, ...moreFoods]
        .firstWhere((f) => f.name == name);

final _today = DateTime(2026, 10, 14, 13, 20);

Future<void> _seed(AppState s) async {
  var now = DateTime(2026, 9, 23, 8);
  s.clock = () => now;
  await s.load(db: AppDatabase.forTesting(NativeDatabase.memory()));
  s.draft
    ..name = 'Elif Yılmaz'
    ..email = 'elif@ornek.com'
    ..gender = Gender.female
    ..age = 27
    ..heightCm = 168
    ..weightKg = 72
    ..activityLevel = ActivityLevel.moderate
    ..goal = WeightGoal.lose
    ..weeklyPaceKg = 0.5
    ..goalWeightKg = 65;
  await s.completeSetup();
  // Three weeks of weigh-ins trending down, and a few logged days.
  for (var i = 0; i <= 21; i++) {
    now = DateTime(2026, 9, 23 + i, 8);
    await s.logWeight(72 - i * 0.09 + (i % 3 == 0 ? 0.15 : 0));
  }
  for (var d = 7; d >= 1; d--) {
    now = _today.subtract(Duration(days: d));
    await s.addFoodToMeal(MealType.breakfast, _food(MockData.searchResults.first.name), 1);
  }
  now = _today;
  await s.rollOverDayIfNeeded();
  final foods = [...MockData.searchResults, ...extraFoods, ...moreFoods];
  FoodItem pick(String part) =>
      foods.firstWhere((f) => f.name.toLowerCase().contains(part),
          orElse: () => foods.first);
  await s.addFoodToMeal(MealType.breakfast, pick('menemen'), 1);
  await s.addFoodToMeal(MealType.breakfast, pick('simit'), 1);
  await s.addFoodToMeal(MealType.breakfast, pick('çay'), 2);
  await s.addFoodToMeal(MealType.lunch, pick('mercimek'), 1);
  await s.addFoodToMeal(MealType.lunch, pick('pilav'), 1);
  await s.addFoodToMeal(MealType.snack, pick('ayran'), 1);
  await s.setWaterGlasses(6);
  s.favoriteRecipes.add(allRecipes.first.title);
}

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget page, {
  bool dark = false,
}) async {
  final state = AppState.instance;
  state.themeMode = dark ? ThemeMode.dark : ThemeMode.light;
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: KeyedSubtree(key: UniqueKey(), child: page),
    ),
  ));
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 400));
    // Asset images decode asynchronously; let them finish before capturing.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final image = (element.widget as Image).image;
        await precacheImage(image, element);
      }
    });
  }
  await tester.pump(const Duration(seconds: 2));
  await expectLater(
      find.byType(MaterialApp), matchesGoldenFile('raw/$name.png'));
}

void main() {
  testWidgets('screenshots', (tester) async {
    // Tests draw elevation as flat outlines by default; show real shadows.
    debugDisableShadows = false;
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3
      ..padding = const FakeViewPadding(top: 141, bottom: 102)
      ..viewPadding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadFonts();
      await _seed(AppState.instance);
    });

    final shots = <String, Widget>{
      '01_onboarding': const OnboardingScreen(),
      '02_sign_up': const SignUpScreen(),
      '03_health_consent': const HealthConsentScreen(),
      '04_setup_activity': const SetupActivityScreen(),
      '05_setup_goal': const SetupGoalScreen(),
      '06_setup_result': const SetupResultScreen(),
      '07_home': const MainShell(),
      '08_diary': const MainShell(initialIndex: 1),
      '09_search': const SearchScreen(),
      '10_food_detail': FoodDetailScreen(food: _food(MockData.searchResults.first.name)),
      '11_custom_food': const CustomFoodScreen(),
      '12_progress': const MainShell(initialIndex: 2),
      '13_recipes': const MainShell(initialIndex: 3),
      '14_recipe_detail': RecipeDetailScreen(recipe: allRecipes.first),
      '15_profile': const MainShell(initialIndex: 4),
      '16_goals': const GoalsScreen(),
      '17_notifications': const NotificationsScreen(),
      '18_settings': const SettingsScreen(),
      '19_cloud_consent': const CloudConsentScreen(),
    };
    for (final MapEntry(:key, :value) in shots.entries) {
      await _shoot(tester, key, value);
    }
    await _shoot(tester, '20_home_dark', const MainShell(), dark: true);
    await _shoot(tester, '21_diary_dark', const MainShell(initialIndex: 1), dark: true);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    debugDisableShadows = true;
  });
}
