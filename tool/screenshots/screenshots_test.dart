// Renders the app's main screens with sample data into PNG files for the
// presentation mockups (docs/mockups/). Not part of the regular test suite:
//
//   flutter test tool/screenshots/screenshots_test.dart --update-goldens
//
// Output: tool/screenshots/raw/<name>.png (1170×2532, iPhone-sized), then
// `python3 tool/screenshots/camera_fill.py tool/screenshots/raw/2[45]_barcode_*.png`
// and `python3 tool/screenshots/frame.py tool/screenshots/raw docs/mockups`.
//
// `flutter test` normally replaces every font without an explicit family
// (button labels, RichText) with box glyphs. For readable output the
// docs/mockups images were rendered with a Flutter SDK whose test runner
// omits `--use-test-fonts` (packages/flutter_tools/lib/src/test/
// flutter_tester_device.dart) and Roboto installed as the system sans-serif.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
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
import 'package:denge/screens/diary/barcode_screen.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  String? scrollToText,
  bool fullPage = true,
  Future<void> Function()? afterBuild,
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
  await _settleImages(tester);
  if (afterBuild != null) {
    await afterBuild();
    await _settleImages(tester);
  }
  if (fullPage) {
    // Grow the phone screen until the page's main list fits without
    // scrolling, so the mockup shows the whole screen top to bottom. Long
    // lazy lists (the food catalog) are capped.
    for (var i = 0; i < 4; i++) {
      final extent = _longestScrollExtent(tester);
      if (extent < 1) break;
      final size = tester.view.physicalSize;
      final height =
          (size.height + extent * tester.view.devicePixelRatio).clamp(0, _maxHeight);
      if (height <= size.height) break;
      tester.view.physicalSize = Size(size.width, height.toDouble());
      await tester.pump(const Duration(milliseconds: 400));
      await _settleImages(tester);
    }
  }
  if (scrollToText != null) {
    // Bring a section further down the page to the top of the screen.
    final target = find.text(scrollToText).first;
    await tester.ensureVisible(target);
    Scrollable.ensureVisible(tester.element(target), alignment: 0.08);
    await tester.pump(const Duration(milliseconds: 400));
  }
  await tester.pump(const Duration(seconds: 2));
  await expectLater(
      find.byType(MaterialApp), matchesGoldenFile('raw/$name.png'));
  tester.view.physicalSize = _phoneSize;
}

const _phoneSize = Size(1170, 2532);
const _maxHeight = 2532 * 2.0;

Future<void> _settleImages(WidgetTester tester) async {
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
}

/// How far the longest vertical, on-screen scrollable can still scroll.
double _longestScrollExtent(WidgetTester tester) {
  var longest = 0.0;
  for (final element in find.byType(Scrollable).evaluate()) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.axisDirection != AxisDirection.down) continue;
    final box = element.renderObject as RenderBox?;
    if (box == null || !box.hasSize || box.size.height < 200) continue;
    final position = state.position;
    if (!position.hasContentDimensions) continue;
    longest = position.maxScrollExtent > longest ? position.maxScrollExtent : longest;
  }
  return longest;
}

void main() {
  testWidgets('screenshots', (tester) async {
    // Tests draw elevation as flat outlines by default; show real shadows.
    debugDisableShadows = false;
    tester.view
      ..physicalSize = _phoneSize
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
    await _shoot(tester, '22_home_water', const MainShell(), scrollToText: 'Su', fullPage: false);
    await _shoot(tester, '23_home_water_dark', const MainShell(),
        dark: true, scrollToText: 'Su', fullPage: false);
    await _shootBarcode(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    debugDisableShadows = true;
  });
}

/// The scanner needs a camera, so its plugin channels are faked: the camera
/// "starts" with an empty preview (frame.py paints a photo behind it) and a
/// scan of a catalog barcode can be sent in.
Future<void> _shootBarcode(WidgetTester tester) async {
  final messenger = tester.binding.defaultBinaryMessenger;
  const method = MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');
  const events = EventChannel('dev.steenbakker.mobile_scanner/scanner/event');
  const orientation =
      EventChannel('dev.steenbakker.mobile_scanner/scanner/deviceOrientation');
  final sinks = <MockStreamHandlerEventSink>[];
  messenger.setMockMethodCallHandler(method, (call) async => switch (call.method) {
        'state' => 1,
        'request' => true,
        'start' => <String, Object?>{
            'textureId': 1,
            'numberOfCameras': 1,
            'currentTorchState': 0,
            'cameraDirection': 1,
            'size': <String, Object?>{'width': 1080.0, 'height': 1920.0},
          },
        _ => null,
      });
  messenger.setMockStreamHandler(
      events, MockStreamHandler.inline(onListen: (_, sink) => sinks.add(sink)));
  messenger.setMockStreamHandler(orientation, MockStreamHandler.inline(onListen: (_, _) {}));
  // The iOS code path of the plugin needs no Android surface details.
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  try {
    await _ignoringDoubleStart(() =>
        _shoot(tester, '24_barcode_scan', const BarcodeScreen(), fullPage: false));
    await _ignoringDoubleStart(() => _shoot(tester, '25_barcode_found',
            const BarcodeScreen(), fullPage: false, afterBuild: () async {
      sinks.last.success(<String, Object?>{
        'name': 'barcode',
        'data': [
          <String, Object?>{'rawValue': MockData.barcodeCatalog.keys.first, 'format': 32},
        ],
      });
      await tester.pump(const Duration(milliseconds: 400));
    }));
  } finally {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(method, null);
    messenger.setMockStreamHandler(events, null);
    messenger.setMockStreamHandler(orientation, null);
  }
}

/// The screen and the MobileScanner widget both start the camera and the
/// plugin rejects the second call with `controllerInitializing`; on a phone
/// that only gets logged. Any other error still fails the run.
Future<void> _ignoringDoubleStart(Future<void> Function() body) async {
  Object? failure;
  StackTrace? failureStack;
  final done = Completer<void>();
  runZonedGuarded(() async {
    await body();
    done.complete();
  }, (error, stack) {
    if (error is MobileScannerException &&
        error.errorCode == MobileScannerErrorCode.controllerInitializing) {
      return;
    }
    failure ??= error;
    failureStack ??= stack;
    if (!done.isCompleted) done.complete();
  });
  await done.future;
  if (failure != null) Error.throwWithStackTrace(failure!, failureStack!);
}
