import 'package:denge/data/app_state.dart';
import 'package:denge/data/models.dart';
import 'package:denge/router.dart';
import 'package:denge/screens/settings/settings_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/food_log_entry_test.dart' show menemen;

void main() {
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'setup_complete': true,
      'user_name': 'Ayşe',
    });
    state = AppState.forTesting()..clock = () => DateTime(2026, 10, 7, 12);
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.runAsync(() async {
      await state.load();
      await state.addFoodToMeal(MealType.lunch, menemen, 1);
    });
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const SettingsScreen(),
        routes: {
          AppRoutes.onboarding: (_) => const Scaffold(body: Text('karşılama')),
        },
      ),
    ));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Tüm verilerimi sil'), 200,
        scrollable: find.byType(Scrollable).first);
  }

  testWidgets('cancelling the dialog keeps everything', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.text('Tüm verilerimi sil'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(state.setupComplete, isTrue);
    expect(state.todayEntries, hasLength(1));
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('confirming wipes the data and returns to the welcome screen',
      (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.text('Tüm verilerimi sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();

    expect(find.text('karşılama'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(state.setupComplete, isFalse);
    expect(state.todayEntries, isEmpty);
    expect(state.user.name, '');
  });
}
