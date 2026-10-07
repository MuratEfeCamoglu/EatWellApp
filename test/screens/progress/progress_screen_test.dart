import 'package:denge/data/app_state.dart';
import 'package:denge/screens/progress/progress_screen.dart';
import 'package:denge/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('chart plots the last weight of each of several days',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 10, 5, 8);
    final state = AppState.forTesting()..clock = () => now;
    await tester.runAsync(() async {
      await state.load();
      await state.logWeight(72);
      now = DateTime(2026, 10, 6, 8);
      await state.logWeight(71.6);
      now = DateTime(2026, 10, 7, 8);
      await state.logWeight(71.4);
      now = DateTime(2026, 10, 7, 21);
      await state.logWeight(71.2); // same day: replaces 71.4 on the chart
    });

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(theme: AppTheme.light(), home: const ProgressScreen()),
    ));
    await tester.pump();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    final spots = chart.data.lineBarsData.single.spots;
    expect(spots.map((s) => s.y), [72, 71.6, 71.2]);
  });
}
