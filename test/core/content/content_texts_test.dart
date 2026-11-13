import 'dart:convert';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  group('ContentTexts', () {
    test('returns the text for a key', () {
      const texts = ContentTexts({'say_locked': 'Locked.'});

      expect(texts.text('say_locked'), 'Locked.');
      expect(texts.has('say_locked'), isTrue);
      expect(texts.keys, ['say_locked']);
    });

    test('replaces placeholders with params', () {
      const texts = ContentTexts({'hint': '{who} was here at {time}.'});

      expect(
        texts.text('hint', params: {'who': 'Someone', 'time': '23:40'}),
        'Someone was here at 23:40.',
      );
    });

    test('a missing key shows the key and logs a warning', () {
      final entries = <LogEntry>[];
      final texts = ContentTexts(
        const {},
        logger: AppLogger('content', writer: entries.add),
      );

      expect(texts.text('say_unknown'), 'say_unknown');
      expect(entries.single.level, LogLevel.warning);
      expect(entries.single.message, contains('say_unknown'));
    });
  });

  group('ContentTextLoader', () {
    ContentTextLoader loader([Map<String, String?> overrides = const {}]) =>
        ContentTextLoader(ContentAssetSource(minimalCaseBundle(overrides)));

    test('merges the shared texts with the texts of every chapter', () async {
      final texts = (await loader().load('case01', 'en')).valueOrNull!;

      expect(texts.languageCode, 'en');
      expect(texts.text('scene_yard'), 'Yard');
      expect(texts.text('generic_item_no_effect'), 'No use.');
    });

    test('a language without files is a content failure', () async {
      final result = await loader().load('case01', 'tr');

      expect(result.failureOrNull, isA<ContentFailure>());
      expect(result.failureOrNull!.message, contains('text_tr.json'));
    });

    test('a key defined in two files is rejected', () async {
      final result = await loader({
        chapterAsset('text_en.json'): jsonEncode({
          'formatVersion': 1,
          'texts': {'generic_item_no_effect': 'Again.'},
        }),
      }).load('case01', 'en');

      expect(
        result.failureOrNull!.message,
        contains('duplicate text key "generic_item_no_effect"'),
      );
    });

    test('a text that is not a string is rejected', () async {
      final result = await loader({
        chapterAsset('text_en.json'): jsonEncode({
          'formatVersion': 1,
          'texts': {'scene_yard': 3},
        }),
      }).load('case01', 'en');

      expect(result.failureOrNull!.message, contains('"scene_yard"'));
    });
  });
}
