import 'dart:io';

import 'package:afterglow/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a schema snapshot exists for the current schema version', () {
    // Testers' and users' data must survive updates. When you change a
    // table: bump schemaVersion, write the migration, then run
    //   dart run drift_dev make-migrations
    // which snapshots the new schema and generates migration tests in
    // test/drift/. CI also fails if drift_schemas/ is out of date.
    final db = AppDatabase(NativeDatabase.memory());
    final v = db.schemaVersion;
    db.close();
    expect(File('drift_schemas/app/drift_schema_v$v.json').existsSync(), isTrue,
        reason: 'Missing drift_schemas/app/drift_schema_v$v.json');
  });
}
