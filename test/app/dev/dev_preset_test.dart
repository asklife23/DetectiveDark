import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/app/dev/dev_preset_source.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  group('parseDevPresets', () {
    test('reads a preset with everything in it', () {
      final presets = parseDevPresets('''
        {"formatVersion": 1, "presets": [
          {"id": "market", "scene": "market_square",
           "items": ["pill_bottle"], "notes": ["hall_letter"],
           "flags": ["front_door_open"]}
        ]}''');

      expect(presets, const [
        DevPreset(
          id: 'market',
          sceneId: 'market_square',
          itemIds: ['pill_bottle'],
          noteIds: ['hall_letter'],
          flags: ['front_door_open'],
        ),
      ]);
    });

    test('items, notes and flags are optional', () {
      final presets = parseDevPresets(
        '{"formatVersion": 1, "presets": [{"id": "a", "scene": "s"}]}',
      );

      expect(presets, const [DevPreset(id: 'a', sceneId: 's')]);
    });

    test('an empty list is fine', () {
      expect(parseDevPresets('{"formatVersion": 1, "presets": []}'), isEmpty);
    });

    FormatException failureOf(String raw) {
      try {
        parseDevPresets(raw);
      } on FormatException catch (error) {
        return error;
      }
      fail('expected a FormatException');
    }

    test('rejects an unsupported format version', () {
      expect(
        failureOf('{"formatVersion": 2, "presets": []}').message,
        contains('formatVersion'),
      );
    });

    test('rejects a misspelled key and names it', () {
      final error = failureOf(
        '{"formatVersion": 1, "presets": [{"id": "a", "scene": "s", '
        '"itmes": []}]}',
      );

      expect(error.message, contains('itmes'));
      expect(error.message, contains('preset #0'));
    });

    test('rejects a preset without a scene', () {
      expect(
        failureOf('{"formatVersion": 1, "presets": [{"id": "a"}]}').message,
        contains('"scene"'),
      );
    });

    test('rejects a list that holds something else than strings', () {
      expect(
        failureOf(
          '{"formatVersion": 1, "presets": [{"id": "a", "scene": "s", '
          '"items": [1]}]}',
        ).message,
        contains('"items"'),
      );
    });

    test('rejects a file that is not an object', () {
      expect(failureOf('[]').message, contains('JSON object'));
    });
  });

  group('DevPresetSource', () {
    test('reads the presets from the bundle', () async {
      final source = DevPresetSource(
        FakeAssetBundle({
          DevPresetSource.path:
              '{"formatVersion": 1, "presets": [{"id": "a", "scene": "s"}]}',
        }),
      );

      expect(await source.load(), const [DevPreset(id: 'a', sceneId: 's')]);
    });

    test('a build without the file has no presets (Windows, staging, '
        'prod)', () async {
      final source = DevPresetSource(FakeAssetBundle({}));

      expect(await source.load(), isEmpty);
    });

    test('a broken file gives no presets and is logged', () async {
      final entries = <LogEntry>[];
      final source = DevPresetSource(
        FakeAssetBundle({DevPresetSource.path: '{"formatVersion": 9}'}),
        logger: AppLogger('dev_menu', writer: entries.add),
      );

      expect(await source.load(), isEmpty);
      expect(entries.single.level, LogLevel.error);
    });
  });
}
