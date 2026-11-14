import 'dart:io';

import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/content_folders.dart';
import '../helpers/content_validation.dart';
import '../helpers/game_harness.dart';
import '../helpers/two_chapter_fixture.dart';

/// The content layout of ADR 0018, on a hand-made case with two chapters:
/// one file or one folder per kind, chapter extensions, missing chapters,
/// validation per chapter prefix, warnings and the `pubspec.yaml` check.
void main() {
  ContentAssetSource source([Map<String, String?> overrides = const {}]) =>
      ContentAssetSource(twoChapterBundle(overrides));

  Future<CaseContent> load([Map<String, String?> overrides = const {}]) async =>
      (await AssetSceneContentRepository(
        source(overrides),
      ).loadCase('case01')).valueOrNull!;

  Future<String> sceneFailure(Map<String, String?> overrides) async {
    final result = await AssetSceneContentRepository(
      source(overrides),
    ).loadCase('case01');
    expect(result.failureOrNull, isA<ContentFailure>());
    return result.failureOrNull!.message;
  }

  Future<Map<String, NoteDefinition>> loadNotes([
    Map<String, String?> overrides = const {},
  ]) async => (await AssetNoteCatalogRepository(
    source(overrides),
  ).loadNotes('case01')).valueOrNull!;

  Future<String> noteFailure(Map<String, String?> overrides) async {
    final result = await AssetNoteCatalogRepository(
      source(overrides),
    ).loadNotes('case01');
    expect(result.failureOrNull, isA<ContentFailure>());
    return result.failureOrNull!.message;
  }

  Future<List<ContentIssue>> validate({
    AssetBundle? bundle,
    int? chapterLimit,
    bool reportUnusedTexts = false,
  }) async => validateLoadedCase(
    await loadCaseForValidation(
      ContentAssetSource(bundle ?? twoChapterBundle()),
      'case01',
      chapterLimit: chapterLimit,
    ),
    styles: fixtureStyles,
    reportUnusedTexts: reportUnusedTexts,
  );

  test('the fixture itself is consistent', () async {
    expect(await validate(reportUnusedTexts: true), isEmpty);
  });

  group('one file or one folder per kind', () {
    test('a folder is read file by file, in name order', () async {
      final content = await load();

      // 01_villa.json (villa, villa_hall), then 02_garden.json (garden),
      // then chapter 2.
      expect(content.scenes.keys, ['villa', 'villa_hall', 'garden', 'cellar']);
      expect(content.sceneChapters, {
        'villa': 'ch01',
        'villa_hall': 'ch01',
        'garden': 'ch01',
        'cellar': 'ch02',
      });
    });

    test('the name decides the order, not the order of the bundle', () async {
      final files = twoChapterFiles();
      final content = await load({
        // Same content under names that sort the other way round.
        ch1('scenes/01_villa.json'): null,
        ch1('scenes/02_garden.json'): null,
        ch1('scenes/b_villa.json'): files[ch1('scenes/01_villa.json')],
        ch1('scenes/a_garden.json'): files[ch1('scenes/02_garden.json')],
      });

      expect(content.scenes.keys.take(3), ['garden', 'villa', 'villa_hall']);
    });

    test('the manifest lists the files of every kind', () async {
      final manifest = await CaseManifest.read(source(), 'case01');
      final first = manifest.chapters.first;

      expect(first.filesOf(ContentType.scenes), [
        ch1('scenes/01_villa.json'),
        ch1('scenes/02_garden.json'),
      ]);
      expect(first.filesOf(ContentType.items), [ch1('items.json')]);
      expect(first.filesOf(ContentType.triggers), isEmpty);
      expect(manifest.chapters.last.filesOf(ContentType.triggers), [
        ch2('triggers.json'),
      ]);
    });

    test('a kind as both file and folder is an error', () async {
      final message = await sceneFailure({
        ch1('scenes.json'): fixtureFile({'scenes': <Object>[]}),
      });

      expect(message, contains('both scenes.json and the folder scenes/'));
      expect(message, contains('"ch01"'));
    });

    test('the same scene ID in two files of a folder is an error', () async {
      final message = await sceneFailure({
        ch1('scenes/03_copy.json'):
            twoChapterFiles()[ch1(
              'scenes/02_garden.json',
            )],
      });

      expect(message, contains('scenes/03_copy.json'));
      expect(message, contains('duplicate scene ID "garden"'));
    });

    test('items, notes, inspections and triggers can be folders too', () async {
      final files = twoChapterFiles();
      final overrides = {
        ch1('items.json'): null,
        ch1('items/keys.json'): files[ch1('items.json')],
        ch1('notes.json'): null,
        ch1('notes/people.json'): files[ch1('notes.json')],
        ch1('inspections.json'): null,
        ch1('inspections/none.json'): files[ch1('inspections.json')],
        ch2('triggers.json'): null,
        ch2('triggers/b_second.json'): fixtureFile({
          'triggers': [
            {
              'id': 'second',
              'when': {'visited': 'villa'},
              'do': [
                {'setFlag': 'x'},
              ],
            },
          ],
        }),
        ch2('triggers/a_first.json'): files[ch2('triggers.json')],
      };

      final content = await load(overrides);
      final items = await AssetItemCatalogRepository(
        source(overrides),
      ).loadItems('case01');
      final notes = await loadNotes(overrides);

      expect(items.valueOrNull!.keys, ['key']);
      expect(notes.keys, ['person_gardener', 'obs_cellar']);
      expect(content.triggers.map((trigger) => trigger.id), [
        'found_the_cellar',
        'second',
      ]);
    });

    test('only .json files directly inside the folder count', () async {
      final content = await load({
        ch1('scenes/README.md'): 'notes for the author',
        ch1('scenes/drafts/old.json'): 'not even JSON',
      });

      expect(content.scenes.keys, hasLength(4));
    });

    test('a broken file inside a folder is named in the failure', () async {
      final message = await sceneFailure({
        ch1('scenes/02_garden.json'): '{"formatVersion": 1,',
      });

      expect(message, contains('scenes/02_garden.json'));
      expect(message, contains('invalid JSON'));
    });
  });

  group('missing chapters', () {
    test('a chapter without any file is skipped', () async {
      final demo = ContentAssetSource(chapterOneOnlyBundle());

      final manifest = await CaseManifest.read(demo, 'case01');
      final content = (await AssetSceneContentRepository(
        demo,
      ).loadCase('case01')).valueOrNull!;
      final notes = (await AssetNoteCatalogRepository(
        demo,
      ).loadNotes('case01')).valueOrNull!;
      final texts = (await ContentTextLoader(
        demo,
      ).load('case01', 'en')).valueOrNull!;

      expect(manifest.chapters.map((chapter) => chapter.id), ['ch01']);
      expect(manifest.skippedChapterIds, ['ch02']);
      expect(content.definition.chapters.map((chapter) => chapter.id), [
        'ch01',
      ]);
      expect(content.scenes.keys, ['villa', 'villa_hall', 'garden']);
      expect(content.triggers, isEmpty);
      // Chapter 2 did not extend anything.
      expect(content.scenes['villa_hall']!.hotspot('trapdoor'), isNull);
      expect(notes['person_gardener']!.entries, hasLength(1));
      expect(texts.has('scene_cellar'), isFalse);
      expect(texts.has('scene_villa'), isTrue);
    });

    test('the game starts with chapter 1 when chapter 2 is absent', () async {
      final game = GameHarness(
        contentRepository: AssetSceneContentRepository(
          ContentAssetSource(chapterOneOnlyBundle()),
        ),
      );
      addTearDown(game.dispose);

      final started = (await game.startGame('case01')).valueOrNull!;

      expect(started.progress.chapterId, 'ch01');
      expect(started.progress.currentSceneId, 'villa');
    });

    test('chapter 1 alone is consistent content', () async {
      expect(await validate(bundle: chapterOneOnlyBundle()), isEmpty);
    });

    test('a chapter that is only partly there is an error', () async {
      final message = await sceneFailure({ch2('items.json'): null});

      expect(message, contains('chapter "ch02" is incomplete'));
      expect(message, contains('items.json'));
    });

    test('a chapter with nothing but a text file is partly there', () async {
      final texts = twoChapterFiles()[ch2('text_en.json')];
      final bundle = chapterOneOnlyBundle({ch2('text_en.json'): texts});

      final result = await AssetSceneContentRepository(
        ContentAssetSource(bundle),
      ).loadCase('case01');

      expect(result.failureOrNull!.message, contains('is incomplete'));
    });

    test('a missing first chapter is an error', () async {
      final message = await sceneFailure({
        for (final path in twoChapterFiles().keys)
          if (path.startsWith(ch1(''))) path: null,
      });

      expect(message, contains('the first chapter "ch01" has no files'));
    });

    test('a chapter after a missing one is an error', () async {
      final files = twoChapterFiles();
      final bundle = chapterOneOnlyBundle({
        fixtureCaseFile: fixtureFile({
          'id': 'case01',
          'chapters': [
            {'id': 'ch01', 'entrySceneId': 'villa'},
            {'id': 'ch02', 'entrySceneId': 'villa'},
            {'id': 'ch03', 'entrySceneId': 'villa'},
          ],
        }),
        for (final file in ['items.json', 'notes.json', 'inspections.json'])
          '${ch1('').replaceFirst('ch01', 'ch03')}$file': files[ch2(file)],
        '${ch1('').replaceFirst('ch01', 'ch03')}scenes.json': fixtureFile({
          'scenes': <Object>[],
        }),
      });

      final result = await AssetSceneContentRepository(
        ContentAssetSource(bundle),
      ).loadCase('case01');

      expect(
        result.failureOrNull!.message,
        contains(
          'chapter "ch03" is present but the earlier chapter "ch02" is '
          'missing',
        ),
      );
    });

    test('a chapter limit keeps only the first chapters', () async {
      final limited = (await AssetSceneContentRepository(
        source(),
        chapterLimit: 1,
      ).loadCase('case01')).valueOrNull!;
      final both = (await AssetSceneContentRepository(
        source(),
        chapterLimit: 2,
      ).loadCase('case01')).valueOrNull!;

      expect(limited.scenes.keys, ['villa', 'villa_hall', 'garden']);
      expect(limited.definition.chapters, hasLength(1));
      expect(both.scenes.keys, hasLength(4));
      expect(await chapterCount(source(), 'case01'), 2);
    });

    test('a chapter limit below 1 is an error', () async {
      final result = await AssetSceneContentRepository(
        source(),
        chapterLimit: 0,
      ).loadCase('case01');

      expect(result.failureOrNull!.message, contains('at least 1'));
    });
  });

  group('sceneExtensions', () {
    test('new hotspots are appended', () async {
      final hall = (await load()).scenes['villa_hall']!;

      expect(hall.hotspots.map((hotspot) => hotspot.id), [
        'chest',
        'lamp',
        'trapdoor',
      ]);
      expect(hall.hotspot('trapdoor')!.interactions.single.effects, const [
        GoToScene('cellar'),
      ]);
    });

    test('new rules are placed before the existing ones', () async {
      final chest = (await load()).scenes['villa_hall']!.hotspot('chest')!;

      expect(chest.interactions, hasLength(2));
      expect(chest.interactions.first.when, const FlagSet('chest_unlocked'));
      expect(chest.interactions.first.effects, const [Say('say_chest_open')]);
      expect(chest.interactions.last.when, isNull);
      expect(chest.interactions.last.effects, const [Say('say_chest_locked')]);
    });

    test('new visual variants are placed before the existing ones', () async {
      final hall = (await load()).scenes['villa_hall']!;

      expect(hall.visualVariants.map((variant) => variant.when), const [
        FlagSet('chest_unlocked'),
        FlagSet('hall_lit'),
      ]);
      expect(hall.visualVariants.first.visual.filterPreset, 'night');
    });

    test('the extended scene keeps its identity and its chapter', () async {
      final content = await load();
      final hall = content.scenes['villa_hall']!;

      expect(hall.parentId, 'villa');
      expect(hall.titleKey, 'scene_hall');
      expect(hall.visual.placeholderStyle, 'plain');
      expect(content.sceneChapters['villa_hall'], 'ch01');
      // The untouched hotspot is exactly what chapter 1 wrote.
      expect(hall.hotspot('lamp')!.interactions.single.effects, const [
        SetFlag('hall_lit'),
      ]);
    });

    String chapterTwoScenes(Map<String, Object?> extension) => fixtureFile({
      'scenes': [
        {
          'id': 'cellar',
          'parentId': 'villa_hall',
          'titleKey': 'scene_cellar',
          'visual': {'placeholderStyle': 'plain'},
        },
      ],
      'sceneExtensions': [extension],
    });

    test('a rule may target a hotspot the same extension adds', () async {
      final content = await load({
        ch2('scenes.json'): chapterTwoScenes({
          'scene': 'garden',
          'hotspots': [
            fixtureHotspot('well', [
              {'say': 'say_well'},
            ]),
          ],
          'rules': [
            {
              'hotspot': 'well',
              'interactions': [
                {
                  'when': {'hasItem': 'key'},
                  'do': [
                    {'say': 'say_well_deep'},
                  ],
                },
              ],
            },
          ],
        }),
      });

      final well = content.scenes['garden']!.hotspot('well')!;
      expect(well.interactions.map((rule) => rule.effects.single), const [
        Say('say_well_deep'),
        Say('say_well'),
      ]);
    });

    test('an unknown scene is an error', () async {
      final message = await sceneFailure({
        ch2('scenes.json'): chapterTwoScenes({'scene': 'attic'}),
      });

      expect(message, contains('scenes.json'));
      expect(message, contains('sceneExtensions: unknown scene "attic"'));
    });

    test('a scene of the same chapter cannot be extended', () async {
      final message = await sceneFailure({
        ch2('scenes.json'): chapterTwoScenes({'scene': 'cellar'}),
      });

      expect(message, contains('"cellar" is not from an earlier chapter'));
    });

    test('the first chapter has nothing to extend', () async {
      final message = await sceneFailure({
        ch1('scenes/03_more.json'): fixtureFile({
          'sceneExtensions': [
            {'scene': 'garden'},
          ],
        }),
      });

      expect(message, contains('"garden" is not from an earlier chapter'));
    });

    test(
      'a new hotspot with an ID the scene already has is an error',
      () async {
        final message = await sceneFailure({
          ch2('scenes.json'): chapterTwoScenes({
            'scene': 'villa_hall',
            'hotspots': [
              fixtureHotspot('chest', [
                {'say': 'x'},
              ]),
            ],
          }),
        });

        expect(
          message,
          contains(
            'sceneExtensions "villa_hall": hotspot ID "chest" already exists',
          ),
        );
      },
    );

    test('rules for a hotspot the scene does not have are an error', () async {
      final message = await sceneFailure({
        ch2('scenes.json'): chapterTwoScenes({
          'scene': 'villa_hall',
          'rules': [
            {
              'hotspot': 'safe',
              'interactions': [
                {
                  'do': [
                    {'say': 'x'},
                  ],
                },
              ],
            },
          ],
        }),
      });

      expect(message, contains('the scene has no hotspot "safe"'));
    });

    test('an unknown key in an extension is rejected', () async {
      final message = await sceneFailure({
        ch2('scenes.json'): chapterTwoScenes({
          'scene': 'villa_hall',
          'onFirstEnter': <Object>[],
        }),
      });

      expect(message, contains('onFirstEnter'));
    });

    test(
      'a broken rule in an extension names the file and the scene',
      () async {
        final message = await sceneFailure({
          ch2('scenes.json'): chapterTwoScenes({
            'scene': 'villa_hall',
            'rules': [
              {
                'hotspot': 'chest',
                'interactions': [
                  {
                    'do': [
                      {'sayy': 'x'},
                    ],
                  },
                ],
              },
            ],
          }),
        });

        expect(message, contains('scenes.json'));
        expect(message, contains('sceneExtensions "villa_hall"'));
        expect(message, contains('Unknown effect "sayy"'));
      },
    );
  });

  group('noteExtensions', () {
    test('new entries are appended to the catalog of the note', () async {
      final gardener = (await loadNotes())['person_gardener']!;

      expect(gardener.entries.map((entry) => entry.id), [
        'works_here',
        'hid_the_lever',
      ]);
      expect(gardener.titleKey, 'gardener_title');
      expect(gardener.category, NoteCategory.person);
    });

    String chapterTwoNotes(Map<String, Object?> extension) => fixtureFile({
      'notes': [
        {
          'id': 'obs_cellar',
          'category': 'observation',
          'titleKey': 'obs_cellar_title',
          'bodyKey': 'obs_cellar_body',
        },
      ],
      'noteExtensions': [extension],
    });

    test('an unknown note is an error', () async {
      final message = await noteFailure({
        ch2('notes.json'): chapterTwoNotes({
          'note': 'person_cook',
          'entries': <Object>[],
        }),
      });

      expect(message, contains('notes.json'));
      expect(message, contains('noteExtensions: unknown note "person_cook"'));
    });

    test('a note of the same chapter cannot be extended', () async {
      final message = await noteFailure({
        ch2('notes.json'): chapterTwoNotes({
          'note': 'obs_cellar',
          'entries': <Object>[],
        }),
      });

      expect(message, contains('"obs_cellar" is not from an earlier chapter'));
    });

    test('an entry ID the note already has is an error', () async {
      final message = await noteFailure({
        ch2('notes.json'): chapterTwoNotes({
          'note': 'person_gardener',
          'entries': [
            {'id': 'works_here', 'textKey': 'x'},
          ],
        }),
      });

      expect(
        message,
        contains(
          'noteExtensions "person_gardener": entry ID "works_here" already '
          'exists',
        ),
      );
    });
  });

  group('validation per chapter prefix', () {
    test('every prefix of the fixture is consistent on its own', () async {
      expect(await validate(chapterLimit: 1), isEmpty);
      expect(await validate(chapterLimit: 2), isEmpty);
    });

    test('chapter 1 reading a flag only chapter 2 sets is caught', () async {
      final files = twoChapterFiles();
      final bundle = twoChapterBundle({
        ch1('scenes/02_garden.json'): files[ch1('scenes/02_garden.json')]!
            .replaceFirst(
              '"labelKey":"label"',
              '"labelKey":"label","visibleWhen":{"flag":"chest_unlocked"}',
            ),
      });

      final whole = await validate(bundle: bundle);
      final chapterOne = await validate(bundle: bundle, chapterLimit: 1);

      // With both chapters the flag is set (by the lever in the cellar)...
      expect(whole, isEmpty);
      // ...but chapter 1 alone, the demo, could never show the gardener.
      expect(
        chapterOne.map((issue) => '$issue'),
        contains(contains('flag "chest_unlocked" is read but never set')),
      );
    });

    test('chapter 1 using a text or a scene of chapter 2 is caught', () async {
      final files = twoChapterFiles();
      final bundle = twoChapterBundle({
        ch1('scenes/02_garden.json'): files[ch1('scenes/02_garden.json')]!
            .replaceFirst('"giveItem":"key"', '"say":"say_chest_open"')
            .replaceFirst('"labelKey":"label"', '"labelKey":"scene_cellar"'),
      });

      final whole = await validate(bundle: bundle);
      final chapterOne = await validate(bundle: bundle, chapterLimit: 1);

      expect(whole, isEmpty);
      expect(
        chapterOne.map((issue) => '$issue'),
        containsAll([
          contains('missing text "say_chest_open" (en)'),
          contains('missing text "scene_cellar" (en)'),
        ]),
      );
    });
  });

  group('warnings', () {
    test('an unused text key is a warning, not an error', () async {
      final bundle = twoChapterBundle({
        ch2('text_en.json'): twoChapterFiles()[ch2('text_en.json')]!
            .replaceFirst(
              '"scene_cellar"',
              '"say_removed_line":"Gone.","scene_cellar"',
            ),
      });

      final issues = await validate(bundle: bundle, reportUnusedTexts: true);

      expect(issues.errors, isEmpty);
      expect(issues.warnings, const [
        ContentIssue(
          'texts',
          'text "say_removed_line" is never used',
          severity: ContentSeverity.warning,
        ),
      ]);
      expect(
        '${issues.single}',
        'warning: texts: text "say_removed_line" is never used',
      );
    });

    test('without the option no unused texts are reported', () async {
      final bundle = twoChapterBundle({
        ch2('text_en.json'): twoChapterFiles()[ch2('text_en.json')]!
            .replaceFirst(
              '"scene_cellar"',
              '"say_removed_line":"Gone.","scene_cellar"',
            ),
      });

      expect(await validate(bundle: bundle), isEmpty);
    });

    test('an error is an error', () {
      const issue = ContentIssue('scene yard', 'unknown scene "x"');

      expect(issue.isError, isTrue);
      expect(issue.isWarning, isFalse);
      expect('$issue', 'scene yard: unknown scene "x"');
      expect([issue].errors, [issue]);
      expect([issue].warnings, isEmpty);
    });
  });

  group('every content folder is declared in pubspec.yaml', () {
    late Directory project;

    setUp(() {
      project = Directory.systemTemp.createTempSync('content_folders_test');
      for (final file in [
        'assets/content/common/text_en.json',
        'assets/content/cases/case01/case.json',
        'assets/content/cases/case01/chapters/ch01/items.json',
        'assets/content/cases/case01/chapters/ch01/scenes/villa.json',
        'assets/fonts/font.ttf',
      ]) {
        File('${project.path}/$file')
          ..createSync(recursive: true)
          ..writeAsStringSync('{}');
      }
    });
    tearDown(() => project.deleteSync(recursive: true));

    const complete = '''
flutter:
  assets:
    - assets/fonts/font.ttf
    # Game content.
    - assets/content/common/
    - assets/content/cases/case01/
    - assets/content/cases/case01/chapters/ch01/
    - path: assets/content/cases/case01/chapters/ch01/scenes/
''';

    test('folders that hold files are found on disk', () {
      expect(contentFoldersOnDisk(project), [
        'assets/content/cases/case01/',
        'assets/content/cases/case01/chapters/ch01/',
        'assets/content/cases/case01/chapters/ch01/scenes/',
        'assets/content/common/',
      ]);
    });

    test('folder entries are read from pubspec.yaml, plain and with path:', () {
      expect(declaredContentFolders(complete), [
        'assets/content/common/',
        'assets/content/cases/case01/',
        'assets/content/cases/case01/chapters/ch01/',
        'assets/content/cases/case01/chapters/ch01/scenes/',
      ]);
    });

    test('a complete list has no problems', () {
      expect(
        contentFolderProblems(
          pubspecYaml: complete,
          foldersOnDisk: contentFoldersOnDisk(project),
        ),
        isEmpty,
      );
    });

    test('a folder missing from pubspec.yaml is reported by name', () {
      final forgotten = complete.replaceFirst(
        '    - path: assets/content/cases/case01/chapters/ch01/scenes/\n',
        '',
      );

      expect(
        contentFolderProblems(
          pubspecYaml: forgotten,
          foldersOnDisk: contentFoldersOnDisk(project),
        ),
        [
          contains(
            'assets/content/cases/case01/chapters/ch01/scenes/ holds '
            'content files but is not listed',
          ),
        ],
      );
    });

    test('a listed folder that does not exist is reported too', () {
      expect(
        contentFolderProblems(
          pubspecYaml:
              '$complete    - assets/content/cases/case01/chapters/ch02/\n',
          foldersOnDisk: contentFoldersOnDisk(project),
        ),
        [
          contains(
            'pubspec.yaml lists assets/content/cases/case01/chapters/ch02/',
          ),
        ],
      );
    });

    test('a folder with only subfolders needs no entry', () {
      expect(
        contentFoldersOnDisk(project),
        isNot(contains('assets/content/cases/')),
      );
    });
  });
}
