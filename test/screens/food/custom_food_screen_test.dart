import 'package:denge/data/app_state.dart';
import 'package:denge/data/custom_food.dart';
import 'package:denge/data/models.dart';
import 'package:denge/screens/food/custom_food_screen.dart';
import 'package:denge/screens/food/food_detail_screen.dart';
import 'package:denge/screens/search/search_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppState state;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    state = AppState.forTesting()..clock = () => DateTime(2026, 10, 7, 12);
  });

  Future<void> pump(WidgetTester tester, Widget home,
      {ThemeData? theme, double textScale = 1}) async {
    await tester.runAsync(() => state.load());
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 720),
            textScaler: TextScaler.linear(textScale),
          ),
          child: home,
        ),
      ),
    ));
    await tester.pump();
  }

  Finder field(String label) => find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(Column))
            .first,
        matching: find.byType(TextFormField),
      );

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
  }

  testWidgets('invalid input shows Turkish errors and saves nothing',
      (tester) async {
    await pump(tester, const CustomFoodScreen());
    await tester.enterText(field('Ad'), 'a');
    await tester.enterText(field('Kalori'), '6000');
    await tester.enterText(field('Protein'), '-2');
    await tapSave(tester);

    expect(find.text('Ad en az 2 karakter olmalı'), findsOneWidget);
    expect(find.text('En fazla 5000 kcal olabilir'), findsOneWidget);
    expect(find.text('0 veya daha büyük olmalı'), findsOneWidget);
    expect(state.customFoods, isEmpty);
  });

  testWidgets('kcal is required', (tester) async {
    await pump(tester, const CustomFoodScreen(initialName: 'Börek'));
    await tapSave(tester);
    expect(find.text('Kalori gerekli'), findsOneWidget);
  });

  testWidgets('saving opens the food detail so it can be logged',
      (tester) async {
    await pump(tester,
        const CustomFoodScreen(initialName: 'Annemin böreği',
            initialMeal: MealType.lunch));
    expect(find.text('Annemin böreği'), findsOneWidget, reason: 'pre-filled');
    await tester.enterText(field('Kalori'), '310');
    await tester.enterText(field('Protein'), '9,5');
    await tapSave(tester);

    expect(state.customFoods.single.name, 'Annemin böreği');
    expect(state.customFoods.single.proteinG, 9.5);
    expect(find.byType(FoodDetailScreen), findsOneWidget);

    await tester.tap(find.textContaining('Öğle yemeğine ekle'));
    await tester.pumpAndSettle();
    final entry = state.todayEntries.single;
    expect(entry.kcal, 310);
    expect(entry.source, FoodLogSource.custom);
    expect(entry.sourceRef, state.customFoods.single.id);
  });

  testWidgets('a barcode passed in is stored with the food', (tester) async {
    await pump(tester,
        const CustomFoodScreen(initialName: 'Gofret', barcode: '869123'));
    expect(find.text('Barkod: 869123'), findsOneWidget);
    await tester.enterText(field('Kalori'), '150');
    await tapSave(tester);
    expect(state.customFoodForBarcode('869123')?.name, 'Gofret');
  });

  for (final dark in [false, true]) {
    testWidgets('no overflow at "Çok büyük" text (dark: $dark)',
        (tester) async {
      await pump(tester, const CustomFoodScreen(),
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          textScale: TextScaleOption.extraLarge.scale);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(SingleChildScrollView).first,
          const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  group('search', () {
    testWidgets('own foods are listed first', (tester) async {
      await tester.runAsync(() async {
        await state.load();
        await state.addCustomFood(const CustomFood(
          id: '',
          name: 'Ev simidi',
          servingLabel: '1 adet',
          kcalPerServing: 280,
          proteinG: 9,
          carbsG: 50,
          fatG: 5,
          category: FoodCategory.hamurIsi,
        ));
      });
      await pump(tester, const SearchScreen(initialMeal: MealType.breakfast));
      await tester.enterText(find.byType(TextField).first, 'simi');
      await tester.pump();

      expect(find.text('Kendi yiyeceklerin'), findsOneWidget);
      final own = tester.getTopLeft(find.text('Ev simidi'));
      final catalog = tester.getTopLeft(find.text('Simit').last);
      expect(own.dy, lessThan(catalog.dy));
    });

    testWidgets('"Yiyeceği kendin ekle" opens the form with the query',
        (tester) async {
      await pump(tester, const SearchScreen(initialMeal: MealType.lunch));
      await tester.enterText(find.byType(TextField).first, 'Ejder meyvesi');
      await tester.pump();
      expect(find.text('Bu özellik yakında'), findsNothing);

      await tester.tap(find.text('Yiyeceği kendin ekle'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomFoodScreen), findsOneWidget);
      expect(
          tester.widget<TextFormField>(field('Ad')).controller!.text,
          'Ejder meyvesi');
    });
  });
}
