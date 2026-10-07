import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';
import 'custom_food.dart';
import 'db/app_database.dart';
import 'db/date_key.dart';
import 'health_consent.dart';
import 'mock_data.dart';
import 'models.dart';
import 'nutrition_targets.dart';
import 'profile_enums.dart';
import 'reminders.dart';
import 'repositories/custom_food_repository.dart';
import 'repositories/food_log_repository.dart';
import 'repositories/water_repository.dart';
import 'repositories/weight_repository.dart';
import 'stats/daily_summary.dart';
import 'stats/streak.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;

import 'sync/profile_snapshot.dart';
import 'sync/sync_backend.dart';
import 'sync/sync_engine.dart';

// Screens import these through app_state.dart.
export 'profile_enums.dart';

enum TextScaleOption { small, normal, large, extraLarge }

/// Cloud backup state shown in Settings.
enum SyncStatus {
  /// Not signed in, no cloud consent, or a local-only build.
  off,

  /// On, but no run has finished yet in this session.
  pending,
  syncing,
  upToDate,

  /// The last run failed (usually offline); it is retried automatically.
  error,
}

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
  static const _kGender = 'user_gender';
  static const _kAge = 'user_age';
  static const _kActivity = 'user_activity';
  static const _kGoalType = 'user_goal_type';
  static const _kNotifications = 'notification_settings';
  static const _kProfileUpdatedAt = 'profile_updated_at';
  static const _kCloudConsentVersion = 'cloud_consent_version';
  static const _kCloudConsentAt = 'cloud_consent_at';
  static const _kLastSyncedAt = 'last_synced_at';

  /// Version of the cloud-storage consent text (CLAUDE.md §13.5). Separate
  /// from the health-data consent: the app works fully without the cloud,
  /// so refusing this must never block anything else. Bump when the text
  /// changes materially.
  static const kCloudConsentVersion = '2026-10-cloud-1';

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

  /// Setup answers kept for the profile screens and goal suggestions. Null
  /// for installs that completed setup before these were stored.
  Gender? gender;
  int? age;
  ActivityLevel? activityLevel;
  WeightGoal? weightGoal;

  /// [weightGoal], or — when it was never stored — the direction implied
  /// by the current and goal weights.
  WeightGoal get effectiveGoal {
    final stored = weightGoal;
    if (stored != null) return stored;
    final delta = user.goalWeightKg - user.weightKg;
    if (delta.abs() < 0.5) return WeightGoal.maintain;
    return delta < 0 ? WeightGoal.lose : WeightGoal.gain;
  }

  /// Reminder choices (all off until the user opts in).
  NotificationSettings notificationSettings = const NotificationSettings();

  /// The cloud; null for local-only builds (see `main`).
  SyncBackend? syncBackend;

  /// When the user agreed to store their data in the cloud (null = not).
  DateTime? cloudConsentAt;
  String? _cloudConsentVersion;
  bool get hasCloudConsent => _cloudConsentVersion == kCloudConsentVersion;

  /// Last local profile change (UTC ms); decides which side wins a sync.
  int _profileUpdatedAt = 0;
  Future<void>? _profileSync;
  bool _profileSyncAgain = false;

  // ---- push sync (B4)
  bool get _syncEnabled =>
      syncBackend != null && isSignedIn && hasCloudConsent;
  SyncStatus _syncStatus = SyncStatus.pending;
  SyncStatus get syncStatus => _syncEnabled ? _syncStatus : SyncStatus.off;

  /// When the last sync run finished successfully.
  DateTime? lastSyncedAt;

  /// Quiet period after a local write before it is sent, so a burst of
  /// edits goes out in one run (CLAUDE.md §13.4). Tests shorten it.
  Duration syncDelay = const Duration(seconds: 5);
  Timer? _syncTimer;
  Future<void>? _syncRun;
  bool _syncAgain = false;
  int _syncFailures = 0;
  StreamSubscription<Object?>? _tablesSub;

  /// Schedules the actual OS notifications; `main` installs the platform
  /// implementation, tests keep the no-op or a fake.
  ReminderScheduler reminders = const NoopReminderScheduler();

  /// Account provider; Supabase when configured (see `main`), otherwise
  /// unavailable and the app is local-only.
  AuthService get auth => _auth;
  AuthService _auth = const UnavailableAuthService();
  StreamSubscription<AuthEvent>? _authSub;
  bool _pendingPasswordRecovery = false;

  set auth(AuthService service) {
    _authSub?.cancel();
    _auth = service;
    _authSub = service.events.listen((event) {
      if (event == AuthEvent.passwordRecovery) _pendingPasswordRecovery = true;
      notifyListeners();
    });
  }

  bool get accountsAvailable => _auth.isAvailable;
  AuthUser? get account => _auth.currentUser;
  bool get isSignedIn => account != null;

  /// True once after a password-reset link opened the app; the app root
  /// then shows the "new password" screen.
  bool takePendingPasswordRecovery() {
    final pending = _pendingPasswordRecovery;
    _pendingPasswordRecovery = false;
    return pending;
  }

  /// Creates an account; the name and e-mail also seed the setup wizard.
  /// Throws [AuthFailure].
  Future<SignUpResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _auth.signUp(
        email: email.trim(), password: password, name: name.trim());
    draft
      ..name = name.trim()
      ..email = email.trim();
    notifyListeners();
    return result;
  }

  /// Throws [AuthFailure]. When this device has no profile yet, the
  /// account's name and e-mail pre-fill the setup wizard.
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signIn(email: email.trim(), password: password);
    final user = account;
    if (!setupComplete && user != null) {
      draft
        ..name = user.name
        ..email = user.email;
    }
    notifyListeners();
    await syncNow();
  }

  // ---------------------------------------------------------------------------
  // Cloud consent and profile sync (CLAUDE.md §13, Aşama B3)
  // ---------------------------------------------------------------------------

  /// Records the cloud-storage consent and syncs right away.
  Future<void> giveCloudConsent() async {
    final now = clock();
    _cloudConsentVersion = kCloudConsentVersion;
    cloudConsentAt = now;
    notifyListeners();
    final prefs = await _prefsOrLoad();
    await Future.wait([
      prefs.setString(_kCloudConsentVersion, kCloudConsentVersion),
      prefs.setString(_kCloudConsentAt, now.toIso8601String()),
    ]);
    await syncNow();
  }

  /// Stops syncing. Data already in the cloud stays until the user deletes
  /// it (account deletion, Aşama B6).
  Future<void> revokeCloudConsent() async {
    _cloudConsentVersion = null;
    cloudConsentAt = null;
    notifyListeners();
    final prefs = await _prefsOrLoad();
    await Future.wait([
      prefs.remove(_kCloudConsentVersion),
      prefs.remove(_kCloudConsentAt),
    ]);
  }

  /// Marks the profile as changed now and pushes it in the background.
  Future<void> _touchProfile() async {
    _profileUpdatedAt = clock().toUtc().millisecondsSinceEpoch;
    final prefs = await _prefsOrLoad();
    await prefs.setInt(_kProfileUpdatedAt, _profileUpdatedAt);
    unawaited(syncProfile());
  }

  /// This device's profile as a sync value; null before setup.
  ProfileSnapshot? get localProfileSnapshot {
    if (!setupComplete) return null;
    final c = consent;
    return ProfileSnapshot(
      createdAt: (memberSince ?? DateTime.fromMillisecondsSinceEpoch(_profileUpdatedAt))
          .toUtc()
          .millisecondsSinceEpoch,
      updatedAt: _profileUpdatedAt,
      name: user.name,
      email: user.email,
      gender: gender,
      age: age,
      heightCm: user.heightCm > 0 ? user.heightCm : null,
      weightKg: user.weightKg > 0 ? user.weightKg : null,
      activityLevel: activityLevel,
      weightGoal: weightGoal,
      goalWeightKg: user.goalWeightKg > 0 ? user.goalWeightKg : null,
      weeklyPaceKg: weeklyPaceKg,
      calorieGoal: user.calorieGoal,
      proteinGoalG: user.proteinGoalG,
      carbsGoalG: user.carbsGoalG,
      fatGoalG: user.fatGoalG,
      allergies: allergies.encodeAllergens(),
      allergyNote: allergies.otherNote,
      consentVersion: c?.version,
      consentAt: c?.acceptedAt.toUtc().millisecondsSinceEpoch,
    );
  }

  /// Adopts a newer profile from the cloud (e.g. on a second device).
  Future<void> _applyProfile(ProfileSnapshot s) async {
    final displayName = s.name.trim().isEmpty ? 'Kullanıcı' : s.name.trim();
    user = UserProfile(
      name: displayName,
      initials: _initialsOf(displayName),
      email: s.email,
      streakDays: 0,
      calorieGoal: s.calorieGoal,
      proteinGoalG: s.proteinGoalG,
      carbsGoalG: s.carbsGoalG,
      fatGoalG: s.fatGoalG,
      heightCm: s.heightCm ?? 0,
      weightKg: s.weightKg ?? user.weightKg,
      goalWeightKg: s.goalWeightKg ?? 0,
    );
    gender = s.gender;
    age = s.age;
    activityLevel = s.activityLevel;
    weightGoal = s.weightGoal;
    weeklyPaceKg = s.weeklyPaceKg ?? weeklyPaceKg;
    allergies = AllergyProfile.decode(s.allergies, s.allergyNote);
    final consentVersion = s.consentVersion, consentAt = s.consentAt;
    if (consentVersion != null && consentAt != null) {
      consent = ConsentRecord(
        version: consentVersion,
        acceptedAt:
            DateTime.fromMillisecondsSinceEpoch(consentAt, isUtc: true).toLocal(),
      );
    }
    setupComplete = true;
    memberSince ??=
        DateTime.fromMillisecondsSinceEpoch(s.createdAt, isUtc: true).toLocal();
    _profileUpdatedAt = s.updatedAt;
    notifyListeners();

    final prefs = await _prefsOrLoad();
    final c = consent;
    await Future.wait([
      prefs.setBool(_kSetupComplete, true),
      // The weight history arrives with full sync (B5); don't let the
      // legacy migration invent a duplicate first entry meanwhile.
      prefs.setBool(_kWeightMigrated, true),
      prefs.setInt(_kProfileUpdatedAt, _profileUpdatedAt),
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
      prefs.setDouble(_kWeeklyPace, weeklyPaceKg),
      prefs.setStringList(_kAllergies, allergies.encodeAllergens()),
      prefs.setString(_kAllergyNote, allergies.otherNote),
      if (gender != null) prefs.setString(_kGender, gender!.name),
      if (age != null) prefs.setInt(_kAge, age!),
      if (activityLevel != null)
        prefs.setString(_kActivity, activityLevel!.name),
      if (weightGoal != null) prefs.setString(_kGoalType, weightGoal!.name),
      if (c != null) prefs.setString(_kConsentVersion, c.version),
      if (c != null) prefs.setString(_kConsentAt, c.acceptedAt.toIso8601String()),
    ]);
  }

  /// Reconciles this device's profile with the cloud (newer wins). Does
  /// nothing unless signed in with the cloud consent given; never throws —
  /// a failed sync is retried on the next trigger. Concurrent calls share
  /// one run (and trigger one more pass if something changed meanwhile).
  Future<void> syncProfile() {
    final backend = syncBackend;
    if (backend == null || !isSignedIn || !hasCloudConsent) {
      return Future.value();
    }
    final running = _profileSync;
    if (running != null) {
      _profileSyncAgain = true;
      return running;
    }
    return _profileSync = () async {
      try {
        do {
          _profileSyncAgain = false;
          final remote = await backend.fetchProfile();
          if (!hasCloudConsent || !isSignedIn) break;
          final local = localProfileSnapshot;
          switch (decideProfileSync(local: local, remote: remote)) {
            case ProfileSyncAction.push:
              await backend.upsertProfile(local!);
            case ProfileSyncAction.pull:
              await _applyProfile(remote!);
            case ProfileSyncAction.none:
              break;
          }
        } while (_profileSyncAgain);
      } catch (e, st) {
        developer.log('Profile sync failed', error: e, stackTrace: st);
      } finally {
        _profileSync = null;
      }
    }();
  }

  /// Ends the session. Local data stays on the device for now; clearing it
  /// on sign-out arrives with sync (CLAUDE.md §13.6, Aşama B6).
  Future<void> signOut() async {
    _syncTimer?.cancel();
    await _syncRun;
    await _auth.signOut();
    notifyListeners();
  }

  /// Called when the app comes back to the foreground.
  Future<void> onResumed() async {
    await rollOverDayIfNeeded();
    await syncNow();
  }

  /// A local write happened: sync after [syncDelay] if anything is dirty.
  void _scheduleSync({Duration? delay}) {
    if (!_syncEnabled) return;
    _syncTimer?.cancel();
    _syncTimer = Timer(delay ?? syncDelay, () async {
      final db = _db;
      // The sync's own "synced" marks also show up as table updates; only
      // start a run when something actually still has to go out.
      if (db == null || !await _hasDirtyRows(db)) return;
      unawaited(syncNow());
    });
  }

  static Future<bool> _hasDirtyRows(AppDatabase db) async {
    for (final table in db.userTables) {
      if ((await db.syncDao.dirtyRows(table, limit: 1)).isNotEmpty) return true;
    }
    return false;
  }

  /// Runs a full sync now (profile, then local changes). Never throws; the
  /// outcome is in [syncStatus]. A failure is retried with growing pauses
  /// (30 s, 1 min, 2 min … up to 15 min). Concurrent calls share one run.
  Future<void> syncNow() {
    final backend = syncBackend;
    if (backend == null || !_syncEnabled) {
      notifyListeners();
      return Future.value();
    }
    final running = _syncRun;
    if (running != null) {
      _syncAgain = true;
      return running;
    }
    _syncTimer?.cancel();
    return _syncRun = () async {
      _syncStatus = SyncStatus.syncing;
      notifyListeners();
      try {
        do {
          _syncAgain = false;
          await syncProfile();
          final db = _db;
          if (db != null && _syncEnabled) {
            final result = await SyncEngine(db, backend).push();
            if (result.failed > 0) {
              developer.log('${result.failed} rows rejected by the server');
            }
          }
        } while (_syncAgain && _syncEnabled);
        _syncFailures = 0;
        _syncStatus = SyncStatus.upToDate;
        lastSyncedAt = clock();
        final prefs = await _prefsOrLoad();
        await prefs.setString(_kLastSyncedAt, lastSyncedAt!.toIso8601String());
      } catch (e, st) {
        developer.log('Sync failed', error: e, stackTrace: st);
        _syncFailures++;
        _syncStatus = SyncStatus.error;
        final backoff = Duration(seconds: 30 * (1 << (_syncFailures - 1).clamp(0, 5)));
        _scheduleRetry(backoff < const Duration(minutes: 15)
            ? backoff
            : const Duration(minutes: 15));
      } finally {
        _syncRun = null;
        notifyListeners();
      }
    }();
  }

  void _scheduleRetry(Duration delay) {
    _syncTimer?.cancel();
    _syncTimer = Timer(delay, () => unawaited(syncNow()));
  }

  /// Throws [AuthFailure].
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email.trim());

  /// Throws [AuthFailure].
  Future<void> updatePassword(String newPassword) =>
      _auth.updatePassword(newPassword);

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
    await _touchProfile();
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
    gender = enumByName(Gender.values, prefs.getString(_kGender));
    age = prefs.getInt(_kAge);
    activityLevel = enumByName(ActivityLevel.values, prefs.getString(_kActivity));
    weightGoal = enumByName(WeightGoal.values, prefs.getString(_kGoalType));
    notificationSettings =
        NotificationSettings.fromJson(prefs.getString(_kNotifications));
    _profileUpdatedAt = prefs.getInt(_kProfileUpdatedAt) ?? 0;
    _cloudConsentVersion = prefs.getString(_kCloudConsentVersion);
    final cloudAt = prefs.getString(_kCloudConsentAt);
    cloudConsentAt = cloudAt == null ? null : DateTime.tryParse(cloudAt);
    final syncedAt = prefs.getString(_kLastSyncedAt);
    lastSyncedAt = syncedAt == null ? null : DateTime.tryParse(syncedAt);
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
    unawaited(syncNow());
    if (notificationSettings.anyEnabled) {
      // Re-schedule on every launch (time zone or OS state may have
      // changed); never prompts — permission was asked when turned on.
      try {
        await reminders.apply(notificationSettings);
      } catch (e, st) {
        developer.log('Scheduling reminders failed', error: e, stackTrace: st);
      }
    }
  }

  static String _initialsOf(String displayName) {
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return initials.isEmpty ? '?' : initials;
  }

  Future<SharedPreferences> _prefsOrLoad() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Saves the "Kişisel bilgiler" screen. Calorie and macro goals are left
  /// alone; the goals screen offers to recalculate them.
  Future<void> updatePersonalInfo({
    required String name,
    required String email,
    required Gender? gender,
    required int? age,
    required double heightCm,
    required ActivityLevel? activityLevel,
  }) async {
    final displayName = name.trim().isEmpty ? 'Kullanıcı' : name.trim();
    user = user.copyWith(
      name: displayName,
      initials: _initialsOf(displayName),
      email: email.trim(),
      heightCm: heightCm,
    );
    this.gender = gender;
    this.age = age;
    this.activityLevel = activityLevel;
    notifyListeners();

    final prefs = await _prefsOrLoad();
    await Future.wait([
      prefs.setString(_kName, user.name),
      prefs.setString(_kInitials, user.initials),
      prefs.setString(_kEmail, user.email),
      prefs.setDouble(_kHeight, heightCm),
      if (gender != null) prefs.setString(_kGender, gender.name),
      if (age != null) prefs.setInt(_kAge, age),
      if (activityLevel != null) prefs.setString(_kActivity, activityLevel.name),
    ]);
    await _touchProfile();
  }

  /// The goals the setup formula gives for the stored profile, or null
  /// while gender, age or activity level is unknown.
  NutritionTargets? suggestedTargets({
    required WeightGoal goal,
    required double weeklyPaceKg,
  }) {
    final g = gender, a = age, act = activityLevel;
    if (g == null || a == null || act == null) return null;
    if (user.weightKg <= 0 || user.heightCm <= 0) return null;
    return computeTargets(
      gender: g,
      age: a,
      heightCm: user.heightCm,
      weightKg: user.weightKg,
      activity: act,
      goal: goal,
      weeklyPaceKg: weeklyPaceKg,
    );
  }

  /// Saves the "Hedefler ve makrolar" screen.
  Future<void> updateGoals({
    required WeightGoal goal,
    required double goalWeightKg,
    required double weeklyPaceKg,
    required int calorieGoal,
    required int proteinG,
    required int carbsG,
    required int fatG,
  }) async {
    weightGoal = goal;
    this.weeklyPaceKg = weeklyPaceKg;
    user = user.copyWith(
      goalWeightKg: goalWeightKg,
      calorieGoal: calorieGoal,
      proteinGoalG: proteinG,
      carbsGoalG: carbsG,
      fatGoalG: fatG,
    );
    notifyListeners();

    final prefs = await _prefsOrLoad();
    await Future.wait([
      prefs.setString(_kGoalType, goal.name),
      prefs.setDouble(_kGoalWeight, goalWeightKg),
      prefs.setDouble(_kWeeklyPace, weeklyPaceKg),
      prefs.setInt(_kCalorieGoal, calorieGoal),
      prefs.setInt(_kProteinGoal, proteinG),
      prefs.setInt(_kCarbsGoal, carbsG),
      prefs.setInt(_kFatGoal, fatG),
    ]);
    await _touchProfile();
  }

  /// Saves reminder choices and (re)schedules them. Turning anything on
  /// asks for the notification permission; returns false when it was
  /// denied (the choice is still saved so it works once allowed in system
  /// settings). Throws if scheduling itself fails.
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    final granted =
        settings.anyEnabled ? await reminders.requestPermission() : true;
    notificationSettings = settings;
    notifyListeners();
    final prefs = await _prefsOrLoad();
    await prefs.setString(_kNotifications, settings.toJson());
    await reminders.apply(settings);
    return granted;
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
    gender = null;
    age = null;
    activityLevel = null;
    weightGoal = null;
    notificationSettings = const NotificationSettings();
    _profileUpdatedAt = 0;
    _cloudConsentVersion = null;
    cloudConsentAt = null;
    _syncTimer?.cancel();
    lastSyncedAt = null;
    _syncStatus = SyncStatus.pending;
    try {
      await reminders.apply(notificationSettings); // cancels everything
    } catch (e, st) {
      developer.log('Cancelling reminders failed', error: e, stackTrace: st);
    }
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
        await db.purgeSoftDeleted(clock(), requireSynced: isSignedIn);
      } catch (e, st) {
        // Housekeeping only; never block the app on it.
        developer.log('Purging old deleted rows failed',
            error: e, stackTrace: st);
      }
      _db = db;
      await _tablesSub?.cancel();
      _tablesSub = db
          .tableUpdates(TableUpdateQuery.onAllTables(db.userTables))
          .listen((_) => _scheduleSync());
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
    _syncTimer?.cancel();
    _tablesSub?.cancel();
    _authSub?.cancel();
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
    await _touchProfile();
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

    final targets = computeTargets(
      gender: draft.gender,
      age: draft.age,
      heightCm: heightCm,
      weightKg: weightKg,
      activity: draft.activityLevel,
      goal: draft.goal,
      weeklyPaceKg: draft.weeklyPaceKg,
    );

    final trimmedName = draft.name.trim();
    final displayName = trimmedName.isEmpty ? 'Kullanıcı' : trimmedName;

    user = UserProfile(
      name: displayName,
      initials: _initialsOf(displayName),
      email: draft.email.trim(),
      streakDays: 0,
      calorieGoal: targets.calories,
      proteinGoalG: targets.proteinG,
      carbsGoalG: targets.carbsG,
      fatGoalG: targets.fatG,
      heightCm: heightCm,
      weightKg: weightKg,
      goalWeightKg: goalWeightKg,
    );
    setupComplete = true;
    weeklyPaceKg = draft.weeklyPaceKg;
    gender = draft.gender;
    age = draft.age;
    activityLevel = draft.activityLevel;
    weightGoal = draft.goal;
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
      prefs.setString(_kGender, draft.gender.name),
      prefs.setInt(_kAge, draft.age),
      prefs.setString(_kActivity, draft.activityLevel.name),
      prefs.setString(_kGoalType, draft.goal.name),
    ]);
    await _touchProfile();
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
