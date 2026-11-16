import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

/// Guards the table layout of the local database.
///
/// `drift_schemas/app_database/` holds one dump per schema version, written
/// by `dart run drift_dev make-migrations`; the files under `generated/`
/// rebuild a database from such a dump. With them this test creates real
/// databases at old versions and checks that the current code opens and
/// upgrades them. From version 2 on, `make-migrations` adds a generated
/// `migration_test.dart` next to this file with the step-by-step tests.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every schema version has a dump, up to the current one', () {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(GeneratedHelper.versions, [
      for (var version = 1; version <= database.schemaVersion; version++)
        version,
    ]);
  });

  // Fails when a table was changed without raising `schemaVersion` and
  // running `make-migrations`: what the code creates would no longer match
  // the dump of its own version.
  test('a new database created by the code equals the dump of the current '
      'version', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, database.schemaVersion);
  });

  for (final version in GeneratedHelper.versions) {
    test('a database created at v$version opens with the current code and '
        'ends with the current tables', () async {
      final connection = await verifier.startAt(version);
      final database = AppDatabase(connection);
      addTearDown(database.close);

      // Runs the migrations from `version` to the current one and compares
      // every table, column and index with what the code expects.
      await verifier.migrateAndValidate(database, database.schemaVersion);
    });
  }
}
