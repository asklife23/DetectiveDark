import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';
import 'package:equatable/equatable.dart';

/// A topic as it stands in the question list.
class TopicView extends Equatable {
  const TopicView({required this.topic, required this.isAsked});

  final DialogueTopic topic;

  /// The player has asked it (or shown what opens it) before.
  final bool isAsked;

  /// Visible but never asked: the list marks it as new.
  bool get isNew => !isAsked;

  @override
  List<Object?> get props => [topic, isAsked];
}

/// Works out which questions a conversation offers for a given progress.
/// Pure Dart.
///
/// **A topic is visible when it was asked, OR when it has no `trigger` and
/// its `visibleWhen` holds.** So:
/// - a topic that was asked once stays in the list for good, even if its
///   condition fails later (the bottle was handed over): the answer can
///   always be read again;
/// - a topic with a `trigger` is not offered until its evidence was shown.
class DialogueViewResolver {
  const DialogueViewResolver({this._evaluator = const ConditionEvaluator()});

  final ConditionEvaluator _evaluator;

  bool isVisible(
    DialogueDefinition dialogue,
    DialogueTopic topic,
    GameProgress progress,
  ) =>
      progress.hasAsked(dialogue.id, topic.id) ||
      (topic.trigger == null && _evaluator.holds(topic.visibleWhen, progress));

  /// The questions on offer, in content order.
  List<TopicView> visibleTopics(
    DialogueDefinition dialogue,
    GameProgress progress,
  ) => List.unmodifiable([
    for (final topic in dialogue.topics)
      if (isVisible(dialogue, topic, progress))
        TopicView(
          topic: topic,
          isAsked: progress.hasAsked(dialogue.id, topic.id),
        ),
  ]);

  /// The greeting to play now: the first form until it was heard once.
  String greetingKey(DialogueDefinition dialogue, GameProgress progress) {
    final greeting = dialogue.greeting;
    final thenKey = greeting.thenKey;
    return thenKey != null && progress.hasSpoken(greeting.firstKey)
        ? thenKey
        : greeting.firstKey;
  }
}
