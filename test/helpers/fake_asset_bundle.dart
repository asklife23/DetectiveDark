import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An [AssetBundle] that serves strings from memory, so content loaders can
/// be tested with small, deliberately broken JSON.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.files);

  /// Asset path → file content.
  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final content = files[key];
    if (content == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(utf8.encode(content));
  }
}

const _chapter = 'assets/content/cases/case01/chapters/ch01';

/// A minimal, valid case with one scene. Tests replace single files with
/// [overrides] (asset path → content); a `null` value removes the file.
FakeAssetBundle minimalCaseBundle([Map<String, String?> overrides = const {}]) {
  final files = <String, String?>{
    'assets/content/cases/case01/case.json': jsonEncode({
      'formatVersion': 1,
      'id': 'case01',
      'chapters': [
        {'id': 'ch01', 'entrySceneId': 'yard'},
      ],
    }),
    '$_chapter/scenes.json': jsonEncode({
      'formatVersion': 1,
      'scenes': [
        {
          'id': 'yard',
          'titleKey': 'scene_yard',
          'visual': {'placeholderStyle': 'villa_exterior'},
        },
      ],
    }),
    '$_chapter/inspections.json': jsonEncode({
      'formatVersion': 1,
      'inspections': <Object>[],
    }),
    '$_chapter/items.json': jsonEncode({
      'formatVersion': 1,
      'items': <Object>[],
    }),
    '$_chapter/notes.json': jsonEncode({
      'formatVersion': 1,
      'notes': <Object>[],
    }),
    '$_chapter/text_en.json': jsonEncode({
      'formatVersion': 1,
      'texts': {'scene_yard': 'Yard'},
    }),
    'assets/content/common/text_en.json': jsonEncode({
      'formatVersion': 1,
      'texts': {'generic_item_no_effect': 'No use.'},
    }),
    ...overrides,
  };

  return FakeAssetBundle({
    for (final MapEntry(:key, :value) in files.entries) key: ?value,
  });
}

/// Asset path of a file in the single chapter of [minimalCaseBundle].
String chapterAsset(String file) => '$_chapter/$file';
