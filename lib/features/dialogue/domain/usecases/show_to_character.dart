import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/ask_topic.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';

/// Shows an item or a note to a character (ADR 0016).
///
/// The first topic that waits for exactly this evidence plays: its effects
/// run (handing an item over is simply a `consumeItem` among them) and it
/// joins the question list as asked. Showing the same thing again only
/// replays the answer. Evidence that means nothing to the character gets
/// the character's shrug (`noReactionKey`): no penalty, no mark, nothing
/// saved.
class ShowToCharacter {
  const ShowToCharacter({
    required this._askTopic,
    this._evaluator = const ConditionEvaluator(),
  });

  final AskTopic _askTopic;
  final ConditionEvaluator _evaluator;

  /// [shown] is what the player holds out: `ShowItem(itemId)` or
  /// `ShowNote(noteId)`. Something the player does not have cannot be
  /// shown: nothing happens.
  ///
  /// [triggers] are the triggers of the case (`CaseContent.triggers`).
  Future<Result<TopicReply>> call({
    required DialogueDefinition dialogue,
    required TopicTrigger shown,
    required GameProgress progress,
    required List<TriggerDefinition> triggers,
  }) async {
    final hasIt = switch (shown) {
      ShowItem(:final itemId) => progress.hasItem(itemId),
      ShowNote(:final noteId) => progress.hasNote(noteId),
    };
    if (!hasIt) return Success(TopicReply.none(progress));

    for (final topic in dialogue.topics) {
      if (topic.trigger != shown) continue;
      // A topic that already played can always be replayed; an unplayed
      // one needs its condition to hold.
      final isOpen =
          progress.hasAsked(dialogue.id, topic.id) ||
          _evaluator.holds(topic.visibleWhen, progress);
      if (!isOpen) continue;

      return _askTopic.play(
        dialogue: dialogue,
        topic: topic,
        progress: progress,
        triggers: triggers,
      );
    }

    return Success(
      TopicReply(progress: progress, lineKeys: [dialogue.noReactionKey]),
    );
  }
}
