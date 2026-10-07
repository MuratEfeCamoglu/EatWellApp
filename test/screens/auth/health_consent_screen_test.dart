import 'package:denge/data/app_state.dart';
import 'package:denge/data/health_consent.dart';
import 'package:denge/router.dart';
import 'package:denge/screens/auth/health_consent_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpScreen(
  WidgetTester tester, {
  ThemeData? theme,
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(320, 640),
          textScaler: TextScaler.linear(textScale),
        ),
        child: const HealthConsentScreen(),
      ),
      routes: {
        AppRoutes.setupGender: (_) => const Scaffold(body: Text('setup')),
      },
    ),
  );
}

ElevatedButton _continueButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Devam'));

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.load();
    AppState.instance
      ..allergies = AllergyProfile.none
      ..consent = null;
  });

  testWidgets('Devam is disabled until consent is ticked', (tester) async {
    await _pumpScreen(tester);
    expect(_continueButton(tester).onPressed, isNull);

    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('saves allergies + consent and opens the setup wizard', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.tap(find.text('Gluten'));
    await tester.enterText(find.byType(TextField), 'çilek');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    expect(find.text('setup'), findsOneWidget);
    final state = AppState.instance;
    expect(state.allergies.allergens, {Allergen.gluten});
    expect(state.allergies.otherNote, 'çilek');
    expect(state.consent?.version, kConsentVersion);

    // Survives a restart.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('user_allergies'), ['gluten']);
    await state.load();
    expect(state.hasConsent, isTrue);
    expect(state.allergies.allergens, {Allergen.gluten});
  });

  testWidgets('"Alerjim yok" clears selected allergens', (tester) async {
    await _pumpScreen(tester);
    await tester.tap(find.text('Susam'));
    await tester.pump();
    await tester.tap(find.text('Alerjim yok'));
    await tester.pump();
    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Susam'),
    );
    expect(chip.selected, isFalse);
  });

  for (final dark in [false, true]) {
    testWidgets('no overflow at "Çok büyük" text (dark: $dark)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpScreen(
        tester,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        textScale: TextScaleOption.extraLarge.scale,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
