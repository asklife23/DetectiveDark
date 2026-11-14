import 'dart:convert';

import 'package:detective_dark/features/scene_engine/domain/services/content_validator.dart';

import 'fake_asset_bundle.dart';

/// A small, consistent case with **two chapters**, for tests of the content
/// layout (ADR 0018). Nothing here is real game content.
///
/// - Chapter 1 splits its scenes into a folder (`scenes/01_villa.json`,
///   `scenes/02_garden.json`): a villa with a hall and a garden.
/// - Chapter 2 uses single files. It adds a cellar and **extends** chapter
///   1 from its own files: a trapdoor and a new first rule for the chest in
///   the hall, a new look of the hall, and a new line in the gardener's
///   file. It also brings a trigger.

const _case = 'assets/content/cases/case01';

/// Asset path of a file of chapter 1 / chapter 2 of the fixture.
String ch1(String file) => '$_case/chapters/ch01/$file';
String ch2(String file) => '$_case/chapters/ch02/$file';

const fixtureCaseFile = '$_case/case.json';

/// The style names the fixture uses.
const fixtureStyles = KnownStyleNames(
  overlayStyles: {'engraved'},
  filterPresets: {'night'},
  placeholderStyles: {'plain', 'lit'},
);

const _rect = {'x': 0.1, 'y': 0.1, 'width': 0.2, 'height': 0.2};

Map<String, Object?> _hotspot(
  String id,
  List<Map<String, Object?>> effects, {
  Map<String, Object?>? visibleWhen,
}) => {
  'id': id,
  'rect': _rect,
  'labelKey': 'label',
  'visibleWhen': ?visibleWhen,
  'interactions': [
    {'do': effects},
  ],
};

String _file(Map<String, Object?> content) =>
    jsonEncode({'formatVersion': 1, ...content});

/// The files of the fixture: asset path → JSON text.
Map<String, String> twoChapterFiles() => {
  fixtureCaseFile: _file({
    'id': 'case01',
    'chapters': [
      {'id': 'ch01', 'entrySceneId': 'villa'},
      {'id': 'ch02', 'entrySceneId': 'villa'},
    ],
  }),
  'assets/content/common/text_en.json': _file({
    'texts': {'generic_item_no_effect': 'No use.'},
  }),

  // ------------------------------------------------------------ chapter 1
  ch1('scenes/01_villa.json'): _file({
    'scenes': [
      {
        'id': 'villa',
        'titleKey': 'scene_villa',
        'visual': {'placeholderStyle': 'plain'},
        'hotspots': [
          _hotspot('door', [
            {'goToScene': 'villa_hall'},
          ]),
          _hotspot('path', [
            {'goToScene': 'garden'},
          ]),
        ],
      },
      {
        'id': 'villa_hall',
        'parentId': 'villa',
        'titleKey': 'scene_hall',
        'visual': {'placeholderStyle': 'plain'},
        'visualVariants': [
          {
            'when': {'flag': 'hall_lit'},
            'visual': {'placeholderStyle': 'lit'},
          },
        ],
        'hotspots': [
          _hotspot('chest', [
            {'say': 'say_chest_locked'},
          ]),
          _hotspot('lamp', [
            {'setFlag': 'hall_lit'},
          ]),
        ],
      },
    ],
  }),
  ch1('scenes/02_garden.json'): _file({
    'scenes': [
      {
        'id': 'garden',
        'parentId': 'villa',
        'titleKey': 'scene_garden',
        'visual': {'placeholderStyle': 'plain'},
        'hotspots': [
          _hotspot('gardener', [
            {
              'addNoteEntry': {
                'note': 'person_gardener',
                'entry': 'works_here',
              },
            },
            {'giveItem': 'key'},
          ]),
        ],
      },
    ],
  }),
  ch1('items.json'): _file({
    'items': [
      {
        'id': 'key',
        'nameKey': 'key_name',
        'descriptionKey': 'key_description',
        'iconStyle': 'plain',
      },
    ],
  }),
  ch1('notes.json'): _file({
    'notes': [
      {
        'id': 'person_gardener',
        'category': 'person',
        'titleKey': 'gardener_title',
        'bodyKey': 'gardener_body',
        'entries': [
          {'id': 'works_here', 'textKey': 'gardener_works_here'},
        ],
      },
    ],
  }),
  ch1('inspections.json'): _file({'inspections': <Object>[]}),
  ch1('text_en.json'): _file({
    'texts': {
      'scene_villa': 'Villa',
      'scene_hall': 'Hall',
      'scene_garden': 'Garden',
      'label': 'Something',
      'say_chest_locked': 'Locked.',
      'key_name': 'Key',
      'key_description': 'A key.',
      'gardener_title': 'The gardener',
      'gardener_body': 'Keeps the grounds.',
      'gardener_works_here': 'Has worked here for years.',
    },
  }),

  // ------------------------------------------------------------ chapter 2
  ch2('scenes.json'): _file({
    'scenes': [
      {
        'id': 'cellar',
        'parentId': 'villa_hall',
        'titleKey': 'scene_cellar',
        'visual': {'placeholderStyle': 'plain'},
        'hotspots': [
          _hotspot('lever', [
            {'setFlag': 'chest_unlocked'},
          ]),
        ],
      },
    ],
    'sceneExtensions': [
      {
        'scene': 'villa_hall',
        'hotspots': [
          _hotspot('trapdoor', [
            {'goToScene': 'cellar'},
          ]),
        ],
        'rules': [
          {
            'hotspot': 'chest',
            'interactions': [
              {
                'when': {'flag': 'chest_unlocked'},
                'do': [
                  {'say': 'say_chest_open'},
                ],
              },
            ],
          },
        ],
        'visualVariants': [
          {
            'when': {'flag': 'chest_unlocked'},
            'visual': {'placeholderStyle': 'lit', 'filterPreset': 'night'},
          },
        ],
      },
    ],
  }),
  ch2('items.json'): _file({'items': <Object>[]}),
  ch2('notes.json'): _file({
    'notes': [
      {
        'id': 'obs_cellar',
        'category': 'observation',
        'titleKey': 'obs_cellar_title',
        'bodyKey': 'obs_cellar_body',
      },
    ],
    'noteExtensions': [
      {
        'note': 'person_gardener',
        'entries': [
          {'id': 'hid_the_lever', 'textKey': 'gardener_hid_the_lever'},
        ],
      },
    ],
  }),
  ch2('inspections.json'): _file({'inspections': <Object>[]}),
  ch2('triggers.json'): _file({
    'triggers': [
      {
        'id': 'found_the_cellar',
        'when': {'visited': 'cellar'},
        'do': [
          {'addNote': 'obs_cellar'},
          {
            'addNoteEntry': {
              'note': 'person_gardener',
              'entry': 'hid_the_lever',
            },
          },
        ],
      },
    ],
  }),
  ch2('text_en.json'): _file({
    'texts': {
      'scene_cellar': 'Cellar',
      'say_chest_open': 'Open.',
      'obs_cellar_title': 'The cellar',
      'obs_cellar_body': 'There is a cellar under the hall.',
      'gardener_hid_the_lever': 'Knew about the lever all along.',
    },
  }),
};

/// The fixture as an asset bundle. [overrides] replaces files (asset path →
/// content); a `null` value removes the file.
FakeAssetBundle twoChapterBundle([Map<String, String?> overrides = const {}]) {
  final files = <String, String?>{...twoChapterFiles(), ...overrides};
  return FakeAssetBundle({
    for (final MapEntry(:key, :value) in files.entries) key: ?value,
  });
}

/// The fixture without any file of chapter 2: what a demo build ships.
FakeAssetBundle chapterOneOnlyBundle([
  Map<String, String?> overrides = const {},
]) => twoChapterBundle({
  for (final path in twoChapterFiles().keys)
    if (path.startsWith(ch2(''))) path: null,
  ...overrides,
});

/// A content file of the fixture format: `formatVersion` plus [content].
String fixtureFile(Map<String, Object?> content) => _file(content);

/// A simple hotspot in fixture JSON.
Map<String, Object?> fixtureHotspot(
  String id,
  List<Map<String, Object?>> effects, {
  Map<String, Object?>? visibleWhen,
}) => _hotspot(id, effects, visibleWhen: visibleWhen);
