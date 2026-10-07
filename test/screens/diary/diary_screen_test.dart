import 'package:denge/data/app_state.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:denge/data/models.dart';
import 'package:denge/screens/diary/diary_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/food_log_entry_test.dart' show menemen;

void main() {
  late AppDatabase db;
  late AppState state;
  late DateTime now;

  // Each test opens its own in-memory database.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    state = AppState.forTesting()..clock = () => now;
  });

  Future<void> pumpDiary(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(theme: AppTheme.light(), home: const DiaryScreen()),
      ),
    );
    await tester.pump();
  }

  /// Builds the StreamBuilder, lets the real database answer, then
  /// rebuilds with the data.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }

  Future<void> tearDownDb(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    // Let drift's stream-close timers fire inside the fake clock; the
    // in-memory database itself is simply dropped.
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('shows a previous day\'s entries after switching to it',
      (tester) async {
    await tester.runAsync(() async {
      now = DateTime(2026, 10, 6, 20); // Tuesday
      await state.load(db: db);
      await state.addFoodToMeal(MealType.dinner, menemen, 1);
      now = DateTime(2026, 10, 7, 9); // Wednesday
      await state.rollOverDayIfNeeded();
    });

    await pumpDiary(tester);
    expect(find.textContaining('Menemen'), findsNothing);

    await tester.tap(find.text('6'));
    await settle(tester);

    expect(find.text('Menemen'), findsOneWidget);
    expect(find.text('6 Ekim'), findsOneWidget);

    await tearDownDb(tester);
  });

  testWidgets('a past day with nothing logged shows the empty state',
      (tester) async {
    await tester.runAsync(() async {
      now = DateTime(2026, 10, 7, 9);
      await state.load(db: db);
    });
    await pumpDiary(tester);
    await tester.tap(find.text('5'));
    await settle(tester);

    expect(find.text('Tabağın henüz boş'), findsOneWidget);

    await tearDownDb(tester);
  });

  group('editing today (in memory)', () {
    late AppState memState;

    Future<void> pumpWithEntry(WidgetTester tester) async {
      memState = AppState.forTesting()..clock = () => DateTime(2026, 10, 7, 9);
      await tester.runAsync(() async {
        await memState.load();
        await memState.addFoodToMeal(MealType.breakfast, menemen, 1);
      });
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: memState,
          child:
              MaterialApp(theme: AppTheme.light(), home: const DiaryScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('each food is its own row with serving and kcal',
        (tester) async {
      await pumpWithEntry(tester);
      expect(find.text('Menemen'), findsOneWidget);
      expect(find.text('1 × 1 porsiyon (200 g)'), findsOneWidget);
      expect(find.text('120 kcal'), findsOneWidget);
    });

    testWidgets('swipe deletes the row, Geri al restores it', (tester) async {
      await pumpWithEntry(tester);
      await tester.drag(find.text('Menemen'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.text('Menemen'), findsNothing);
      expect(memState.caloriesConsumedToday, 0);
      expect(find.text('Menemen silindi'), findsOneWidget);

      await tester.tap(find.text('Geri al'));
      await tester.pumpAndSettle();
      expect(find.text('Menemen'), findsOneWidget);
      expect(memState.caloriesConsumedToday, 120);
    });

    testWidgets('the undo SnackBar goes away after 4 seconds', (tester) async {
      await pumpWithEntry(tester);
      await tester.drag(find.text('Menemen'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Geri al'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Geri al'), findsNothing);
    });

    testWidgets('tapping a row edits its serving and meal', (tester) async {
      await pumpWithEntry(tester);
      await tester.tap(find.text('Menemen'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Kaydet'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded).last);
      await tester.pump();
      await tester.ensureVisible(find.text('Akşam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Akşam'));
      await tester.pump();
      expect(find.text('Kaydet · 180 kcal'), findsOneWidget);

      await tester.tap(find.text('Kaydet · 180 kcal'));
      await tester.pumpAndSettle();

      final e = memState.todayEntries.single;
      expect(e.amount, 1.5);
      expect(e.meal, MealType.dinner);
      expect(memState.caloriesConsumedToday, 180);
      expect(find.byType(DiaryScreen), findsOneWidget);
    });
  });
}
