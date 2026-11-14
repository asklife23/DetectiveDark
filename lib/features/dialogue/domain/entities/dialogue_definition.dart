import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:equatable/equatable.dart';

/// The picture of a character in the dialogue panel.
class DialoguePortrait extends Equatable {
  const DialoguePortrait({required this.placeholderStyle, this.image});

  /// Name of the placeholder drawing, used while [image] is null.
  final String placeholderStyle;

  /// Real artwork (asset path).
  final String? image;

  @override
  List<Object?> get props => [placeholderStyle, image];
}

/// What a character says when the conversation opens.
///
/// Like a `say` effect it has one or two forms: with a [thenKey] the
/// character says [firstKey] the first time and [thenKey] from then on.
/// "Heard before" is remembered in the save (`spokenLines`), under
/// [firstKey].
class DialogueGreeting extends Equatable {
  const DialogueGreeting(this.firstKey, {this.thenKey});

  final String firstKey;
  final String? thenKey;

  @override
  List<Object?> get props => [firstKey, thenKey];
}

/// What has to be shown to a character for a topic to play.
sealed class TopicTrigger extends Equatable {
  const TopicTrigger();
}

/// The topic plays when this item is shown (or handed over).
final class ShowItem extends TopicTrigger {
  const ShowItem(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// The topic plays when this note is shown.
final class ShowNote extends TopicTrigger {
  const ShowNote(this.noteId);

  final String noteId;

  @override
  List<Object?> get props => [noteId];
}

/// One prewritten question and the answer of the character.
class DialogueTopic extends Equatable {
  const DialogueTopic({
    required this.id,
    required this.promptKey,
    required this.answer,
    this.visibleWhen,
    this.trigger,
    this.effects = const [],
  });

  /// Unique inside its dialogue.
  final String id;

  /// The question as it stands in the list.
  final String promptKey;

  /// The lines of the character, shown one at a time. Never empty.
  final List<String> answer;

  /// While this is false an unasked topic is not offered.
  final Condition? visibleWhen;

  /// When set, the topic is not in the list at first: it plays when the
  /// item or note is shown, and stays in the list afterwards.
  final TopicTrigger? trigger;

  /// What happens the **first** time the topic is asked. Allowed: `say`,
  /// `setFlag`, `addNote`, `addNoteEntry`, `giveItem`, `consumeItem`.
  final List<Effect> effects;

  @override
  List<Object?> get props => [
    id,
    promptKey,
    answer,
    visibleWhen,
    trigger,
    effects,
  ];
}

/// A conversation with one character (ADR 0016): who it is, how they greet
/// the detective and which questions can be asked.
///
/// The player only picks prewritten questions. Questions reveal
/// information; they never branch the story.
class DialogueDefinition extends Equatable {
  const DialogueDefinition({
    required this.id,
    required this.nameKey,
    required this.portrait,
    required this.greeting,
    required this.noReactionKey,
    this.topics = const [],
  });

  /// Unique inside the case.
  final String id;

  final String nameKey;
  final DialoguePortrait portrait;
  final DialogueGreeting greeting;

  /// What the character says to something that means nothing to them.
  final String noReactionKey;

  /// In the order they are listed.
  final List<DialogueTopic> topics;

  DialogueTopic? topic(String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    nameKey,
    portrait,
    greeting,
    noReactionKey,
    topics,
  ];
}
