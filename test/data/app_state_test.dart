import 'package:denge/data/app_state.dart';
import 'package:denge/data/auth.dart';
import 'package:denge/data/custom_food.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/health_consent.dart';
import 'package:denge/data/models.dart';
import 'package:denge/data/reminders.dart';
import 'package:denge/data/sync/profile_snapshot.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_reminder_scheduler.dart';
import '../helpers/fake_sync_backend.dart';
import 'food_log_entry_test.dart' show menemen;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 10, 7, 12);
  });

  Future<AppState> loaded({AppDatabase? db, bool autoDispose = true}) async {
    final state = AppState.forTesting()..clock = () => now;
    if (autoDispose) addTearDown(state.dispose);
    await state.load(db: db);
    return state;
  }

  AppDatabase memoryDb() {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  test('loads without a database (existing widget tests rely on this)',
      () async {
    final state = await loaded();
    expect(state.hasDatabase, isFalse);
    expect(state.storageError, isNull);
    expect(state.caloriesConsumedToday, 0);
  });

  test('attaches a database during load', () async {
    final state = await loaded(db: memoryDb());
    expect(state.hasDatabase, isTrue);
    expect(state.storageError, isNull);
  });

  group('diary', () {
    test('addFoodToMeal raises calories and macros (no database)', () async {
      final state = await loaded();
      await state.addFoodToMeal(MealType.breakfast, menemen, 2);
      expect(state.caloriesConsumedToday, 240);
      expect(state.proteinConsumedG, closeTo(13, 1e-9));
      expect(state.todayEntries, hasLength(1));
    });

    test('addFoodToMeal raises calories and is still there after reload',
        () async {
      final db = memoryDb();
      final first = await loaded(db: db, autoDispose: false);
      await first.addFoodToMeal(MealType.breakfast, menemen, 1);
      await first.addFoodToMeal(MealType.dinner, menemen, 0.5);
      expect(first.caloriesConsumedToday, 180);
      first.dispose();

      final second = await loaded(db: db);
      expect(second.caloriesConsumedToday, 180);
      expect(second.todayEntries.map((e) => e.meal),
          [MealType.breakfast, MealType.dinner]);
    });

    test('todaysMeals keeps its legacy shape', () async {
      final state = await loaded(db: memoryDb());
      expect(state.todaysMeals, hasLength(4));
      expect(state.todaysMeals.every((m) => !m.logged), isTrue);
      expect(state.todaysMeals.first.title, 'Kahvaltı');

      await state.addFoodToMeal(MealType.breakfast, menemen, 1);
      await state.addFoodToMeal(
          MealType.breakfast,
          const FoodItem(
              name: 'Simit', brand: '', caloriesPer100g: 280,
              proteinG: 9, carbsG: 55, fatG: 3),
          1);
      final breakfast =
          state.todaysMeals.firstWhere((m) => m.type == MealType.breakfast);
      expect(breakfast.logged, isTrue);
      expect(breakfast.description, 'Menemen, Simit');
      expect(breakfast.calories, 400);
      expect(state.hasLoggedFoodToday, isTrue);
    });

    test('entries from yesterday are not counted today', () async {
      final db = memoryDb();
      now = DateTime(2026, 10, 6, 22);
      final yesterday = await loaded(db: db, autoDispose: false);
      await yesterday.addFoodToMeal(MealType.dinner, menemen, 1);
      yesterday.dispose();

      now = DateTime(2026, 10, 7, 8);
      final today = await loaded(db: db);
      expect(today.caloriesConsumedToday, 0);
      final past =
          await today.watchEntriesForDate(DateTime(2026, 10, 6)).first;
      expect(past, hasLength(1));
    });

    test('rolls over to the new day when the app stays open past midnight',
        () async {
      now = DateTime(2026, 10, 7, 23, 50);
      final state = await loaded(db: memoryDb());
      await state.addFoodToMeal(MealType.snack, menemen, 1);
      expect(state.caloriesConsumedToday, 120);

      now = DateTime(2026, 10, 8, 0, 5);
      await state.rollOverDayIfNeeded();
      expect(state.caloriesConsumedToday, 0);

      await state.addFoodToMeal(MealType.breakfast, menemen, 1);
      expect(state.todayEntries.single.date, '2026-10-08');
    });
  });

  group('edit diary', () {
    for (final withDb in [true, false]) {
      final label = withDb ? 'database' : 'in memory';

      test('deleted entry leaves the totals, undo brings it back ($label)',
          () async {
        final state = await loaded(db: withDb ? memoryDb() : null);
        await state.addFoodToMeal(MealType.lunch, menemen, 1);
        await state.addFoodToMeal(MealType.lunch, menemen, 2);
        expect(state.caloriesConsumedToday, 360);

        final first = state.todayEntries.first;
        await state.deleteEntry(first.id);
        expect(state.caloriesConsumedToday, 240);
        expect(state.todayEntries, hasLength(1));

        await state.restoreEntry(first.id);
        expect(state.caloriesConsumedToday, 360);
        expect(state.todayEntries.first.id, first.id);
      });

      test('updating amount and meal rescales macros ($label)', () async {
        final state = await loaded(db: withDb ? memoryDb() : null);
        await state.addFoodToMeal(MealType.lunch, menemen, 1);
        final id = state.todayEntries.single.id;

        await state.updateEntry(id, amount: 1.5, meal: MealType.dinner);
        final e = state.todayEntries.single;
        expect(e.amount, 1.5);
        expect(e.meal, MealType.dinner);
        expect(e.kcal, 180);
        expect(state.proteinConsumedG, closeTo(9.75, 1e-9));
        expect(state.todaySummary.meal(MealType.lunch).entries, isEmpty);
      });
    }
  });

  group('water', () {
    test('survives a reload and a new day starts at 0', () async {
      final db = memoryDb();
      final first = await loaded(db: db, autoDispose: false);
      await first.setWaterGlasses(4);
      expect(first.waterGlasses, 4);
      first.dispose();

      final second = await loaded(db: db, autoDispose: false);
      expect(second.waterGlasses, 4);

      now = DateTime(2026, 10, 8, 0, 10);
      await second.rollOverDayIfNeeded();
      expect(second.waterGlasses, 0);
      second.dispose();

      now = DateTime(2026, 10, 7, 18);
      final back = await loaded(db: db);
      expect(back.waterGlasses, 4, reason: 'the old day is untouched');
    });

    test('is clamped to the goal', () async {
      final state = await loaded(db: memoryDb());
      await state.setWaterGlasses(99);
      expect(state.waterGlasses, 10);
      await state.setWaterGlasses(-3);
      expect(state.waterGlasses, 0);
    });
  });

  group('weight', () {
    test('logWeight persists and updates the profile weight', () async {
      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_weight': 80.0,
        'weight_history_migrated': true,
      });
      final db = memoryDb();
      final first = await loaded(db: db, autoDispose: false);
      await first.logWeight(79.2);
      expect(first.user.weightKg, 79.2);
      first.dispose();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('user_weight'), 79.2);

      final second = await loaded(db: db);
      expect(second.weightHistory.map((e) => e.kg), [79.2]);
      expect(second.user.weightKg, 79.2);
    });

    test('completeSetup records the setup weight as the first entry',
        () async {
      final db = memoryDb();
      final state = await loaded(db: db);
      state.draft.weightKg = 66;
      await state.completeSetup();
      expect(state.weightHistory.map((e) => e.kg), [66]);
      expect((await db.weightDao.history()).single.kg, 66);
      expect(state.weightHistory.single.date, now);
    });

    test('existing users get their profile weight migrated exactly once',
        () async {
      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_weight': 82.5,
      });
      final db = memoryDb();
      final first = await loaded(db: db, autoDispose: false);
      expect(first.weightHistory.map((e) => e.kg), [82.5]);
      first.dispose();

      // A second launch must not add another copy.
      final second = await loaded(db: db);
      expect(second.weightHistory, hasLength(1));
      final rows = await db.weightDao.history();
      expect(rows.single.date, '2026-10-07');
    });

    test('migration does not run before setup is complete', () async {
      final db = memoryDb();
      await loaded(db: db);
      expect(await db.weightDao.history(), isEmpty);
    });
  });

  group('streak', () {
    test('counts consecutive logged days and ignores the old pref',
        () async {
      SharedPreferences.setMockInitialValues({'user_streak': 42});
      final db = memoryDb();
      for (final day in [4, 5, 6]) {
        now = DateTime(2026, 10, day, 12);
        final s = await loaded(db: db, autoDispose: false);
        await s.addFoodToMeal(MealType.lunch, menemen, 1);
        s.dispose();
      }

      now = DateTime(2026, 10, 7, 8);
      final state = await loaded(db: db);
      expect(state.streakDays, 3, reason: 'today not logged yet');
      expect(state.loggedDaysCount, 3);

      await state.addFoodToMeal(MealType.breakfast, menemen, 1);
      expect(state.streakDays, 4);
      expect(state.loggedDaysCount, 4);

      await state.deleteEntry(state.todayEntries.single.id);
      expect(state.streakDays, 3);
    });

    test('a skipped day resets the streak', () async {
      final db = memoryDb();
      now = DateTime(2026, 10, 4, 12);
      final s = await loaded(db: db, autoDispose: false);
      await s.addFoodToMeal(MealType.lunch, menemen, 1);
      s.dispose();

      now = DateTime(2026, 10, 6, 12);
      final state = await loaded(db: db);
      expect(state.streakDays, 0);
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
      expect(state.streakDays, 1);
    });

    test('without a database only today counts', () async {
      final state = await loaded();
      expect(state.streakDays, 0);
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
      expect(state.streakDays, 1);
      expect(state.loggedDaysCount, 1);
    });
  });

  group('custom foods', () {
    const draft = CustomFood(
      id: '',
      name: 'Annemin böreği',
      servingLabel: '1 dilim',
      kcalPerServing: 310,
      proteinG: 9,
      carbsG: 30,
      fatG: 17,
      category: FoodCategory.hamurIsi,
      barcode: '8690000000001',
    );

    for (final withDb in [true, false]) {
      final label = withDb ? 'database' : 'in memory';

      test('add, find by barcode, update and delete ($label)', () async {
        final state = await loaded(db: withDb ? memoryDb() : null);
        final saved = await state.addCustomFood(draft);
        expect(saved.id, isNotEmpty);
        expect(state.customFoods.map((f) => f.name), ['Annemin böreği']);
        expect(state.customFoodForBarcode('8690000000001')?.id, saved.id);
        expect(state.customFoodForBarcode('000'), isNull);

        await state.updateCustomFood(saved.copyWith(kcalPerServing: 300));
        expect(state.customFoods.single.kcalPerServing, 300);

        await state.deleteCustomFood(saved.id);
        expect(state.customFoods, isEmpty);
        expect(state.customFoodForBarcode('8690000000001'), isNull);
      });
    }

    test('saved foods are there after a reload and can be logged', () async {
      final db = memoryDb();
      final first = await loaded(db: db, autoDispose: false);
      final saved = await first.addCustomFood(draft);
      first.dispose();

      final second = await loaded(db: db);
      expect(second.customFoods.single.id, saved.id);
      await second.addFoodToMeal(
          MealType.lunch, second.customFoods.single.asFoodItem, 1,
          source: FoodLogSource.custom, sourceRef: saved.id);
      expect(second.caloriesConsumedToday, 310);
      expect(second.todayEntries.single.sourceRef, saved.id);
    });
  });

  group('data management', () {
    test('deleteAllData empties every table and returns to first launch',
        () async {
      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_name': 'Ayşe',
        'user_weight': 70.0,
        'theme_mode': 'dark',
        'favorite_recipes': ['Mercimek çorbası'],
        'consent_version': '1',
        'consent_at': '2026-10-01T10:00:00.000',
      });
      final db = memoryDb();
      final state = await loaded(db: db);
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
      await state.setWaterGlasses(5);
      await state.logWeight(69.5);
      await state.addCustomFood(const CustomFood(
          id: '', name: 'Börek', servingLabel: '1', kcalPerServing: 300,
          proteinG: 0, carbsG: 0, fatG: 0, category: FoodCategory.tatli));
      final deleted = state.todayEntries.single.id;
      await state.deleteEntry(deleted); // a soft-deleted row is wiped too
      state.draft.name = 'Taslak';

      await state.deleteAllData();

      for (final table in db.allTables) {
        expect(await db.select(table).get(), isEmpty,
            reason: table.actualTableName);
      }
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);

      expect(state.setupComplete, isFalse);
      expect(state.user.name, '');
      expect(state.hasConsent, isFalse);
      expect(state.themeMode, ThemeMode.light);
      expect(state.favoriteRecipes, isEmpty);
      expect(state.todayEntries, isEmpty);
      expect(state.caloriesConsumedToday, 0);
      expect(state.waterGlasses, 0);
      expect(state.weightHistory, isEmpty);
      expect(state.customFoods, isEmpty);
      expect(state.streakDays, 0);
      expect(state.draft.name, '');
      expect(state.hasDatabase, isTrue, reason: 'the app keeps working');

      // And a migration must not resurrect the old weight on next launch.
      final relaunched = await loaded(db: db);
      expect(relaunched.weightHistory, isEmpty);
    });

    test('works without a database too', () async {
      SharedPreferences.setMockInitialValues({'setup_complete': true});
      final state = await loaded();
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
      await state.deleteAllData();
      expect(state.setupComplete, isFalse);
      expect(state.todayEntries, isEmpty);
    });

    test('load purges rows soft-deleted more than 30 days ago', () async {
      final db = memoryDb();
      now = DateTime(2026, 9, 1, 12);
      final old = await loaded(db: db, autoDispose: false);
      await old.addFoodToMeal(MealType.lunch, menemen, 1);
      await old.deleteEntry(old.todayEntries.single.id);
      old.dispose();
      expect(await db.select(db.foodLogEntries).get(), hasLength(1));

      now = DateTime(2026, 9, 20, 12);
      (await loaded(db: db, autoDispose: false)).dispose();
      expect(await db.select(db.foodLogEntries).get(), hasLength(1),
          reason: 'only 19 days old');

      now = DateTime(2026, 10, 7, 12);
      await loaded(db: db);
      expect(await db.select(db.foodLogEntries).get(), isEmpty);
    });
  });

  group('profile menus', () {
    Future<AppState> setUpUser({AppDatabase? db}) async {
      final state = await loaded(db: db);
      state.draft
        ..name = 'Ayşe Yılmaz'
        ..gender = Gender.female
        ..age = 27
        ..heightCm = 168
        ..weightKg = 70
        ..activityLevel = ActivityLevel.moderate
        ..goal = WeightGoal.lose
        ..weeklyPaceKg = 0.5;
      await state.completeSetup();
      return state;
    }

    test('setup now remembers gender, age, activity and goal type', () async {
      final state = await setUpUser();
      expect(state.user.calorieGoal, 1704, reason: 'same maths as before');
      final again = await loaded();
      expect(again.gender, Gender.female);
      expect(again.age, 27);
      expect(again.activityLevel, ActivityLevel.moderate);
      expect(again.weightGoal, WeightGoal.lose);
    });

    test('updatePersonalInfo persists and refreshes the initials', () async {
      await setUpUser();
      final state = await loaded();
      await state.updatePersonalInfo(
        name: '  Mehmet Can Demir ',
        email: 'mehmet@ornek.com',
        gender: Gender.male,
        age: 31,
        heightCm: 181.5,
        activityLevel: ActivityLevel.active,
      );
      expect(state.user.name, 'Mehmet Can Demir');
      expect(state.user.initials, 'MC');

      final again = await loaded();
      expect(again.user.name, 'Mehmet Can Demir');
      expect(again.user.email, 'mehmet@ornek.com');
      expect(again.user.heightCm, 181.5);
      expect(again.gender, Gender.male);
      expect(again.age, 31);
      expect(again.activityLevel, ActivityLevel.active);
      expect(again.user.calorieGoal, 1704,
          reason: 'goals only change from the goals screen');
    });

    test('suggestedTargets uses the stored profile, null when incomplete',
        () async {
      final state = await setUpUser();
      final t = state.suggestedTargets(
          goal: WeightGoal.maintain, weeklyPaceKg: 0.5)!;
      expect(t.calories, 2254);

      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_weight': 70.0,
        'user_height': 168.0,
      });
      final legacy = await loaded();
      expect(legacy.gender, isNull);
      expect(
          legacy.suggestedTargets(goal: WeightGoal.lose, weeklyPaceKg: 0.5),
          isNull);
    });

    test('updateGoals persists goal type, weight, pace, kcal and macros',
        () async {
      await setUpUser();
      final state = await loaded();
      await state.updateGoals(
        goal: WeightGoal.gain,
        goalWeightKg: 74,
        weeklyPaceKg: 0.25,
        calorieGoal: 2500,
        proteinG: 140,
        carbsG: 300,
        fatG: 80,
      );
      final again = await loaded();
      expect(again.weightGoal, WeightGoal.gain);
      expect(again.user.goalWeightKg, 74);
      expect(again.weeklyPaceKg, 0.25);
      expect(again.user.calorieGoal, 2500);
      expect(
          (again.user.proteinGoalG, again.user.carbsGoalG, again.user.fatGoalG),
          (140, 300, 80));
    });

    test('effectiveGoal falls back to the weights when the type is unknown',
        () async {
      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_weight': 80.0,
        'user_goal_weight': 72.0,
      });
      expect((await loaded()).effectiveGoal, WeightGoal.lose);
      SharedPreferences.setMockInitialValues({
        'setup_complete': true,
        'user_weight': 80.0,
        'user_goal_weight': 80.2,
      });
      expect((await loaded()).effectiveGoal, WeightGoal.maintain);
    });
  });

  group('notifications', () {
    test('enabling asks for permission, saves and schedules', () async {
      final fake = FakeReminderScheduler();
      final state = await loaded();
      state.reminders = fake;

      final granted = await state.updateNotificationSettings(
          const NotificationSettings(mealReminders: true));
      expect(granted, isTrue);
      expect(fake.permissionRequests, 1);
      expect(fake.applied.last.mealReminders, isTrue);

      final again = await loaded();
      expect(again.notificationSettings.mealReminders, isTrue);
    });

    test('a denied permission is reported but the choice is kept', () async {
      final fake = FakeReminderScheduler()..grant = false;
      final state = await loaded();
      state.reminders = fake;
      final granted = await state.updateNotificationSettings(
          const NotificationSettings(waterReminders: true));
      expect(granted, isFalse);
      expect(state.notificationSettings.waterReminders, isTrue);
    });

    test('turning everything off does not ask for permission', () async {
      final fake = FakeReminderScheduler();
      final state = await loaded();
      state.reminders = fake;
      await state.updateNotificationSettings(const NotificationSettings());
      expect(fake.permissionRequests, 0);
      expect(fake.applied.single.anyEnabled, isFalse);
    });

    test('saved reminders are re-scheduled on launch without a prompt',
        () async {
      SharedPreferences.setMockInitialValues({
        'notification_settings':
            const NotificationSettings(weeklySummary: true).toJson(),
      });
      final fake = FakeReminderScheduler();
      final state = AppState.forTesting()
        ..clock = (() => now)
        ..reminders = fake;
      addTearDown(state.dispose);
      await state.load();
      expect(fake.applied.single.weeklySummary, isTrue);
      expect(fake.permissionRequests, 0);
    });

    test('deleteAllData cancels every reminder', () async {
      final fake = FakeReminderScheduler();
      final state = await loaded();
      state.reminders = fake;
      await state.updateNotificationSettings(const NotificationSettings(
          mealReminders: true, waterReminders: true));
      await state.deleteAllData();
      expect(state.notificationSettings.anyEnabled, isFalse);
      expect(fake.applied.last.anyEnabled, isFalse);
    });
  });

  group('account', () {
    late FakeAuthService auth;

    Future<AppState> withAuth() async {
      auth = FakeAuthService();
      final state = AppState.forTesting()
        ..clock = (() => now)
        ..auth = auth;
      addTearDown(state.dispose);
      await state.load();
      return state;
    }

    test('without Supabase configured the app reports no account system',
        () async {
      final state = await loaded();
      expect(state.accountsAvailable, isFalse);
      expect(state.account, isNull);
    });

    test('sign up keeps name and e-mail for the setup wizard', () async {
      final state = await withAuth();
      final result = await state.signUp(
          name: ' Ayşe Yılmaz ', email: ' ayse@ornek.com ', password: 'sifre123');
      expect(result, SignUpResult.signedIn);
      expect(state.account?.email, 'ayse@ornek.com');
      expect(state.draft.name, 'Ayşe Yılmaz');
      expect(state.draft.email, 'ayse@ornek.com');
    });

    test('sign in prefills the wizard when this device has no profile',
        () async {
      final state = await withAuth();
      auth.addUser('can@ornek.com', 'sifre123', name: 'Can');
      await state.signIn(email: 'can@ornek.com', password: 'sifre123');
      expect(state.isSignedIn, isTrue);
      expect(state.draft.name, 'Can');
      expect(state.draft.email, 'can@ornek.com');
    });

    test('auth events refresh listeners; sign out clears the account',
        () async {
      final state = await withAuth();
      auth.addUser('can@ornek.com', 'sifre123');
      var notified = 0;
      state.addListener(() => notified++);
      await state.signIn(email: 'can@ornek.com', password: 'sifre123');
      await state.signOut();
      await pumpEventQueue();
      expect(state.isSignedIn, isFalse);
      expect(notified, greaterThanOrEqualTo(2));
    });

    test('a password-recovery link raises a one-shot flag', () async {
      final state = await withAuth();
      auth.emitPasswordRecovery();
      await pumpEventQueue();
      expect(state.takePendingPasswordRecovery(), isTrue);
      expect(state.takePendingPasswordRecovery(), isFalse);
    });

    test('failures surface as AuthFailure', () async {
      final state = await withAuth();
      await expectLater(
        state.signIn(email: 'kimse@ornek.com', password: 'sifre123'),
        throwsA(isA<AuthFailure>().having(
            (f) => f.code, 'code', AuthFailureCode.invalidCredentials)),
      );
    });

    test('signing out keeps the local diary (B6 handles cleanup)', () async {
      final state = await withAuth();
      auth.addUser('can@ornek.com', 'sifre123');
      await state.signIn(email: 'can@ornek.com', password: 'sifre123');
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
      await state.signOut();
      expect(state.todayEntries, hasLength(1));
    });
  });

  group('profile sync (B3)', () {
    late FakeAuthService auth;
    late FakeSyncBackend cloud;

    Future<AppState> syncing({bool signIn = true, bool consent = true}) async {
      auth = FakeAuthService()..addUser('ayse@ornek.com', 'sifre123');
      final state = AppState.forTesting()
        ..clock = (() => now)
        ..auth = auth
        ..syncBackend = cloud;
      addTearDown(state.dispose);
      await state.load();
      if (signIn) {
        await state.signIn(email: 'ayse@ornek.com', password: 'sifre123');
      }
      if (consent) await state.giveCloudConsent();
      return state;
    }

    Future<void> completeSetup(AppState state) async {
      state.draft
        ..name = 'Ayşe'
        ..gender = Gender.female
        ..age = 27
        ..heightCm = 168
        ..weightKg = 70
        ..activityLevel = ActivityLevel.moderate
        ..goal = WeightGoal.lose
        ..weeklyPaceKg = 0.5;
      await state.completeSetup();
    }

    setUp(() => cloud = FakeSyncBackend());

    test('nothing is sent without the cloud consent', () async {
      final state = await syncing(consent: false);
      await completeSetup(state);
      await state.syncProfile();
      expect(cloud.fetches + cloud.pushes, 0);
      expect(state.hasCloudConsent, isFalse);
    });

    test('nothing is sent while signed out', () async {
      final state = await syncing(signIn: false);
      await completeSetup(state);
      await state.syncProfile();
      expect(cloud.fetches + cloud.pushes, 0);
    });

    test('a profile made on this device is pushed', () async {
      final state = await syncing();
      await completeSetup(state);
      await state.syncProfile();
      expect(cloud.profile?.calorieGoal, 1704);
      expect(cloud.profile?.gender, Gender.female);
      expect(cloud.profile?.weightKg, 70);
    });

    test('a fresh device pulls the profile, goals and health consent',
        () async {
      cloud.profile = ProfileSnapshot(
        createdAt: 1,
        updatedAt: 2,
        name: 'Ayşe',
        email: 'ayse@ornek.com',
        gender: Gender.female,
        age: 27,
        heightCm: 168,
        weightKg: 69.5,
        activityLevel: ActivityLevel.light,
        weightGoal: WeightGoal.lose,
        goalWeightKg: 64,
        weeklyPaceKg: 0.25,
        calorieGoal: 1650,
        proteinGoalG: 125,
        carbsGoalG: 170,
        fatGoalG: 50,
        allergies: const ['gluten'],
        allergyNote: '',
        consentVersion: kConsentVersion,
        consentAt: DateTime(2026, 9, 1).millisecondsSinceEpoch,
      );
      final state = await syncing();
      await state.syncProfile();

      expect(state.setupComplete, isTrue);
      expect(state.user.calorieGoal, 1650);
      expect(state.user.weightKg, 69.5);
      expect(state.activityLevel, ActivityLevel.light);
      expect(state.hasConsent, isTrue);
      expect(state.allergies.allergens.map((a) => a.name), ['gluten']);

      // ...and it survives a restart.
      final again = await loaded();
      expect(again.setupComplete, isTrue);
      expect(again.user.calorieGoal, 1650);
    });

    test('later edits are pushed; the newer side wins', () async {
      final state = await syncing();
      await completeSetup(state);
      await state.syncProfile();

      now = now.add(const Duration(minutes: 5));
      await state.updateGoals(
        goal: WeightGoal.lose,
        goalWeightKg: 63,
        weeklyPaceKg: 0.5,
        calorieGoal: 1600,
        proteinG: 120,
        carbsG: 170,
        fatG: 50,
      );
      await state.syncProfile();
      expect(cloud.profile?.calorieGoal, 1600);

      // Another device changed it later still.
      cloud.profile = cloud.profile!.copyWith(
          calorieGoal: 1550,
          updatedAt: cloud.profile!.updatedAt + 60000);
      await state.syncProfile();
      expect(state.user.calorieGoal, 1550);
    });

    test('a failing cloud never breaks the app', () async {
      final state = await syncing();
      await completeSetup(state);
      cloud.failWith = Exception('offline');
      await state.syncProfile(); // must not throw
      expect(state.user.calorieGoal, 1704);
    });

    test('revoking the cloud consent stops syncing', () async {
      final state = await syncing();
      await state.revokeCloudConsent();
      await completeSetup(state);
      await state.syncProfile();
      expect(cloud.pushes, 0);
      expect((await loaded()).hasCloudConsent, isFalse);
    });
  });
}
