import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';
import 'package:detective_dark/features/progress/data/migrations/save_migrator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invented migrations, to test the chain without waiting for the game to
/// need a real one.
///
/// v1 → v2: `coins` (a number) becomes `wallet: {coins: n}`.
Map<String, dynamic> _v1ToV2(Map<String, dynamic> json) => {
  for (final entry in json.entries)
    if (entry.key != 'coins') entry.key: entry.value,
  'wallet': {'coins': json['coins'] as int},
};

/// v2 → v3: a new field with a default.
Map<String, dynamic> _v2ToV3(Map<String, dynamic> json) => {
  ...json,
  'hintsUsed': 0,
};

void main() {
  const migrator = SaveMigrator(migrations: [_v1ToV2, _v2ToV3]);

  group('the migrator of the game', () {
    const real = SaveMigrator();

    test('writes the version that follows its migrations', () {
      expect(real.currentVersion, 1 + saveMigrations.length);
    });

    test('returns a current payload unchanged', () {
      final json = {
        SaveMigrator.versionKey: real.currentVersion,
        'caseId': 'case01',
      };

      expect(real.migrate(json), same(json));
    });
  });

  test('the current version is the first version plus one per '
      'migration', () {
    expect(SaveMigrator.firstVersion, 1);
    expect(migrator.currentVersion, 3);
  });

  test('an old payload runs through every missing step, in order', () {
    final migrated = migrator.migrate({
      'schemaVersion': 1,
      'caseId': 'case01',
      'coins': 7,
    });

    expect(migrated, {
      'schemaVersion': 3,
      'caseId': 'case01',
      'wallet': {'coins': 7},
      'hintsUsed': 0,
    });
  });

  test('a payload in the middle of the chain runs only the later '
      'steps', () {
    final migrated = migrator.migrate({
      'schemaVersion': 2,
      'wallet': {'coins': 7},
    });

    expect(migrated, {
      'schemaVersion': 3,
      'wallet': {'coins': 7},
      'hintsUsed': 0,
    });
  });

  test('the input is not changed (migrations are pure)', () {
    final json = <String, dynamic>{'schemaVersion': 1, 'coins': 7};

    migrator.migrate(json);

    expect(json, {'schemaVersion': 1, 'coins': 7});
  });

  test('every step stamps its version, even when the migration '
      'forgets to', () {
    const forgetful = SaveMigrator(migrations: [_v2ToV3]);

    expect(forgetful.migrate({'schemaVersion': 1})['schemaVersion'], 2);
  });

  test('a payload from a newer build is refused with both versions', () {
    expect(
      () => migrator.migrate({'schemaVersion': 4}),
      throwsA(
        isA<SaveTooNewException>()
            .having((e) => e.savedVersion, 'savedVersion', 4)
            .having((e) => e.supportedVersion, 'supportedVersion', 3),
      ),
    );
  });

  group('a payload without a usable version is corrupt', () {
    for (final (name, version) in [
      ('missing', null),
      ('text', '1'),
      ('zero', 0),
      ('negative', -2),
      ('fraction', 1.5),
    ]) {
      test(name, () {
        expect(
          () => migrator.migrate({'schemaVersion': ?version}),
          throwsA(isA<SaveCorruptException>()),
        );
      });
    }
  });

  test('a migration that chokes on damaged data reports a corrupt save, '
      'naming the step', () {
    expect(
      () => migrator.migrate({'schemaVersion': 1, 'coins': 'many'}),
      throwsA(
        isA<SaveCorruptException>()
            .having((e) => e.message, 'message', contains('v1 → v2'))
            .having((e) => e.cause, 'cause', isA<TypeError>()),
      ),
    );
  });

  test('a migration that throws an exception reports a corrupt save', () {
    final failing = SaveMigrator(
      migrations: [(_) => throw const FormatException('bad date')],
    );

    expect(
      () => failing.migrate({'schemaVersion': 1}),
      throwsA(
        isA<SaveCorruptException>().having(
          (e) => e.cause,
          'cause',
          isA<FormatException>(),
        ),
      ),
    );
  });
}
