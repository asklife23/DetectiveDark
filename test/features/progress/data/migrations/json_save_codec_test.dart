import 'dart:convert';
import 'dart:io';

import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/progress/data/datasources/local/game_progress_converter.dart';
import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';
import 'package:detective_dark/features/progress/data/migrations/save_migrator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/progress_fixtures.dart';
import '../../../../helpers/slice_fixtures.dart';

/// v1 → v2 of an invented future: `playTimeSeconds` becomes
/// `playTimeMinutes`. Version 2 is not what the DTO reads, so this codec
/// can only prove what happens *around* the DTO.
Map<String, dynamic> _renamePlayTime(Map<String, dynamic> json) => {
  for (final entry in json.entries)
    if (entry.key != 'playTimeSeconds') entry.key: entry.value,
  'playTimeMinutes': (json['playTimeSeconds'] as int) ~/ 60,
};

void main() {
  const codec = JsonSaveCodec();

  Map<String, dynamic> jsonOf(String text) =>
      jsonDecode(text) as Map<String, dynamic>;

  test('what is encoded decodes to the same progress', () {
    expect(codec.decode(codec.encode(richProgress)).valueOrNull, richProgress);
    expect(codec.decode(codec.encode(newGame)).valueOrNull, newGame);
  });

  test('the text starts with the version this build writes', () {
    final text = codec.encode(newGame);

    expect(codec.version, const SaveMigrator().currentVersion);
    expect(text, startsWith('{"schemaVersion":${codec.version},'));
  });

  test('the save holds no texts, only IDs, flags and keys', () {
    final text = codec.encode(richProgress);

    // Every string in the save is an identifier: no spaces, no sentences.
    final strings = RegExp('"([^"]*)"').allMatches(text).map((m) => m[1]!);
    expect(strings.where((value) => value.contains(' ')), isEmpty);
  });

  // The file is a real save of format version 1. It must stay readable for
  // as long as the game exists, and until a migration is added the game
  // must keep writing exactly this format.
  group('the stored example of format version 1', () {
    final example = File('test/fixtures/saves/save_v1.json').readAsStringSync();

    test('still decodes to the same progress', () {
      expect(codec.decode(example).valueOrNull, richProgress);
    });

    test('is what the game writes while the format is at version 1. If '
        'this fails, the save format changed: add a migration and a new '
        'example instead of editing this one', () {
      expect(jsonOf(example)['schemaVersion'], 1);
      if (codec.version == 1) {
        expect(jsonOf(codec.encode(richProgress)), jsonOf(example));
      }
    });
  });

  group('a text that is not a save is reported as corrupt', () {
    for (final (name, text) in [
      ('empty', ''),
      ('cut off', '{"schemaVersion":1,"caseId":"case01","sceneSt'),
      ('not JSON', 'hello detective'),
      ('a list', '[1, 2, 3]'),
      ('a number', '42'),
      ('no version', '{"caseId":"case01"}'),
      ('version only', '{"schemaVersion":1}'),
    ]) {
      test(name, () {
        final result = codec.decode(text);

        expect(result.failureOrNull, isA<SaveCorruptFailure>());
        expect(
          () => codec.decodeOrThrow(text),
          throwsA(isA<SaveCorruptException>()),
        );
      });
    }

    test('a mistyped field is named in the failure', () {
      final json = jsonOf(codec.encode(richProgress))..['inventory'] = 'key';

      final failure = codec.decode(jsonEncode(json)).failureOrNull;

      expect(failure, isA<SaveCorruptFailure>());
      expect(failure!.message, contains('inventory'));
      expect(failure.cause, isNotNull);
    });

    test('an unknown field is rejected (a save is not half-read)', () {
      final json = jsonOf(codec.encode(richProgress))..['gold'] = 9999;

      expect(
        codec.decode(jsonEncode(json)).failureOrNull,
        isA<SaveCorruptFailure>(),
      );
    });
  });

  test('a save from a newer build is reported as too new, with both '
      'versions', () {
    final json = jsonOf(codec.encode(richProgress))
      ..['schemaVersion'] = codec.version + 1
      ..['somethingFromTheFuture'] = true;

    final failure = codec.decode(jsonEncode(json)).failureOrNull;

    expect(
      failure,
      SaveTooNewFailure(
        savedVersion: codec.version + 1,
        supportedVersion: codec.version,
      ),
    );
    expect(
      () => codec.decodeOrThrow(jsonEncode(json)),
      throwsA(isA<SaveTooNewException>()),
    );
  });

  group('with migrations', () {
    const future = JsonSaveCodec(
      migrator: SaveMigrator(migrations: [_renamePlayTime]),
    );

    test('writes the new version number', () {
      expect(future.version, 2);
      expect(jsonOf(future.encode(newGame))['schemaVersion'], 2);
    });

    test('an old save is migrated before its fields are checked', () {
      // The migrated JSON has `playTimeMinutes`, which today's DTO does not
      // know. That it complains about exactly this field proves the
      // migration ran first.
      final failure = future.decode(codec.encode(richProgress)).failureOrNull;

      expect(failure, isA<SaveCorruptFailure>());
      expect(failure!.message, contains('playTimeMinutes'));
    });

    test('what was too new for the old build is readable for the new '
        'one', () {
      final v2 = jsonOf(future.encode(newGame));

      expect(
        codec.decode(jsonEncode(v2)).failureOrNull,
        isA<SaveTooNewFailure>(),
      );
      expect(future.decode(jsonEncode(v2)).valueOrNull, newGame);
    });
  });

  group('GameProgressConverter (the save column)', () {
    const converter = GameProgressConverter();

    test('writes and reads with the save codec', () {
      expect(converter.toSql(richProgress), codec.encode(richProgress));
      expect(converter.fromSql(codec.encode(richProgress)), richProgress);
    });

    test('throws the save exceptions, which the repository catches', () {
      expect(
        () => converter.fromSql('{"schemaVersion":99}'),
        throwsA(isA<SaveTooNewException>()),
      );
      expect(
        () => converter.fromSql('not a save'),
        throwsA(isA<SaveCorruptException>()),
      );
    });
  });
}
