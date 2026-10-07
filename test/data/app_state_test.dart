import 'package:denge/data/app_state.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
