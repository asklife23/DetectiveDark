import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_checks.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_issue.dart';

/// Checks the conversations of a case. Pure Dart.
///
/// The scene side (`talk` effects, `topicAsked` conditions) is checked by
/// the scene engine's `ContentValidator`, which only gets the dialogue and
/// topic IDs as plain data: the dependency runs one way, from this feature
/// to the scene engine. Both validators write into the same
/// [ContentChecks], so the rules that span both hold: flags, `first` lines
/// and used texts.
///
/// Run it **after** the scene validator (it needs to know which dialogues a
/// `talk` opens) and call `checks.flagIssues()` after both.
class DialogueValidator {
  const DialogueValidator();

  /// Effects allowed in a topic.
  static const _topicEffects =
      'say, setFlag, addNote, addNoteEntry, giveItem, consumeItem';

  /// Dialogue ID → topic IDs: the plain data the scene validator needs.
  static Map<String, Set<String>> topicIds(
    Map<String, DialogueDefinition> dialogues,
  ) => {
    for (final dialogue in dialogues.values)
      dialogue.id: {for (final topic in dialogue.topics) topic.id},
  };

  /// [portraitStyles] are the placeholder drawings that exist in code.
  /// Returns the issues of this call; they are also added to [checks].
  List<ContentIssue> validate({
    required Map<String, DialogueDefinition> dialogues,
    required ContentChecks checks,
    required Set<String> portraitStyles,
  }) {
    final before = checks.issues.length;

    for (final dialogue in dialogues.values) {
      final where = 'dialogue ${dialogue.id}';
      checks
        ..text(where, dialogue.nameKey)
        ..text(where, dialogue.noReactionKey)
        ..text('$where / greeting', dialogue.greeting.firstKey);
      if (dialogue.greeting.thenKey case final thenKey?) {
        checks
          ..text('$where / greeting', thenKey)
          // Greetings share `spokenLines` with `say` first/then.
          ..firstLine('$where / greeting', dialogue.greeting.firstKey);
      }
      if (!portraitStyles.contains(dialogue.portrait.placeholderStyle)) {
        checks.add(
          where,
          'unknown portrait placeholder style '
          '"${dialogue.portrait.placeholderStyle}"',
        );
      }
      if (!checks.talkedDialogueIds.contains(dialogue.id)) {
        checks.warn(where, 'no talk effect opens this dialogue');
      }

      final seen = <String>{};
      for (final topic in dialogue.topics) {
        final at = '$where / topic ${topic.id}';
        if (!seen.add(topic.id)) {
          checks.add(at, 'duplicate topic ID in this dialogue');
        }
        _topic(checks, at, topic);
      }
    }

    return checks.issues.sublist(before);
  }

  void _topic(ContentChecks checks, String at, DialogueTopic topic) {
    checks.text(at, topic.promptKey);
    if (topic.answer.isEmpty) checks.add(at, 'has no answer lines');
    for (final line in topic.answer) {
      checks.text(at, line);
    }

    if (topic.visibleWhen case final visibleWhen?) {
      checks.condition(
        '$at / visibleWhen',
        visibleWhen,
        noUsingItem: 'in a dialogue topic',
      );
    }

    switch (topic.trigger) {
      case ShowItem(:final itemId):
        if (!checks.items.containsKey(itemId)) {
          checks.add('$at / trigger', 'unknown item "$itemId"');
        }
      case ShowNote(:final noteId):
        if (!checks.notes.containsKey(noteId)) {
          checks.add('$at / trigger', 'unknown note "$noteId"');
        }
      case null:
        break;
    }

    checks.restrictedEffects(
      at,
      topic.effects,
      allowed: (effect) =>
          effect is Say ||
          effect is SetFlag ||
          effect is AddNote ||
          effect is AddNoteEntry ||
          effect is GiveItem ||
          effect is ConsumeItem,
      allowedNames: _topicEffects,
    );
  }
}
