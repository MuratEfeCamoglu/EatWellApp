import 'package:denge/data/app_state.dart';
import 'package:denge/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loads without a database (existing widget tests rely on this)',
      () async {
    final state = AppState.forTesting();
    await state.load();
    expect(state.hasDatabase, isFalse);
    expect(state.storageError, isNull);
    expect(state.caloriesConsumedToday, 0);
  });

  test('attaches a database during load', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final state = AppState.forTesting();
    await state.load(db: db);
    expect(state.hasDatabase, isTrue);
    expect(state.storageError, isNull);
  });
}
