import 'dart:io';

import 'package:denge/data/sync/row_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Column names of `create table public.<table> (...)` across all
/// migrations (plus later `add column`s).
Set<String> serverColumns(String table) {
  final sql = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .map((f) => f.readAsStringSync())
      .join('\n');
  final create = RegExp('create table public\\.$table \\((.*?)\\n\\);',
          dotAll: true)
      .firstMatch(sql)!
      .group(1)!;
  final cols = <String>{
    for (final line in create.split('\n'))
      if (RegExp(r'^\s+([a-z_]+) ').firstMatch(line) case final m?)
        if (!{'unique', 'primary', 'check', 'constraint'}.contains(m.group(1)))
          m.group(1)!,
  };
  for (final m in RegExp('alter table public\\.$table\\s+add column ([a-z_]+)')
      .allMatches(sql)) {
    cols.add(m.group(1)!);
  }
  return cols;
}

void main() {
  for (final table in pushedTables) {
    test('$table: every column the app sends exists on the server', () {
      final server = serverColumns(table);
      expect(server, isNotEmpty);
      final sent = sampleRowKeys(table);
      expect(server.containsAll(sent), isTrue,
          reason: 'unknown: ${sent.difference(server)}');
      expect(sent.contains('user_id'), isFalse);
      expect(sent.contains('server_updated_at'), isFalse);
    });
  }

  test('upsert_water parameters match the RPC signature', () {
    final sql = File('supabase/migrations/20261007140000_initial_schema.sql')
        .readAsStringSync();
    for (final p in waterRpcParams(const {
      'id': 'x', 'date': 'd', 'glasses': 1, 'created_at': 1,
      'updated_at': 1, 'deleted_at': null,
    }).keys) {
      expect(sql, contains(p), reason: p);
    }
  });
}
