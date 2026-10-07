import 'package:denge/data/profile_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name', () {
    expect(validateName(''), isNotNull);
    expect(validateName('  '), isNotNull);
    expect(validateName('Ayşe'), isNull);
  });

  test('email is optional but must look like one when given', () {
    expect(validateEmail(''), isNull);
    expect(validateEmail('ayse@ornek.com'), isNull);
    expect(validateEmail('ayse'), isNotNull);
    expect(validateEmail('ayse@ornek'), isNotNull);
  });

  test('age 13–100', () {
    expect(validateAge('12'), isNotNull);
    expect(validateAge('13'), isNull);
    expect(validateAge('100'), isNull);
    expect(validateAge('101'), isNotNull);
    expect(validateAge('27,5'), isNotNull);
    expect(validateAge(''), isNotNull);
  });

  test('height 100–250 cm, decimals allowed', () {
    expect(validateHeight('99'), isNotNull);
    expect(validateHeight('168,5'), isNull);
    expect(validateHeight('251'), isNotNull);
  });

  test('goal weight 30–300 kg', () {
    expect(validateGoalWeight('29'), isNotNull);
    expect(validateGoalWeight('65,5'), isNull);
    expect(validateGoalWeight('301'), isNotNull);
  });

  test('calorie goal 800–6000, whole number', () {
    expect(validateCalorieGoal('799'), isNotNull);
    expect(validateCalorieGoal('1850'), isNull);
    expect(validateCalorieGoal('6001'), isNotNull);
    expect(validateCalorieGoal('1850,5'), isNotNull);
  });

  test('macro goal 0–1000 g, whole number', () {
    expect(validateMacroGoal('0'), isNull);
    expect(validateMacroGoal('140'), isNull);
    expect(validateMacroGoal('-1'), isNotNull);
    expect(validateMacroGoal('1001'), isNotNull);
    expect(validateMacroGoal(''), isNotNull);
  });

  test('macroKcal', () {
    expect(macroKcal(proteinG: 100, carbsG: 200, fatG: 50), 1650);
  });
}
