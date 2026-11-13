import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_stack_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

SceneDefinition _scene(String id, {String? parentId}) => SceneDefinition(
  id: id,
  parentId: parentId,
  titleKey: 'scene_$id',
  visual: const SceneVisual(placeholderStyle: 'generic'),
);

Map<String, SceneDefinition> _scenes(List<SceneDefinition> scenes) => {
  for (final scene in scenes) scene.id: scene,
};

void main() {
  const resolver = SceneStackResolver();
  final scenes = _scenes([
    _scene('villa_exterior'),
    _scene('villa_door_closeup', parentId: 'villa_exterior'),
    _scene('villa_hall', parentId: 'villa_door_closeup'),
    _scene('statue_closeup', parentId: 'villa_exterior'),
  ]);

  test('a main location is a stack of one', () {
    expect(resolver.stackFor('villa_exterior', scenes).valueOrNull, [
      'villa_exterior',
    ]);
  });

  test('a nested scene gets its whole chain of parents, root first', () {
    expect(resolver.stackFor('villa_hall', scenes).valueOrNull, [
      'villa_exterior',
      'villa_door_closeup',
      'villa_hall',
    ]);
  });

  test('an unknown scene is a content failure', () {
    final result = resolver.stackFor('cellar', scenes);

    expect(result.failureOrNull, isA<ContentFailure>());
  });

  test('a missing parent is a content failure', () {
    final broken = _scenes([_scene('attic', parentId: 'roof')]);

    expect(
      resolver.stackFor('attic', broken).failureOrNull,
      isA<ContentFailure>(),
    );
  });

  test('a parent cycle is a content failure instead of an endless loop', () {
    final cyclic = _scenes([
      _scene('a', parentId: 'b'),
      _scene('b', parentId: 'a'),
    ]);

    expect(resolver.stackFor('a', cyclic).failureOrNull, isA<ContentFailure>());
  });
}
