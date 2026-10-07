import 'package:denge/data/app_state.dart';
import 'package:denge/main.dart';
import 'package:flutter/material.dart';
import 'package:denge/screens/auth/password_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_auth_service.dart';

void main() {
  testWidgets(
      'a password-reset link that cold-starts the app ends on the new '
      'password screen, even after the splash moves on', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final auth = FakeAuthService();
    AppState.instance.auth = auth;
    await tester.runAsync(() => AppState.instance.load());

    await tester.pumpWidget(const DengeApp());
    await tester.pump();
    auth.emitPasswordRecovery();
    // Push, transition, and the extra frame that brings a new route onstage.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(NewPasswordScreen), findsOneWidget);

    // Let the splash timer fire and navigate away underneath.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    final route = ModalRoute.of(
        tester.element(find.byType(NewPasswordScreen, skipOffstage: false)));
    expect(route?.isCurrent, isTrue,
        reason: 'the splash must not cover the new password screen');
  });
}
