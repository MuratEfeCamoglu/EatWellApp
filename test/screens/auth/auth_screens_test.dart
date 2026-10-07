import 'package:denge/data/app_state.dart';
import 'package:denge/data/auth.dart';
import 'package:denge/router.dart';
import 'package:denge/screens/auth/login_screen.dart';
import 'package:denge/screens/auth/password_screens.dart';
import 'package:denge/screens/auth/sign_up_screen.dart';
import 'package:denge/screens/settings/settings_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fake_sync_backend.dart';
import 'package:denge/data/sync/profile_snapshot.dart';
import 'package:denge/screens/auth/cloud_consent_screen.dart';

void main() {
  late AppState state;
  late FakeAuthService auth;
  late FakeSyncBackend cloud;
  late WidgetTester current;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuthService();
    cloud = FakeSyncBackend();
    state = AppState.forTesting()..clock = (() => DateTime(2026, 10, 7, 12));
  });

  Future<void> pump(WidgetTester tester, Widget home,
      {bool withAuth = true}) async {
    current = tester;
    // A phone-sized screen (360×800 logical) rather than the 800×600 default.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    if (withAuth) {
      state
        ..auth = auth
        ..syncBackend = cloud;
    }
    await tester.runAsync(() => state.load());
    Widget stub(String name) => Scaffold(body: Text('→ $name'));
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: home,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signUp: (_) => const SignUpScreen(),
          AppRoutes.healthConsent: (_) => stub('onay'),
          AppRoutes.setupGender: (_) => stub('kurulum'),
          AppRoutes.main: (_) => stub('ana sayfa'),
          AppRoutes.onboarding: (_) => stub('karşılama'),
        },
      ),
    ));
    await tester.pump();
  }

  /// The text field directly below the label [label].
  Finder field(String label) {
    final labelTop = current.getTopLeft(find.text(label).first).dy;
    final fields = find.byType(TextFormField).evaluate().toList();
    Element? best;
    var bestGap = double.infinity;
    for (final e in fields) {
      final gap = current.getTopLeft(find.byElementPredicate((x) => x == e)).dy -
          labelTop;
      if (gap > 0 && gap < bestGap) {
        bestGap = gap;
        best = e;
      }
    }
    return find.byElementPredicate((x) => x == best);
  }

  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    // A focused text field scrolls itself back into view; drop the focus
    // like a user dismissing the keyboard before tapping a button.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('login', () {
    testWidgets('signs in and continues to consent on a fresh device',
        (tester) async {
      auth.addUser('can@ornek.com', 'sifre123', name: 'Can');
      await pump(tester, const LoginScreen());
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'sifre123');
      await tapVisible(tester, find.text('Giriş yap').first);
      await tapVisible(tester, find.text('Şimdilik hayır'));

      expect(state.account?.email, 'can@ornek.com');
      expect(find.text('→ onay'), findsOneWidget);
    });

    testWidgets('goes to the main shell when the device has a profile',
        (tester) async {
      SharedPreferences.setMockInitialValues({'setup_complete': true});
      auth.addUser('can@ornek.com', 'sifre123');
      await pump(tester, const LoginScreen());
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'sifre123');
      await tapVisible(tester, find.text('Giriş yap').first);
      await tapVisible(tester, find.text('Şimdilik hayır'));
      expect(find.text('→ ana sayfa'), findsOneWidget);
    });

    testWidgets('wrong password shows a Turkish error and stays',
        (tester) async {
      auth.addUser('can@ornek.com', 'sifre123');
      await pump(tester, const LoginScreen());
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'yanlis999');
      await tapVisible(tester, find.text('Giriş yap').first);

      expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(state.isSignedIn, isFalse);
    });

    testWidgets('network failure is explained', (tester) async {
      auth.nextFailure = const AuthFailure(AuthFailureCode.network);
      await pump(tester, const LoginScreen());
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'sifre123');
      await tapVisible(tester, find.text('Giriş yap').first);
      expect(find.text('İnternet bağlantısı yok. Bağlanıp tekrar dene.'),
          findsOneWidget);
    });

    testWidgets('without Supabase it keeps the local-only behaviour',
        (tester) async {
      await pump(tester, const LoginScreen(), withAuth: false);
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'x');
      await tapVisible(tester, find.text('Giriş yap').first);
      expect(find.text('→ onay'), findsOneWidget);
    });

    testWidgets('"Şifremi unuttum" sends a reset link', (tester) async {
      await pump(tester, const LoginScreen());
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tapVisible(tester, find.text('Şifremi unuttum'));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('can@ornek.com'), findsOneWidget, reason: 'pre-filled');

      await tapVisible(tester, find.text('Bağlantı gönder'));
      expect(auth.resetEmails, ['can@ornek.com']);
      expect(find.text('E-postanı kontrol et'), findsOneWidget);
    });
  });

  group('sign up', () {
    Future<void> fill(WidgetTester tester,
        {String password = 'sifre123'}) async {
      await tester.enterText(field('Ad Soyad'), 'Ayşe Yılmaz');
      await tester.enterText(field('E-posta'), 'ayse@ornek.com');
      await tester.enterText(field('Şifre'), password);
    }

    testWidgets('creates the account and continues to consent',
        (tester) async {
      await pump(tester, const SignUpScreen());
      await fill(tester);
      await tapVisible(tester, find.text('Kayıt ol'));
      await tapVisible(tester, find.text('Şimdilik hayır'));
      expect(state.account?.email, 'ayse@ornek.com');
      expect(state.draft.name, 'Ayşe Yılmaz');
      expect(find.text('→ onay'), findsOneWidget);
    });

    testWidgets('with e-mail confirmation it explains and goes to login',
        (tester) async {
      auth.requireConfirmation = true;
      await pump(tester, const SignUpScreen());
      await fill(tester);
      await tapVisible(tester, find.text('Kayıt ol'));
      expect(find.text('E-postanı doğrula'), findsOneWidget);
      await tapVisible(tester, find.text('Tamam'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(state.isSignedIn, isFalse);
    });

    testWidgets('an existing e-mail is reported', (tester) async {
      auth.addUser('ayse@ornek.com', 'baska123');
      await pump(tester, const SignUpScreen());
      await fill(tester);
      await tapVisible(tester, find.text('Kayıt ol'));
      expect(find.text('Bu e-posta ile zaten bir hesap var. Giriş yapmayı dene.'),
          findsOneWidget);
    });

    testWidgets('password needs a digit', (tester) async {
      await pump(tester, const SignUpScreen());
      await fill(tester, password: 'sadeceharf');
      await tapVisible(tester, find.text('Kayıt ol'));
      expect(find.text('En az bir rakam içermeli'), findsOneWidget);
      expect(state.isSignedIn, isFalse);
    });

    testWidgets('"Hesapsız devam et" skips the account', (tester) async {
      await pump(tester, const SignUpScreen());
      await tester.enterText(field('Ad Soyad'), 'Misafir');
      await tapVisible(tester, find.text('Hesapsız devam et'));
      expect(find.text('→ onay'), findsOneWidget);
      expect(state.isSignedIn, isFalse);
      expect(state.draft.name, 'Misafir');
    });
  });

  group('new password', () {
    testWidgets('must match and follow the rule, then saves', (tester) async {
      await pump(tester, const NewPasswordScreen());
      await tester.enterText(field('Yeni şifre'), 'yenisifre1');
      await tester.enterText(field('Yeni şifre (tekrar)'), 'yenisifre2');
      await tapVisible(tester, find.text('Şifreyi kaydet'));
      expect(find.text('Şifreler aynı değil'), findsOneWidget);

      await tester.enterText(field('Yeni şifre (tekrar)'), 'yenisifre1');
      await tapVisible(tester, find.text('Şifreyi kaydet'));
      expect(auth.updatedPassword, 'yenisifre1');
    });
  });

  group('settings account section', () {
    testWidgets('signed in: shows the e-mail and signs out', (tester) async {
      auth.addUser('can@ornek.com', 'sifre123');
      await pump(tester, const SettingsScreen());
      await tester.runAsync(
          () => state.signIn(email: 'can@ornek.com', password: 'sifre123'));
      await tester.pump();

      await tapVisible(tester, find.text('Çıkış yap'));
      expect(find.text('Giriş yapıldı: can@ornek.com'), findsOneWidget);
      await tester.tap(find.text('Çıkış yap').last);
      await tester.pumpAndSettle();
      expect(state.isSignedIn, isFalse);
      expect(find.text('Giriş yap veya hesap oluştur'), findsOneWidget);
    });

    testWidgets('local-only builds show no account button', (tester) async {
      await pump(tester, const SettingsScreen(), withAuth: false);
      expect(find.text('Çıkış yap'), findsNothing);
      expect(find.text('Giriş yap veya hesap oluştur'), findsNothing);
    });
  });

  group('cloud consent', () {
    Future<void> signInVia(WidgetTester tester) async {
      await tester.enterText(field('E-posta'), 'can@ornek.com');
      await tester.enterText(field('Şifre'), 'sifre123');
      await tapVisible(tester, find.text('Giriş yap').first);
    }

    testWidgets('after login it asks; accepting pulls the cloud profile',
        (tester) async {
      auth.addUser('can@ornek.com', 'sifre123');
      cloud.profile = const ProfileSnapshot(
          createdAt: 1, updatedAt: 2, name: 'Can', calorieGoal: 2100,
          consentVersion: 'v', consentAt: 1);
      await pump(tester, const LoginScreen());
      await signInVia(tester);

      expect(find.byType(CloudConsentScreen), findsOneWidget);
      final accept = find.text('Kabul et ve yedekle');
      expect(tester.widget<ElevatedButton>(
              find.ancestor(of: accept, matching: find.byType(ElevatedButton)))
          .onPressed, isNull, reason: 'needs the explicit tick first');
      await tapVisible(tester, find.byType(CheckboxListTile));
      await tester.runAsync(() async {
        await tester.tap(accept);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(state.hasCloudConsent, isTrue);
      expect(state.user.calorieGoal, 2100);
      expect(find.text('→ ana sayfa'), findsOneWidget);
    });

    testWidgets('"Şimdilik hayır" keeps everything local', (tester) async {
      auth.addUser('can@ornek.com', 'sifre123');
      await pump(tester, const LoginScreen());
      await signInVia(tester);
      await tapVisible(tester, find.text('Şimdilik hayır'));

      expect(state.hasCloudConsent, isFalse);
      expect(cloud.fetches + cloud.pushes, 0);
      expect(find.text('→ onay'), findsOneWidget);
    });

    testWidgets('sign up asks before the health consent page', (tester) async {
      await pump(tester, const SignUpScreen());
      await tester.enterText(field('Ad Soyad'), 'Ayşe');
      await tester.enterText(field('E-posta'), 'ayse@ornek.com');
      await tester.enterText(field('Şifre'), 'sifre123');
      await tapVisible(tester, find.text('Kayıt ol'));
      expect(find.byType(CloudConsentScreen), findsOneWidget);
      await tapVisible(tester, find.text('Şimdilik hayır'));
      expect(find.text('→ onay'), findsOneWidget);
    });

    testWidgets('settings shows the status and lets the user turn it off',
        (tester) async {
      auth.addUser('can@ornek.com', 'sifre123');
      await pump(tester, const SettingsScreen());
      await tester.runAsync(() async {
        await state.signIn(email: 'can@ornek.com', password: 'sifre123');
        await state.giveCloudConsent();
      });
      await tester.pump();

      await tapVisible(tester, find.text('Bulut yedekleme'));
      expect(find.byType(CloudConsentScreen), findsOneWidget);
      expect(find.textContaining('Bulut yedekleme açık'), findsOneWidget);
      await tapVisible(tester, find.text('Yedeklemeyi kapat'));
      expect(state.hasCloudConsent, isFalse);
    });
  });
}
