import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';

/// Builds the navigation stack of a scene.
///
/// The stack is always the chain of parents of the scene, root first:
/// `villa_hall` → `[villa_exterior, villa_door_closeup, villa_hall]`. So
/// Back always leads to the parent scene, no matter where the player came
/// from, and the whole stack can be rebuilt from one scene ID.
class SceneStackResolver {
  const SceneStackResolver();

  Result<List<String>> stackFor(
    String sceneId,
    Map<String, SceneDefinition> scenes,
  ) {
    final chain = <String>[];
    String? currentId = sceneId;

    while (currentId != null) {
      final scene = scenes[currentId];
      if (scene == null) {
        return Failed(ContentFailure('Unknown scene "$currentId".'));
      }
      if (chain.contains(currentId)) {
        return Failed(
          ContentFailure('Scene "$currentId" is its own ancestor.'),
        );
      }
      chain.add(currentId);
      currentId = scene.parentId;
    }

    return Success(List.unmodifiable(chain.reversed));
  }
}
