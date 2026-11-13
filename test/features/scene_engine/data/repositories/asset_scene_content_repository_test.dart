import 'dart:convert';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_asset_bundle.dart';

void main() {
  AssetSceneContentRepository repository(Map<String, String?> overrides) =>
      AssetSceneContentRepository(
        ContentAssetSource(minimalCaseBundle(overrides)),
      );

  String scenesJson(List<Map<String, Object?>> scenes) =>
      jsonEncode({'formatVersion': 1, 'scenes': scenes});

  Future<String> failureMessage(Map<String, String?> overrides) async {
    final result = await repository(overrides).loadCase('case01');
    expect(result.failureOrNull, isA<ContentFailure>());
    return result.failureOrNull!.message;
  }

  test('loads the case with its chapters and scenes', () async {
    final content = (await repository({}).loadCase('case01')).valueOrNull!;

    expect(content.definition.id, 'case01');
    expect(content.definition.chapters.single.entrySceneId, 'yard');
    expect(content.scenes.keys, ['yard']);
    expect(content.sceneChapters, {'yard': 'ch01'});
    expect(content.inspections, isEmpty);
  });

  test('turns the JSON of a full scene into entities', () async {
    final result = await repository({
      chapterAsset('scenes.json'): scenesJson([
        {
          'id': 'yard',
          'titleKey': 'scene_yard',
          'visual': {
            'placeholderStyle': 'villa_exterior',
            'filterPreset': 'night',
            'overlays': [
              {
                'rect': {'x': 0.1, 'y': 0.2, 'width': 0.3, 'height': 0.1},
                'textKey': 'number',
                'style': 'brass',
                'rotation': 4,
              },
            ],
          },
          'visualVariants': [
            {
              'when': {'flag': 'gate_open'},
              'visual': {'placeholderStyle': 'villa_door_open'},
            },
          ],
          'onFirstEnter': [
            {'say': 'first_look'},
          ],
          'hotspots': [
            {
              'id': 'gate',
              'rect': {'x': 0, 'y': 0, 'width': 0.5, 'height': 1},
              'labelKey': 'hotspot_gate',
              'glint': true,
              'visibleWhen': {'notFlag': 'gate_gone'},
              'interactions': [
                {
                  'when': {'usingItem': 'key'},
                  'do': [
                    {'setFlag': 'gate_open'},
                  ],
                },
                {
                  'do': [
                    {'say': 'locked'},
                  ],
                },
              ],
            },
          ],
        },
      ]),
    }).loadCase('case01');

    final scene = result.valueOrNull!.scenes['yard']!;
    expect(scene.visual.filterPreset, 'night');
    final overlay = scene.visual.overlays.single as TextOverlay;
    expect(overlay.style, 'brass');
    expect(overlay.rotation, 4);
    expect(scene.visualVariants.single.when, const FlagSet('gate_open'));
    expect(scene.onFirstEnter, const [Say('first_look')]);

    final gate = scene.hotspot('gate')!;
    expect(gate.glint, isTrue);
    expect(gate.rect.width, 0.5);
    expect(gate.visibleWhen, const FlagNotSet('gate_gone'));
    expect(gate.interactions.first.when, const UsingItem('key'));
    expect(gate.interactions.first.effects, const [SetFlag('gate_open')]);
    expect(gate.interactions.last.when, isNull);
  });

  test('a missing file fails with its path', () async {
    final message = await failureMessage({chapterAsset('scenes.json'): null});

    expect(message, contains('scenes.json'));
    expect(message, contains('missing'));
  });

  test('invalid JSON fails with the file name', () async {
    final message = await failureMessage({
      chapterAsset('scenes.json'): '{"formatVersion": 1,',
    });

    expect(message, contains('scenes.json'));
    expect(message, contains('invalid JSON'));
  });

  test('an unsupported format version is rejected', () async {
    final message = await failureMessage({
      chapterAsset('scenes.json'): jsonEncode({
        'formatVersion': 2,
        'scenes': <Object>[],
      }),
    });

    expect(message, contains('formatVersion'));
  });

  test('a misspelled field name is rejected, not ignored', () async {
    final message = await failureMessage({
      chapterAsset('scenes.json'): scenesJson([
        {
          'id': 'yard',
          'titleKey': 'scene_yard',
          'visual': {'placeholderStyle': 'villa_exterior'},
          'hotspotz': <Object>[],
        },
      ]),
    });

    expect(message, contains('scenes.json'));
    expect(message, contains('hotspotz'));
  });

  test('an unknown effect names the scene and the hotspot', () async {
    final message = await failureMessage({
      chapterAsset('scenes.json'): scenesJson([
        {
          'id': 'yard',
          'titleKey': 'scene_yard',
          'visual': {'placeholderStyle': 'villa_exterior'},
          'hotspots': [
            {
              'id': 'gate',
              'rect': {'x': 0, 'y': 0, 'width': 0.5, 'height': 1},
              'labelKey': 'hotspot_gate',
              'interactions': [
                {
                  'do': [
                    {'teleport': 'moon'},
                  ],
                },
              ],
            },
          ],
        },
      ]),
    });

    expect(message, contains('scene "yard"'));
    expect(message, contains('hotspot "gate"'));
    expect(message, contains('Unknown effect "teleport"'));
  });

  test('a duplicate scene ID is rejected', () async {
    const scene = {
      'id': 'yard',
      'titleKey': 'scene_yard',
      'visual': {'placeholderStyle': 'villa_exterior'},
    };
    final message = await failureMessage({
      chapterAsset('scenes.json'): scenesJson([scene, scene]),
    });

    expect(message, contains('duplicate scene ID "yard"'));
  });

  test('a case.json whose id does not match its folder is rejected', () async {
    final message = await failureMessage({
      'assets/content/cases/case01/case.json': jsonEncode({
        'formatVersion': 1,
        'id': 'case02',
        'chapters': [
          {'id': 'ch01', 'entrySceneId': 'yard'},
        ],
      }),
    });

    expect(message, contains('case.json'));
    expect(message, contains('case02'));
  });
}
