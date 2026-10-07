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
}
