import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_issue.dart';

/// The shared part of one content validation run: the checks every rule
/// needs (does this text exist, does this condition point at real things,
/// is this effect allowed here) and what must be remembered **across**
/// validators.
///
/// Scenes are checked by `ContentValidator`, conversations by the dialogue
/// feature's validator. Both write into one [ContentChecks], because some
/// rules span both: a flag set by a dialogue topic may be read by a
/// hotspot, a `first` line must be unique among `say` effects and
/// greetings together, and a text is "used" no matter who uses it. Call
/// [flagIssues] once every validator has run.
class ContentChecks {
  ContentChecks({
    required this.content,
    required this.items,
    required this.notes,
    required this.textKeysByLanguage,
    this.dialogueTopics = const {},
    Set<String>? usedTextKeys,
  }) : usedTextKeys = usedTextKeys ?? {};

  static const _insideNotOrAtLeast = 'inside not / atLeast';

  final CaseContent content;
  final Map<String, ItemDefinition> items;
  final Map<String, NoteDefinition> notes;

  /// Language code → the text keys that exist in that language.
  final Map<String, Set<String>> textKeysByLanguage;

  /// The conversations that exist: dialogue ID → its topic IDs. Plain data
  /// instead of dialogue entities, so `scene_engine` does not depend on the
  /// dialogue feature (features must not depend on each other in a cycle).
  final Map<String, Set<String>> dialogueTopics;

  /// Every text key the content refers to, collected while checking.
  final Set<String> usedTextKeys;

  /// The dialogues some `talk` effect opens, collected while checking.
  final talkedDialogueIds = <String>{};

  final _issues = <ContentIssue>[];
  final _flagsRead = <String, String>{};
  final _flagsSet = <String>{};
  final _firstLines = <String, String>{};

  /// Everything found so far, by any validator.
  List<ContentIssue> get issues => List.unmodifiable(_issues);

  void add(String where, String message) =>
      _issues.add(ContentIssue(where, message));

  void warn(String where, String message) => _issues.add(
    ContentIssue(where, message, severity: ContentSeverity.warning),
  );

  /// [key] must exist in every supported language.
  void text(String where, String key) {
    usedTextKeys.add(key);
    textKeysByLanguage.forEach((language, keys) {
      if (!keys.contains(key)) add(where, 'missing text "$key" ($language)');
    });
  }

  void optionalText(String where, String? key) {
    if (key != null) text(where, key);
  }

  /// Checks what [condition] refers to and notes the flags it reads.
  ///
  /// [noUsingItem] names a place where `usingItem` is forbidden ("in a
  /// trigger"); null where it is allowed. Inside `not` and `atLeast` it is
  /// always forbidden, at any depth.
  void condition(String where, Condition condition, {String? noUsingItem}) {
    void inner(Condition c, {String? ban}) =>
        this.condition(where, c, noUsingItem: noUsingItem ?? ban);

    switch (condition) {
      case FlagSet(:final flag) || FlagNotSet(:final flag):
        _flagsRead.putIfAbsent(flag, () => where);
      case HasItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
      case UsingItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
        if (noUsingItem != null) {
          add(where, 'usingItem cannot be used $noUsingItem');
        }
      case HasNote(:final noteId):
        if (!notes.containsKey(noteId)) add(where, 'unknown note "$noteId"');
      case AllOf(:final conditions) || AnyOf(:final conditions):
        conditions.forEach(inner);
      case Not(condition: final negated):
        inner(negated, ban: _insideNotOrAtLeast);
      case AtLeast(:final count, :final conditions):
        if (count < 1 || count > conditions.length) {
          add(
            where,
            'atLeast count $count must be between 1 and '
            '${conditions.length}',
          );
        }
        for (final c in conditions) {
          inner(c, ban: _insideNotOrAtLeast);
        }
      case Visited(:final sceneId) || InScene(:final sceneId):
        if (!content.scenes.containsKey(sceneId)) {
          add(where, 'unknown scene "$sceneId"');
        }
      case HasAsked(:final dialogueId, :final topicId):
        final topics = dialogueTopics[dialogueId];
        if (topics == null) {
          add(where, 'unknown dialogue "$dialogueId"');
        } else if (!topics.contains(topicId)) {
          add(where, 'dialogue "$dialogueId" has no topic "$topicId"');
        }
    }
  }

  /// Checks what [effect] refers to and notes the flag it sets.
  void effect(String where, Effect effect) {
    switch (effect) {
      case GoToScene(:final sceneId):
        if (!content.scenes.containsKey(sceneId)) {
          add(where, 'unknown scene "$sceneId"');
        }
      case GiveItem(:final itemId) || ConsumeItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
      case AddNote(:final noteId):
        if (!notes.containsKey(noteId)) add(where, 'unknown note "$noteId"');
      case AddNoteEntry(:final noteId, :final entryId):
        final note = notes[noteId];
        if (note == null) {
          add(where, 'unknown note "$noteId"');
        } else if (note.entry(entryId) == null) {
          add(where, 'note "$noteId" has no entry "$entryId"');
        }
      case SetFlag(:final flag):
        _flagsSet.add(flag);
      case Say(:final messageKey, :final repeatKey):
        text(where, messageKey);
        if (repeatKey != null) {
          text(where, repeatKey);
          firstLine(where, messageKey);
        }
      case Inspect(:final inspectionId):
        if (!content.inspections.containsKey(inspectionId)) {
          add(where, 'unknown inspection "$inspectionId"');
        }
      case Talk(:final dialogueId):
        talkedDialogueIds.add(dialogueId);
        if (!dialogueTopics.containsKey(dialogueId)) {
          add(where, 'unknown dialogue "$dialogueId"');
        }
      case HideHotspot():
        break;
    }
  }

  /// Checks a list of effects of a place where only some kinds are
  /// [allowed] (`onFirstEnter`, a trigger, a dialogue topic). [allowedNames]
  /// is the list shown in the message.
  void restrictedEffects(
    String where,
    List<Effect> effects, {
    required bool Function(Effect effect) allowed,
    required String allowedNames,
  }) {
    for (final effect in effects) {
      if (!allowed(effect)) {
        add(
          where,
          '${effect.runtimeType} is not allowed here (only $allowedNames)',
        );
      }
      this.effect(where, effect);
    }
  }

  /// The `first` key of a two-form line (`say` first/then, a greeting) must
  /// be unique in the case: it is the key under which "already said" is
  /// saved, so a second use would start out as already spoken.
  void firstLine(String where, String key) {
    final earlier = _firstLines[key];
    if (earlier == null) {
      _firstLines[key] = where;
    } else {
      add(where, 'first line "$key" is already used at $earlier');
    }
  }

  /// A flag that is read but never set is almost always a typo. Call this
  /// last: every validator must have seen its `setFlag` effects first.
  ///
  /// Adds the issues to [issues] and returns them.
  List<ContentIssue> flagIssues() {
    final found = <ContentIssue>[];
    _flagsRead.forEach((flag, where) {
      if (!_flagsSet.contains(flag)) {
        found.add(ContentIssue(where, 'flag "$flag" is read but never set'));
      }
    });
    _issues.addAll(found);
    return found;
  }
}
