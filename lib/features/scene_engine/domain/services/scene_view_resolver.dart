import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';

/// Works out what a scene looks like for a given progress: which visual is
/// shown and which hotspots exist right now. Pure Dart.
class SceneViewResolver {
  const SceneViewResolver({this._evaluator = const ConditionEvaluator()});

  final ConditionEvaluator _evaluator;

  /// The first variant whose condition holds, otherwise the default visual.
  SceneVisual visualFor(SceneDefinition scene, GameProgress progress) {
    for (final variant in scene.visualVariants) {
      if (_evaluator.evaluate(variant.when, progress)) return variant.visual;
    }
    return scene.visual;
  }

  /// Whether the player can currently see and tap [hotspot].
  bool isVisible(
    SceneDefinition scene,
    HotspotDefinition hotspot,
    GameProgress progress,
  ) =>
      !progress.isHotspotHidden(scene.id, hotspot.id) &&
      _evaluator.holds(hotspot.visibleWhen, progress);

  /// The hotspots that exist right now, in content order (later ones lie
  /// on top of earlier ones).
  List<HotspotDefinition> visibleHotspots(
    SceneDefinition scene,
    GameProgress progress,
  ) => List.unmodifiable(
    scene.hotspots.where((hotspot) => isVisible(scene, hotspot, progress)),
  );
}
