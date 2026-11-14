import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';

/// Answers a [Condition] for a given state of the game. A pure function:
/// the same inputs always give the same answer.
class ConditionEvaluator {
  const ConditionEvaluator();

  /// [usingItemId] is the item selected in the inventory at the moment of
  /// the tap, if any. Without it every [UsingItem] is false.
  bool evaluate(
    Condition condition,
    GameProgress progress, {
    String? usingItemId,
  }) {
    bool check(Condition inner) =>
        evaluate(inner, progress, usingItemId: usingItemId);

    return switch (condition) {
      FlagSet(:final flag) => progress.hasFlag(flag),
      FlagNotSet(:final flag) => !progress.hasFlag(flag),
      HasItem(:final itemId) => progress.hasItem(itemId),
      UsingItem(:final itemId) => usingItemId == itemId,
      HasNote(:final noteId) => progress.hasNote(noteId),
      AllOf(:final conditions) => conditions.every(check),
      AnyOf(:final conditions) => conditions.any(check),
      Not(condition: final inner) => !check(inner),
      AtLeast(:final count, :final conditions) =>
        conditions.where(check).length >= count,
      Visited(:final sceneId) => progress.hasVisited(sceneId),
      InScene(:final sceneId) => progress.currentSceneId == sceneId,
      HasAsked(:final dialogueId, :final topicId) => progress.hasAsked(
        dialogueId,
        topicId,
      ),
    };
  }

  /// Like [evaluate], but an absent condition counts as true.
  bool holds(
    Condition? condition,
    GameProgress progress, {
    String? usingItemId,
  }) =>
      condition == null ||
      evaluate(condition, progress, usingItemId: usingItemId);
}
