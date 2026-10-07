import 'package:denge/data/app_state.dart';
import 'package:denge/screens/profile/goals_screen.dart';
import 'package:denge/screens/profile/notifications_screen.dart';
import 'package:denge/screens/profile/personal_info_screen.dart';
import 'package:denge/screens/profile/profile_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_reminder_scheduler.dart';

void main() {
  late AppState state;
  late FakeReminderScheduler reminders;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    reminders = FakeReminderScheduler();
    state = AppState.forTesting()
      ..clock = (() => DateTime(2026, 10, 7, 12))
      ..reminders = reminders;
  });

  /// A user who completed setup: female, 27, 168 cm, 70 kg, moderate,
  /// losing 0.5 kg/week -> 1704 kcal.
  Future<void> pump(WidgetTester tester, Widget home,
      {ThemeData? theme, double textScale = 1}) async {
    await tester.runAsync(() async {
      await state.load();
      state.draft
        ..name = 'Ayşe Yılmaz'
        ..email = 'ayse@ornek.com'
        ..gender = Gender.female
        ..age = 27
        ..heightCm = 168
        ..weightKg = 70
        ..activityLevel = ActivityLevel.moderate
        ..goal = WeightGoal.lose
        ..weeklyPaceKg = 0.5
        ..goalWeightKg = 64;
      await state.completeSetup();
    });
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 740),
            textScaler: TextScaler.linear(textScale),
          ),
          child: home,
        ),
      ),
    ));
    await tester.pump();
  }

  Finder field(String label) => find.descendant(
        of: find
            .ancestor(of: find.text(label), matching: find.byType(Column))
            .first,
        matching: find.byType(TextFormField),
      );

  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('profile menu', () {
    for (final (row, screen) in [
      ('Kişisel bilgiler', PersonalInfoScreen),
      ('Hedefler ve makrolar', GoalsScreen),
      ('Bildirimler', NotificationsScreen),
    ]) {
      testWidgets('"$row" opens its screen', (tester) async {
        await pump(tester, const ProfileScreen());
        await tapVisible(tester, find.text(row));
        expect(find.byType(screen), findsOneWidget);
      });
    }

    testWidgets('the edit button opens personal info', (tester) async {
      await pump(tester, const ProfileScreen());
      await tester.tap(find.bySemanticsLabel('Profili düzenle'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalInfoScreen), findsOneWidget);
    });
  });

  group('personal info', () {
    testWidgets('is pre-filled from the profile', (tester) async {
      await pump(tester, const PersonalInfoScreen());
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('ayse@ornek.com'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
      expect(find.text('168'), findsOneWidget);
      expect(find.text('70 kg'), findsOneWidget);
      expect(
          tester
              .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Kadın'))
              .selected,
          isTrue);
    });

    testWidgets('invalid input is rejected with Turkish messages',
        (tester) async {
      await pump(tester, const PersonalInfoScreen());
      await tester.enterText(field('Yaş'), '8');
      await tester.enterText(field('E-posta'), 'ayse');
      await tapVisible(tester, find.text('Kaydet'));
      expect(find.text('13–100 yaş arası olmalı'), findsOneWidget);
      expect(find.text('Geçerli bir e-posta gir'), findsOneWidget);
      expect(state.age, 27);
    });

    testWidgets('saves the changes and goes back', (tester) async {
      await pump(tester, const PersonalInfoScreen());
      await tester.enterText(field('Ad Soyad'), 'Ayşe Demir');
      await tester.enterText(field('Yaş'), '28');
      await tester.enterText(field('Boy'), '170,5');
      await tapVisible(tester, find.text('Çok aktif'));
      await tapVisible(tester, find.text('Kaydet'));

      expect(state.user.name, 'Ayşe Demir');
      expect(state.user.initials, 'AD');
      expect(state.age, 28);
      expect(state.user.heightCm, 170.5);
      expect(state.activityLevel, ActivityLevel.active);
      expect(find.byType(PersonalInfoScreen), findsNothing);
    });
  });

  group('goals', () {
    testWidgets('shows the current goals and the suggestion', (tester) async {
      await pump(tester, const GoalsScreen());
      expect(find.text('1704'), findsOneWidget);
      expect(find.text('64'), findsOneWidget);
      expect(find.text('1704 kcal · P 126 g · K 185 g · Y 51 g'),
          findsOneWidget);
    });

    testWidgets('"Önerileni kullan" fills in the suggestion for a new goal',
        (tester) async {
      await pump(tester, const GoalsScreen());
      await tapVisible(tester, find.text('Kilomu korumak'));
      expect(
          tester.widget<TextFormField>(field('Hedef kilo')).enabled, isFalse);
      await tapVisible(tester, find.text('Önerileni kullan'));
      expect(find.text('2254'), findsOneWidget);

      await tapVisible(tester, find.text('Kaydet'));
      expect(state.weightGoal, WeightGoal.maintain);
      expect(state.user.goalWeightKg, 70);
      expect(state.user.calorieGoal, 2254);
    });

    testWidgets('typed goals are saved; mismatched macros are flagged',
        (tester) async {
      await pump(tester, const GoalsScreen());
      await tester.enterText(field('Günlük kalori hedefi'), '2000');
      await tester.pump();
      expect(find.textContaining('kalori hedefinden %'), findsOneWidget);

      await tester.enterText(field('Karbonhidrat'), '259');
      await tester.pump();
      expect(find.textContaining('kalori hedefinle uyumlu'), findsOneWidget);

      await tapVisible(tester, find.text('Kaydet'));
      expect(state.user.calorieGoal, 2000);
      expect(state.user.carbsGoalG, 259);
    });

    testWidgets('a goal weight in the wrong direction is rejected',
        (tester) async {
      await pump(tester, const GoalsScreen());
      await tester.enterText(field('Hedef kilo'), '75');
      await tapVisible(tester, find.text('Kaydet'));
      expect(find.textContaining('düşük olmalı'), findsOneWidget);
      expect(state.user.goalWeightKg, 64);
    });

    testWidgets('without gender/age/activity it points to personal info',
        (tester) async {
      await pump(tester, const GoalsScreen());
      state
        ..gender = null
        ..notifyListeners();
      await tester.pump();
      expect(find.text('Kişisel bilgilere git'), findsOneWidget);
      await tapVisible(tester, find.text('Kişisel bilgilere git'));
      expect(find.byType(PersonalInfoScreen), findsOneWidget);
    });
  });

  group('notifications', () {
    testWidgets('everything starts off', (tester) async {
      await pump(tester, const NotificationsScreen());
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      expect(switches.every((s) => !s.value), isTrue);
    });

    testWidgets('turning meal reminders on asks permission and schedules',
        (tester) async {
      await pump(tester, const NotificationsScreen());
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(reminders.permissionRequests, 1);
      expect(reminders.applied.last.mealReminders, isTrue);
      expect(state.notificationSettings.mealReminders, isTrue);
      expect(find.text('08:30'), findsOneWidget);
    });

    testWidgets('a denied permission explains how to allow it',
        (tester) async {
      reminders.grant = false;
      await pump(tester, const NotificationsScreen());
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bildirim izni verilmedi'), findsOneWidget);
      expect(state.notificationSettings.waterReminders, isTrue);
    });

    testWidgets('water interval and weekly summary are saved', (tester) async {
      await pump(tester, const NotificationsScreen());
      await tapVisible(tester, find.text('3 saat'));
      expect(state.notificationSettings.waterIntervalHours, 3);
      expect(find.text('09:00–21:00 arası, her 3 saatte bir'), findsOneWidget);
      await tapVisible(tester, find.byType(Switch).last);
      expect(state.notificationSettings.weeklySummary, isTrue);
    });
  });

  for (final dark in [false, true]) {
    for (final screen in const [
      PersonalInfoScreen(),
      GoalsScreen(),
      NotificationsScreen(),
    ]) {
      testWidgets(
          'no overflow at "Çok büyük" text: ${screen.runtimeType} (dark: $dark)',
          (tester) async {
        await pump(tester, screen,
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            textScale: TextScaleOption.extraLarge.scale);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(SingleChildScrollView).first,
            const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
