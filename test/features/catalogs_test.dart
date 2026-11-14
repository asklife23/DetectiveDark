import 'dart:convert';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_bundle.dart';

/// The item and note catalogs share one loading pattern, so they are tested
/// side by side.
void main() {
  ContentAssetSource source(Map<String, String?> overrides) =>
      ContentAssetSource(minimalCaseBundle(overrides));

  group('AssetItemCatalogRepository', () {
    test('loads items keyed by ID', () async {
      final result = await AssetItemCatalogRepository(
        source({
          chapterAsset('items.json'): jsonEncode({
            'formatVersion': 1,
            'items': [
              {
                'id': 'brass_key',
                'nameKey': 'key_name',
                'descriptionKey': 'key_description',
                'iconStyle': 'item_brass_key',
              },
            ],
          }),
        }),
      ).loadItems('case01');

      expect(result.valueOrNull, {
        'brass_key': const ItemDefinition(
          id: 'brass_key',
          nameKey: 'key_name',
          descriptionKey: 'key_description',
          iconStyle: 'item_brass_key',
        ),
      });
    });

    test('a missing required field is a content failure', () async {
      final result = await AssetItemCatalogRepository(
        source({
          chapterAsset('items.json'): jsonEncode({
            'formatVersion': 1,
            'items': [
              {'id': 'brass_key', 'nameKey': 'key_name'},
            ],
          }),
        }),
      ).loadItems('case01');

      expect(result.failureOrNull, isA<ContentFailure>());
      expect(result.failureOrNull!.message, contains('items.json'));
    });
  });

  group('AssetNoteCatalogRepository', () {
    String notesJson(String category) => jsonEncode({
      'formatVersion': 1,
      'notes': [
        {
          'id': 'hall_letter',
          'category': category,
          'titleKey': 'letter_title',
          'bodyKey': 'letter_body',
        },
      ],
    });

    test('loads notes with their category', () async {
      final result = await AssetNoteCatalogRepository(
        source({chapterAsset('notes.json'): notesJson('document')}),
      ).loadNotes('case01');

      expect(
        result.valueOrNull!['hall_letter']!.category,
        NoteCategory.document,
      );
    });

    test('an unknown category is a content failure', () async {
      final result = await AssetNoteCatalogRepository(
        source({chapterAsset('notes.json'): notesJson('rumour')}),
      ).loadNotes('case01');

      expect(result.failureOrNull, isA<ContentFailure>());
      expect(result.failureOrNull!.message, contains('notes.json'));
    });
  });

  group('note entries', () {
    String notesWith(Object? entries) => jsonEncode({
      'formatVersion': 1,
      'notes': [
        {
          'id': 'person_pharmacist',
          'category': 'person',
          'titleKey': 'pharmacist_title',
          'bodyKey': 'pharmacist_body',
          'entries': ?entries,
        },
      ],
    });

    test('a person file is loaded with its entries, in order', () async {
      final result = await AssetNoteCatalogRepository(
        source({
          chapterAsset('notes.json'): notesWith([
            {'id': 'knows_villa', 'textKey': 'pharmacist_knows_villa'},
            {'id': 'pills_prescribed', 'textKey': 'pharmacist_pills'},
          ]),
        }),
      ).loadNotes('case01');

      final note = result.valueOrNull!['person_pharmacist']!;
      expect(note.category, NoteCategory.person);
      expect(note.entries, const [
        NoteEntryDefinition(
          id: 'knows_villa',
          textKey: 'pharmacist_knows_villa',
        ),
        NoteEntryDefinition(
          id: 'pills_prescribed',
          textKey: 'pharmacist_pills',
        ),
      ]);
      expect(note.entry('pills_prescribed')!.textKey, 'pharmacist_pills');
      expect(note.entry('other'), isNull);
    });

    test('entries are optional', () async {
      final result = await AssetNoteCatalogRepository(
        source({chapterAsset('notes.json'): notesWith(null)}),
      ).loadNotes('case01');

      expect(result.valueOrNull!['person_pharmacist']!.entries, isEmpty);
    });

    test('an entry needs id and textKey', () async {
      final result = await AssetNoteCatalogRepository(
        source({
          chapterAsset('notes.json'): notesWith([
            {'id': 'knows_villa'},
          ]),
        }),
      ).loadNotes('case01');

      expect(result.failureOrNull, isA<ContentFailure>());
      expect(result.failureOrNull!.message, contains('textKey'));
    });

    test('the old category name is rejected', () async {
      final result = await AssetNoteCatalogRepository(
        source({
          chapterAsset('notes.json'): jsonEncode({
            'formatVersion': 1,
            'notes': [
              {
                'id': 'x',
                'category':
                    'sus'
                    'pect',
                'titleKey': 't',
                'bodyKey': 'b',
              },
            ],
          }),
        }),
      ).loadNotes('case01');

      expect(result.failureOrNull, isA<ContentFailure>());
    });
  });
}
