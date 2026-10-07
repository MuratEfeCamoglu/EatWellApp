import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_food.dart';
import 'db/app_database.dart';
import 'db/date_key.dart';
import 'health_consent.dart';
import 'mock_data.dart';
import 'models.dart';
import 'repositories/custom_food_repository.dart';
import 'repositories/food_log_repository.dart';
import 'repositories/water_repository.dart';
import 'repositories/weight_repository.dart';
import 'stats/daily_summary.dart';
import 'stats/streak.dart';

enum Gender { female, male }

enum ActivityLevel { sedentary, light, moderate, active }

extension ActivityLevelMultiplier on ActivityLevel {
  /// Standard Harris/Mifflin activity multipliers used to turn BMR into TDEE.
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
    }
  }
}

enum WeightGoal { lose, maintain, gain }

enum TextScaleOption { small, normal, large, extraLarge }

extension TextScaleOptionValue on TextScaleOption {
  double get scale {
    switch (this) {
      case TextScaleOption.small:
        return 0.9;
      case TextScaleOption.normal:
        return 1.0;
      case TextScaleOption.large:
        return 1.15;
      case TextScaleOption.extraLarge:
        return 1.3;
    }
  }

  String get label {
    switch (this) {
      case TextScaleOption.small:
        return 'Küçük';
      case TextScaleOption.normal:
        return 'Normal';
      case TextScaleOption.large:
        return 'Büyük';
      case TextScaleOption.extraLarge:
        return 'Çok büyük';
    }
  }
}

/// Answers collected across the 6-step setup wizard. Kept separate from
/// [UserProfile] because it's incomplete until the final step turns it into
/// one; screens write into this as the user moves forward instead of each
/// screen re-reading the shared mock profile.
class SetupDraft {
  String name = '';
  String email = '';
  Gender gender = Gender.female;
  int age = 27;
  double heightCm = 168;
  double weightKg = 70;
  ActivityLevel activityLevel = ActivityLevel.moderate;
  WeightGoal goal = WeightGoal.lose;
  double weeklyPaceKg = 0.5;

  /// Null until the goal screen either defaults it (lose/gain) or the user
  /// edits it directly; [AppState.suggestedGoalWeightKg] supplies the
  /// starting suggestion.
  double? goalWeightKg;
}

/// Shared, persisted app state. Replaces scattered references to the
/// static [MockData.user] with a real (initially empty) profile that only
/// gets filled in once the user actually completes setup, plus a mutable
/// diary so adding a food item is reflected across Home/Diary.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  /// A fresh, non-singleton instance so tests don't share state.
  @visibleForTesting
  AppState.forTesting();

  static const _kThemeMode = 'theme_mode';
  static const _kTextScale = 'text_scale';
  static const _kReduceMotion = 'reduce_motion';
  static const _kLocale = 'locale';
  static const _kSetupComplete = 'setup_complete';
  static const _kName = 'user_name';
  static const _kEmail = 'user_email';
  static const _kInitials = 'user_initials';
  static const _kCalorieGoal = 'user_calorie_goal';
  static const _kProteinGoal = 'user_protein_goal';
  static const _kCarbsGoal = 'user_carbs_goal';
  static const _kFatGoal = 'user_fat_goal';
  static const _kHeight = 'user_height';
  static const _kWeight = 'user_weight';
  static const _kGoalWeight = 'user_goal_weight';
  static const _kWeeklyPace = 'user_weekly_pace';
  static const _kMemberSince = 'user_member_since';
  static const _kFavoriteRecipes = 'favorite_recipes';
  static const _kAllergies = 'user_allergies';
  static const _kAllergyNote = 'user_allergy_note';
  static const _kConsentVersion = 'consent_version';
  static const _kConsentAt = 'consent_at';

  /// Set once the profile weight of a pre-database install has been copied
  /// into `weight_entries` (or setup recorded a first weight itself), so
  /// the migration never runs twice.
  static const _kWeightMigrated = 'weight_history_migrated';

  ThemeMode themeMode = ThemeMode.light;
  TextScaleOption textScale = TextScaleOption.normal;
  bool reduceMotion = false;
  Locale locale = const Locale('tr');

  bool setupComplete = false;
  UserProfile user = UserProfile.empty;
  SetupDraft draft = SetupDraft();

  /// Allergies entered on the health & consent page (F21).
  AllergyProfile allergies = AllergyProfile.none;

  /// Null until the user ticks the explicit-consent box (F20); the setup
  /// wizard is only reachable once this is set.
  ConsentRecord? consent;

  bool get hasConsent => consent != null;

  /// The pace chosen during setup, persisted separately from [draft] (which
  /// resets each session) so screens like Profile can still show an
  /// accurate ETA after an app restart.
  double weeklyPaceKg = 0.5;

  /// When setup actually completed — used for Profile's "üye" (member
  /// since) label instead of a fixed placeholder date.
  DateTime? memberSince;

  static const _mealTitles = {
    MealType.breakfast: 'Kahvaltı',
    MealType.lunch: 'Öğle yemeği',
    MealType.dinner: 'Akşam yemeği',
    MealType.snack: 'Ara öğün',
  };

  /// Today's diary entries in logged order. Kept in sync with the database
  /// (a live subscription plus a refresh after every write); without a
  /// database it is a plain in-memory list.
  List<FoodLogEntry> todayEntries = const [];
  DailySummary _todaySummary = DailySummary.empty;

  /// Local day key [todayEntries] belongs to.
  String _todayKey = '';
  StreamSubscription<List<FoodLogEntry>>? _todaySub;
  Timer? _midnightTimer;
  FoodLogRepository? _foodLog;

  DailySummary get todaySummary => _todaySummary;

  /// Legacy per-meal view used by Home: one card per meal with the food
  /// names joined by commas, derived from [todayEntries].
  List<MealEntry> get todaysMeals => [
        for (final type in MealType.values)
          _mealEntry(type, _todaySummary.meal(type)),
      ];

  static MealEntry _mealEntry(MealType type, MealSummary meal) => MealEntry(
        type: type,
        title: _mealTitles[type]!,
        description: meal.entries.isEmpty
            ? 'Henüz eklenmedi'
            : meal.entries.map((e) => e.foodName).join(', '),
        calories: meal.kcal,
        logged: meal.entries.isNotEmpty,
      );

  double get proteinConsumedG => _todaySummary.proteinG;
  double get carbsConsumedG => _todaySummary.carbsG;
  double get fatConsumedG => _todaySummary.fatG;
  /// Glasses drunk today; reloaded for the new day after midnight.
  int get waterGlasses => _waterGlasses;
  int _waterGlasses = 0;
  WaterRepository? _water;

  /// Every weight measurement, oldest first (from the database when there
  /// is one). Charts reduce it to the last measurement of each day.
  final List<WeightEntry> weightHistory = [];
  WeightRepository? _weights;

  int get caloriesConsumedToday => _todaySummary.kcal;

  bool get hasLoggedFoodToday => todayEntries.isNotEmpty;

  /// Days (`yyyy-MM-dd`) with at least one diary entry, from the database.
  Set<String> _loggedDates = const {};

  Set<String> get _datesForStats => _foodLog == null
      ? {if (todayEntries.isNotEmpty) _todayKey}
      : _loggedDates;

  /// Current logging streak, always derived from the diary (never stored).
  int get streakDays => currentStreak(_datesForStats, clock());

  /// Number of distinct days with at least one diary entry.
  int get loggedDaysCount => _datesForStats.length;

  /// Sets today's glasses (clamped to the goal). Shown immediately; if the
  /// write fails the previous value comes back and the error is rethrown.
  Future<void> setWaterGlasses(int value) async {
    await rollOverDayIfNeeded();
    final previous = _waterGlasses;
    _waterGlasses = value.clamp(0, MockData.waterGlassesGoal);
    notifyListeners();
    final repo = _water;
    if (repo == null) return;
    try {
      await repo.setGlasses(_todayKey, _waterGlasses, clock());
    } catch (_) {
      _waterGlasses = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// Titles of recipes the user has hearted, persisted across restarts.
  final Set<String> favoriteRecipes = {};

  bool isFavoriteRecipe(Recipe recipe) => favoriteRecipes.contains(recipe.title);

  void toggleFavoriteRecipe(Recipe recipe) {
    if (!favoriteRecipes.remove(recipe.title)) favoriteRecipes.add(recipe.title);
    notifyListeners();
    _prefs?.setStringList(_kFavoriteRecipes, favoriteRecipes.toList());
  }

  /// Records a new weight and keeps the profile's `user_weight` equal to
  /// the latest measurement. Throws if the database write fails.
  Future<void> logWeight(double kg) async {
    final now = clock();
    final repo = _weights;
    if (repo == null) {
      weightHistory.add(WeightEntry(now, kg));
    } else {
      await repo.addEntry(kg, now);
      await _reloadWeights(repo);
    }
    user = user.copyWith(weightKg: kg);
    notifyListeners();
    await _prefs?.setDouble(_kWeight, kg);
  }

  Future<void> _reloadWeights(WeightRepository repo) async {
    final history = await repo.history();
    weightHistory
      ..clear()
      ..addAll(history);
  }

  /// One-time copy of a pre-database install's profile weight into
  /// `weight_entries`, dated today, so its chart doesn't start empty.
  Future<void> _migrateLegacyWeight(
      WeightRepository repo, SharedPreferences prefs) async {
    if (prefs.getBool(_kWeightMigrated) ?? false) return;
    if (await repo.latest() == null && user.weightKg > 0) {
      await repo.addEntry(user.weightKg, clock());
    }
    await prefs.setBool(_kWeightMigrated, true);
  }

  SharedPreferences? _prefs;

  /// The on-device database, or null when running without one (widget
  /// tests that never call `load(db: ...)`); every DB-backed feature then
  /// silently falls back to in-memory behaviour.
  AppDatabase? _db;

  bool get hasDatabase => _db != null;

  /// Turkish, user-facing message set when the database couldn't be
  /// opened. The app keeps working in memory and the file is never
  /// deleted automatically (CLAUDE.md §8).
  String? storageError;

  /// Source of "now" for everything date-dependent; tests replace it with
  /// a fixed clock. Only this outermost layer ever calls [DateTime.now].
  DateTime Function() clock = DateTime.now;

  Future<void> load({AppDatabase? db}) async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    if (db != null) await _attachDatabase(db);
    await _loadToday();

    final themeName = prefs.getString(_kThemeMode);
    themeMode = switch (themeName) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };

    final scaleName = prefs.getString(_kTextScale);
    textScale = TextScaleOption.values.firstWhere(
      (o) => o.name == scaleName,
      orElse: () => TextScaleOption.normal,
    );
    reduceMotion = prefs.getBool(_kReduceMotion) ?? false;
    locale = Locale(prefs.getString(_kLocale) ?? 'tr');
    favoriteRecipes
      ..clear()
      ..addAll(prefs.getStringList(_kFavoriteRecipes) ?? const []);

    allergies = AllergyProfile.decode(
      prefs.getStringList(_kAllergies) ?? const [],
      prefs.getString(_kAllergyNote) ?? '',
    );
    consent = ConsentRecord.tryParse(
      prefs.getString(_kConsentVersion),
      prefs.getString(_kConsentAt),
    );

    setupComplete = prefs.getBool(_kSetupComplete) ?? false;
    weeklyPaceKg = prefs.getDouble(_kWeeklyPace) ?? 0.5;
    final memberSinceStr = prefs.getString(_kMemberSince);
    memberSince = memberSinceStr == null ? null : DateTime.tryParse(memberSinceStr);
    if (setupComplete) {
      user = UserProfile(
        name: prefs.getString(_kName) ?? '',
        initials: prefs.getString(_kInitials) ?? '',
        email: prefs.getString(_kEmail) ?? '',
        // The old `user_streak` pref is no longer read; see [streakDays].
        streakDays: 0,
        calorieGoal: prefs.getInt(_kCalorieGoal) ?? 0,
        proteinGoalG: prefs.getInt(_kProteinGoal) ?? 0,
        carbsGoalG: prefs.getInt(_kCarbsGoal) ?? 0,
        fatGoalG: prefs.getInt(_kFatGoal) ?? 0,
        heightCm: prefs.getDouble(_kHeight) ?? 0,
        weightKg: prefs.getDouble(_kWeight) ?? 0,
        goalWeightKg: prefs.getDouble(_kGoalWeight) ?? 0,
      );
    }
    await _loadWeights(prefs);
    await _loadCustomFoods();
    notifyListeners();
  }

  /// "Tüm verilerimi sil": physically empties every database table, clears
  /// all preferences and resets this state to a first launch. The database
  /// itself stays open so the app keeps working afterwards.
  Future<void> deleteAllData() async {
    final db = _db;
    if (db != null) await db.wipeAllData();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.clear();

    // [load] only fills what the (now empty) preferences contain, so first
    // drop everything it wouldn't overwrite.
    user = UserProfile.empty;
    draft = SetupDraft();
    allergies = AllergyProfile.none;
    consent = null;
    customFoods = const [];
    _loggedDates = const {};
    _memoryDeleted.clear();
    _waterGlasses = 0;
    await load(db: db);
  }

  /// The user's own foods, sorted by name.
  List<CustomFood> customFoods = const [];
  CustomFoodRepository? _customFoodRepo;
  int _memoryCustomIds = 0;

  Future<void> _loadCustomFoods() async {
    final repo = _customFoodRepo;
    if (repo == null) return;
    try {
      customFoods = List.unmodifiable(await repo.all());
    } catch (e, st) {
      developer.log('Loading custom foods failed', error: e, stackTrace: st);
    }
  }

  void _setMemoryCustomFoods(List<CustomFood> foods) {
    customFoods = List.unmodifiable(
        [...foods]..sort((a, b) => a.name.compareTo(b.name)));
  }

  /// Saves a new own food and returns it with its id. Throws on failure.
  Future<CustomFood> addCustomFood(CustomFood draft) async {
    final repo = _customFoodRepo;
    final CustomFood saved;
    if (repo == null) {
      saved = draft.copyWith(id: 'mem-custom-${_memoryCustomIds++}');
      _setMemoryCustomFoods([...customFoods, saved]);
    } else {
      saved = await repo.add(draft, clock());
      customFoods = List.unmodifiable(await repo.all());
    }
    notifyListeners();
    return saved;
  }

  Future<void> updateCustomFood(CustomFood food) async {
    final repo = _customFoodRepo;
    if (repo == null) {
      _setMemoryCustomFoods(
          [for (final f in customFoods) f.id == food.id ? food : f]);
    } else {
      await repo.update(food, clock());
      customFoods = List.unmodifiable(await repo.all());
    }
    notifyListeners();
  }

  /// Soft-deletes an own food; diary entries already logged keep their
  /// copied values.
  Future<void> deleteCustomFood(String id) async {
    final repo = _customFoodRepo;
    if (repo == null) {
      _setMemoryCustomFoods([for (final f in customFoods) if (f.id != id) f]);
    } else {
      await repo.delete(id, clock());
      customFoods = List.unmodifiable(await repo.all());
    }
    notifyListeners();
  }

  /// The own food saved for a scanned [barcode], checked before the online
  /// product lookup.
  CustomFood? customFoodForBarcode(String barcode) {
    for (final f in customFoods) {
      if (f.barcode == barcode) return f;
    }
    return null;
  }

  Future<void> _loadWeights(SharedPreferences prefs) async {
    weightHistory.clear();
    final repo = _weights;
    if (repo == null) {
      // No database: a single point from the last known weight rather
      // than an empty chart.
      if (setupComplete) weightHistory.add(WeightEntry(clock(), user.weightKg));
      return;
    }
    try {
      if (setupComplete) await _migrateLegacyWeight(repo, prefs);
      await _reloadWeights(repo);
    } catch (e, st) {
      developer.log('Loading weights failed', error: e, stackTrace: st);
    }
  }

  Future<void> _attachDatabase(AppDatabase db) async {
    try {
      // Drift opens lazily; a trivial query forces the file to be created
      // (and any open/migration error to surface) right here.
      await db.customSelect('SELECT 1').get();
      try {
        await db.purgeSoftDeleted(clock());
      } catch (e, st) {
        // Housekeeping only; never block the app on it.
        developer.log('Purging old deleted rows failed',
            error: e, stackTrace: st);
      }
      _db = db;
      _foodLog = FoodLogRepository(db);
      _water = WaterRepository(db);
      _weights = WeightRepository(db);
      _customFoodRepo = CustomFoodRepository(db);
      storageError = null;
    } catch (e, st) {
      developer.log('Database open failed', error: e, stackTrace: st);
      _db = null;
      _foodLog = null;
      _water = null;
      _weights = null;
      _customFoodRepo = null;
      storageError =
          'Kayıtların saklandığı veritabanı açılamadı. Uygulamayı kullanmaya '
          'devam edebilirsin ama bu oturumdaki kayıtlar kaydedilmeyecek.';
    }
  }

  void _setTodayEntries(List<FoodLogEntry> entries) {
    todayEntries = List.unmodifiable(entries);
    _todaySummary = DailySummary.fromEntries(todayEntries);
  }

  /// (Re)binds today's entries to the current local day: loads them,
  /// subscribes to changes and arms a timer for the next midnight.
  Future<void> _loadToday() async {
    final now = clock();
    _todayKey = dateKey(now);
    await _todaySub?.cancel();
    _todaySub = null;
    _midnightTimer?.cancel();

    final repo = _foodLog;
    if (repo == null) {
      _setTodayEntries(const []);
      _waterGlasses = 0;
    } else {
      try {
        _setTodayEntries(await repo.entriesForDate(_todayKey));
        _loggedDates = await repo.datesWithEntries();
        _waterGlasses = await _water!.glassesFor(_todayKey);
      } catch (e, st) {
        developer.log('Loading today failed', error: e, stackTrace: st);
        _setTodayEntries(const []);
      }
      final key = _todayKey;
      _todaySub = repo.watchDate(key).listen((entries) {
        if (key != _todayKey) return;
        _setTodayEntries(entries);
        notifyListeners();
      }, onError: (Object e, StackTrace st) {
        developer.log('Watching today failed', error: e, stackTrace: st);
      });
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      _midnightTimer = Timer(
        nextMidnight.difference(now) + const Duration(seconds: 1),
        rollOverDayIfNeeded,
      );
    }
  }

  /// Moves "today" to the new day if the clock passed midnight while the
  /// app stayed open; called by the midnight timer and before writes.
  Future<void> rollOverDayIfNeeded() async {
    if (dateKey(clock()) == _todayKey) return;
    await _loadToday();
    notifyListeners();
  }

  /// Live entries of the local day containing [day], for the Diary's day
  /// browser. Without a database only today has (in-memory) entries.
  Stream<List<FoodLogEntry>> watchEntriesForDate(DateTime day) {
    final key = dateKey(day);
    final repo = _foodLog;
    if (repo == null) {
      return Stream.value(key == _todayKey ? todayEntries : const []);
    }
    return repo.watchDate(key);
  }

  @override
  void dispose() {
    _todaySub?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    _prefs?.setString(_kThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void setTextScale(TextScaleOption option) {
    textScale = option;
    notifyListeners();
    _prefs?.setString(_kTextScale, option.name);
  }

  void setReduceMotion(bool value) {
    reduceMotion = value;
    notifyListeners();
    _prefs?.setBool(_kReduceMotion, value);
  }

  void setLocale(Locale value) {
    locale = value;
    notifyListeners();
    _prefs?.setString(_kLocale, value.languageCode);
  }

  /// Stores the allergy answers and the explicit consent given at [now]
  /// (F20, F21). Device-only for now; moves to the cloud profile in Aşama 3.
  Future<void> saveHealthConsent({
    required AllergyProfile allergies,
    required DateTime now,
  }) async {
    this.allergies = allergies;
    consent = ConsentRecord(version: kConsentVersion, acceptedAt: now);
    notifyListeners();

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await Future.wait([
      prefs.setStringList(_kAllergies, allergies.encodeAllergens()),
      prefs.setString(_kAllergyNote, allergies.otherNote),
      prefs.setString(_kConsentVersion, consent!.version),
      prefs.setString(_kConsentAt, now.toIso8601String()),
    ]);
  }

  /// Basal metabolic rate via the Mifflin-St Jeor equation.
  double _bmr({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return gender == Gender.male ? base + 5 : base - 161;
  }

  /// A sensible default target weight for the current draft's goal, used to
  /// pre-fill the (still user-editable) "Hedef kilo" field. Maintaining
  /// weight always suggests the current weight itself, never a fixed mock
  /// number, so it stops contradicting a goal the user didn't ask for.
  double suggestedGoalWeightKg(WeightGoal goal, double currentWeightKg) {
    switch (goal) {
      case WeightGoal.maintain:
        return currentWeightKg;
      case WeightGoal.lose:
        return (currentWeightKg - 5).clamp(35, currentWeightKg);
      case WeightGoal.gain:
        return currentWeightKg + 5;
    }
  }

  /// Builds the final profile from [draft] using real BMR/TDEE math, stores
  /// it as the active user, and persists it so it survives app restarts.
  Future<void> completeSetup() async {
    final weightKg = draft.weightKg;
    final heightCm = draft.heightCm;
    final goalWeightKg =
        draft.goalWeightKg ?? suggestedGoalWeightKg(draft.goal, weightKg);

    final bmr = _bmr(
      gender: draft.gender,
      weightKg: weightKg,
      heightCm: heightCm,
      age: draft.age,
    );
    final tdee = bmr * draft.activityLevel.multiplier;

    // 1 kg of body fat ~= 7700 kcal.
    final dailyDeltaKcal = draft.weeklyPaceKg * 7700 / 7;
    double calorieGoal;
    switch (draft.goal) {
      case WeightGoal.lose:
        calorieGoal = tdee - dailyDeltaKcal;
        break;
      case WeightGoal.gain:
        calorieGoal = tdee + dailyDeltaKcal;
        break;
      case WeightGoal.maintain:
        calorieGoal = tdee;
        break;
    }
    final floor = draft.gender == Gender.male ? 1500.0 : 1200.0;
    calorieGoal = calorieGoal.clamp(floor, 4000.0);

    final proteinGoalG = (weightKg * 1.8).round();
    final fatGoalG = (calorieGoal * 0.27 / 9).round();
    final proteinKcal = proteinGoalG * 4;
    final fatKcal = fatGoalG * 9;
    final carbsGoalG = ((calorieGoal - proteinKcal - fatKcal) / 4)
        .round()
        .clamp(0, 999);

    final trimmedName = draft.name.trim();
    final displayName = trimmedName.isEmpty ? 'Kullanıcı' : trimmedName;
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    user = UserProfile(
      name: displayName,
      initials: initials.isEmpty ? '?' : initials,
      email: draft.email.trim(),
      streakDays: 0,
      calorieGoal: calorieGoal.round(),
      proteinGoalG: proteinGoalG,
      carbsGoalG: carbsGoalG,
      fatGoalG: fatGoalG,
      heightCm: heightCm,
      weightKg: weightKg,
      goalWeightKg: goalWeightKg,
    );
    setupComplete = true;
    weeklyPaceKg = draft.weeklyPaceKg;
    final now = clock();
    memberSince = now;
    final weights = _weights;
    if (weights == null) {
      weightHistory
        ..clear()
        ..add(WeightEntry(now, weightKg));
    } else {
      // A failed history write must not break setup itself; the profile
      // weight below is still saved.
      try {
        await weights.addEntry(weightKg, now);
        await _reloadWeights(weights);
      } catch (e, st) {
        developer.log('Saving setup weight failed', error: e, stackTrace: st);
        weightHistory
          ..clear()
          ..add(WeightEntry(now, weightKg));
      }
    }
    notifyListeners();

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await Future.wait([
      prefs.setBool(_kWeightMigrated, true),
      prefs.setBool(_kSetupComplete, true),
      prefs.setDouble(_kWeeklyPace, weeklyPaceKg),
      prefs.setString(_kMemberSince, memberSince!.toIso8601String()),
      prefs.setString(_kName, user.name),
      prefs.setString(_kInitials, user.initials),
      prefs.setString(_kEmail, user.email),
      prefs.setInt(_kCalorieGoal, user.calorieGoal),
      prefs.setInt(_kProteinGoal, user.proteinGoalG),
      prefs.setInt(_kCarbsGoal, user.carbsGoalG),
      prefs.setInt(_kFatGoal, user.fatGoalG),
      prefs.setDouble(_kHeight, user.heightCm),
      prefs.setDouble(_kWeight, user.weightKg),
      prefs.setDouble(_kGoalWeight, user.goalWeightKg),
    ]);
  }

  /// Adds [amount] servings (matching [food]'s serving size) of [food] to
  /// today's [type] meal and saves it. Throws if the write fails so the
  /// calling screen can tell the user.
  Future<void> addFoodToMeal(
    MealType type,
    FoodItem food,
    double amount, {
    FoodLogSource source = FoodLogSource.catalog,
    String? sourceRef,
  }) async {
    await rollOverDayIfNeeded();
    final now = clock();
    final draft = FoodLogEntry.fromFood(food, amount, type, now,
        source: source, sourceRef: sourceRef);
    final repo = _foodLog;
    if (repo == null) {
      _setTodayEntries([
        ...todayEntries,
        draft.copyWith(id: 'mem-${_memoryIds++}'),
      ]);
    } else {
      await repo.add(draft, now);
      await _refreshToday(repo);
    }
    notifyListeners();
  }

  /// In-memory fallback (no database): ids for new entries and the
  /// deleted ones kept around so "Geri al" can still restore them.
  int _memoryIds = 0;
  final Map<String, (int, FoodLogEntry)> _memoryDeleted = {};

  Future<void> _refreshToday(FoodLogRepository repo) async {
    _setTodayEntries(await repo.entriesForDate(_todayKey));
    _loggedDates = await repo.datesWithEntries();
  }

  /// Soft-deletes a diary entry of any day. Throws if the write fails.
  Future<void> deleteEntry(String id) async {
    final repo = _foodLog;
    if (repo == null) {
      final index = todayEntries.indexWhere((e) => e.id == id);
      if (index == -1) return;
      _memoryDeleted[id] = (index, todayEntries[index]);
      _setTodayEntries([...todayEntries]..removeAt(index));
    } else {
      await repo.delete(id, clock());
      await _refreshToday(repo);
    }
    notifyListeners();
  }

  /// Undoes [deleteEntry].
  Future<void> restoreEntry(String id) async {
    final repo = _foodLog;
    if (repo == null) {
      final removed = _memoryDeleted.remove(id);
      if (removed == null) return;
      final (index, entry) = removed;
      _setTodayEntries([...todayEntries]
        ..insert(index.clamp(0, todayEntries.length), entry));
    } else {
      await repo.restore(id, clock());
      await _refreshToday(repo);
    }
    notifyListeners();
  }

  /// Changes an entry's serving count (kcal/macros scale with it) and/or
  /// moves it to another meal. Throws if the write fails.
  Future<void> updateEntry(String id, {double? amount, MealType? meal}) async {
    final repo = _foodLog;
    if (repo == null) {
      _setTodayEntries([
        for (final e in todayEntries)
          if (e.id != id)
            e
          else
            (amount == null ? e : e.withAmount(amount)).copyWith(meal: meal),
      ]);
    } else {
      await repo.update(id, clock(), amount: amount, meal: meal);
      await _refreshToday(repo);
    }
    notifyListeners();
  }
}
