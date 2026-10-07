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
}
