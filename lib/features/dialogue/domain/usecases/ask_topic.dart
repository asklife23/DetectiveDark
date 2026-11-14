import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:equatable/equatable.dart';

/// What the character answers and what that changed.
class TopicReply extends Equatable {
  const TopicReply({
    required this.progress,
    required this.lineKeys,
    this.isFirstTime = false,
  });

  /// Nothing to say and nothing changed.
  const TopicReply.none(this.progress)
    : lineKeys = const [],
      isFirstTime = false;

  /// The progress afterwards (unchanged when the topic was asked before).
  final GameProgress progress;

  /// The lines of the character to play, in order. Empty when nothing
  /// happened.
  final List<String> lineKeys;

  /// Whether the effects of the topic ran now.
  final bool isFirstTime;

  @override
  List<Object?> get props => [progress, lineKeys, isFirstTime];
}

/// Asks a character one of the prewritten questions.
///
/// The first time, the effects of the topic run and the topic is written
/// to `askedTopics`, all through the effect pipeline: triggers are
/// evaluated in the same save ("both were asked about the villa"). Asking
/// again changes nothing and only replays the answer.
///
/// The lines of the character are not part of the detective's message
/// history (`chatLog`). A comment of the detective is a `say` among the
/// effects of the topic.
class AskTopic {
  const AskTopic({
    required this._pipeline,
    required this._clock,
    this._viewResolver = const DialogueViewResolver(),
  });

  final EffectPipeline _pipeline;
  final Clock _clock;
  final DialogueViewResolver _viewResolver;

  /// Asks the topic [topicId] of [dialogue]. A topic that is not on offer
  /// right now (unknown, hidden by its condition, or waiting for evidence)
  /// does nothing.
  ///
  /// [triggers] are the triggers of the case (`CaseContent.triggers`).
  Future<Result<TopicReply>> call({
    required DialogueDefinition dialogue,
    required String topicId,
    required GameProgress progress,
    required List<TriggerDefinition> triggers,
  }) async {
    final topic = dialogue.topic(topicId);
    if (topic == null || !_viewResolver.isVisible(dialogue, topic, progress)) {
      return Success(TopicReply.none(progress));
    }
    return play(
      dialogue: dialogue,
      topic: topic,
      progress: progress,
      triggers: triggers,
    );
  }

  /// Plays [topic] without asking whether it is on offer. This is what
  /// showing evidence does with a topic that waits for it.
  Future<Result<TopicReply>> play({
    required DialogueDefinition dialogue,
    required DialogueTopic topic,
    required GameProgress progress,
    required List<TriggerDefinition> triggers,
  }) async {
    if (progress.hasAsked(dialogue.id, topic.id)) {
      return Success(TopicReply(progress: progress, lineKeys: topic.answer));
    }

    final outcome = await _pipeline.run(
      progress: progress,
      prepare: (progress) => progress.withAskedTopic(dialogue.id, topic.id),
      effects: topic.effects,
      context: EffectContext(
        sceneId: progress.currentSceneId ?? '',
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
      triggers: triggers,
      leadingEvents: [TopicAsked(dialogue.id, topic.id)],
    );

    return switch (outcome) {
      Success(:final value) => Success(
        TopicReply(
          progress: value.progress,
          lineKeys: topic.answer,
          isFirstTime: true,
        ),
      ),
      Failed(:final failure) => Failed(failure),
    };
  }
}
