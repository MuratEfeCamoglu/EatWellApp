import 'package:denge/data/app_state.dart';
import 'package:denge/screens/auth/cloud_consent_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('no overflow at "Çok büyük" text (dark: $dark)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState.forTesting();
      await tester.runAsync(() => state.load());
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(320, 640),
              textScaler: TextScaler.linear(TextScaleOption.extraLarge.scale),
            ),
            child: const CloudConsentScreen(),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
