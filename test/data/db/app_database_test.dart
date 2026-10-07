import 'package:denge/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('in-memory database opens and creates the four user tables', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll(<String>[
        'food_log_entries',
        'water_logs',
        'weight_entries',
        'custom_foods',
      ]),
    );
  });

  test('every user table carries the shared sync columns', () async {
    for (final table in db.allTables) {
      final columns = table.$columns.map((c) => c.name).toSet();
      expect(
        columns,
        containsAll(<String>[
          'id',
          'created_at',
          'updated_at',
          'deleted_at',
          'synced_at',
        ]),
        reason: table.actualTableName,
      );
    }
  });

  test('food log indexes exist', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND tbl_name = 'food_log_entries' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    expect(rows, hasLength(2));
  });

  test('schema version is 1', () {
    expect(db.schemaVersion, 1);
    expect(db.executor, isA<QueryExecutor>());
  });
}
