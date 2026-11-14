import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/rule_parser.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dialogue_dto.g.dart';

/// JSON form of a [DialoguePortrait].
@JsonSerializable()
class PortraitDto {
  const PortraitDto({required this.placeholderStyle, this.image});

  factory PortraitDto.fromJson(Map<String, dynamic> json) =>
      _$PortraitDtoFromJson(json);

  final String placeholderStyle;
  final String? image;

  DialoguePortrait toEntity() =>
      DialoguePortrait(placeholderStyle: placeholderStyle, image: image);
}

/// JSON form of a [DialogueTopic].
///
/// `visibleWhen` and `do` are written in the rule language of the scene
/// engine. They are kept as raw JSON here and turned into conditions and
/// effects by a [RuleParser] in [toEntity]: this feature's data layer may
/// not import the codecs of another feature's data layer.
@JsonSerializable()
class TopicDto {
  const TopicDto({
    required this.id,
    required this.promptKey,
    required this.answer,
    this.visibleWhen,
    this.trigger,
    this.effects = const [],
  });

  factory TopicDto.fromJson(Map<String, dynamic> json) =>
      _$TopicDtoFromJson(json);

  static const _showItem = 'showItem';
  static const _showNote = 'showNote';

  final String id;
  final String promptKey;
  final List<String> answer;
  final Map<String, dynamic>? visibleWhen;
  final Map<String, dynamic>? trigger;

  @JsonKey(name: 'do')
  final List<Map<String, dynamic>> effects;

  DialogueTopic toEntity(RuleParser rules) {
    try {
      return DialogueTopic(
        id: id,
        promptKey: promptKey,
        answer: List.unmodifiable(answer),
        visibleWhen: visibleWhen == null
            ? null
            : rules.parseCondition(visibleWhen),
        trigger: _trigger(trigger),
        effects: rules.parseEffects(effects),
      );
    } on FormatException catch (error) {
      throw FormatException('topic "$id": ${error.message}');
    }
  }

  /// `{"showItem": id}` or `{"showNote": id}`: exactly one of them.
  static TopicTrigger? _trigger(Map<String, dynamic>? json) {
    if (json == null) return null;
    final value = json.length == 1 ? json.values.single : null;
    if (value is String && value.isNotEmpty) {
      switch (json.keys.single) {
        case _showItem:
          return ShowItem(value);
        case _showNote:
          return ShowNote(value);
      }
    }
    throw FormatException(
      '"trigger" needs exactly one of "$_showItem" or "$_showNote" with an '
      'ID, got: $json',
    );
  }
}

/// JSON form of a [DialogueDefinition].
@JsonSerializable()
class DialogueDto {
  const DialogueDto({
    required this.id,
    required this.nameKey,
    required this.portrait,
    required this.greeting,
    required this.noReactionKey,
    this.topics = const [],
  });

  factory DialogueDto.fromJson(Map<String, dynamic> json) =>
      _$DialogueDtoFromJson(json);

  static const _greetingKeys = {'first', 'then'};

  final String id;
  final String nameKey;
  final PortraitDto portrait;

  /// A text key, or `{"first": ..., "then": ...}` like a `say` effect.
  final Object greeting;
  final String noReactionKey;
  final List<TopicDto> topics;

  DialogueDefinition toEntity(RuleParser rules) {
    try {
      return DialogueDefinition(
        id: id,
        nameKey: nameKey,
        portrait: portrait.toEntity(),
        greeting: _greeting(greeting),
        noReactionKey: noReactionKey,
        topics: List.unmodifiable(topics.map((topic) => topic.toEntity(rules))),
      );
    } on FormatException catch (error) {
      throw FormatException('dialogue "$id": ${error.message}');
    }
  }

  static DialogueGreeting _greeting(Object json) {
    if (json is String && json.isNotEmpty) return DialogueGreeting(json);
    if (json is Map<String, dynamic>) {
      final unknown = json.keys.where((key) => !_greetingKeys.contains(key));
      if (unknown.isNotEmpty) {
        throw FormatException(
          'Unknown "greeting" keys: ${unknown.join(', ')}. '
          'Known: ${_greetingKeys.join(', ')}.',
        );
      }
      final first = json['first'];
      final then = json['then'];
      if (first is String &&
          first.isNotEmpty &&
          then is String &&
          then.isNotEmpty) {
        return DialogueGreeting(first, thenKey: then);
      }
    }
    throw const FormatException(
      '"greeting" needs a text key or an object with both "first" and '
      '"then" as non-empty strings.',
    );
  }
}

/// One entry of `dialogueExtensions`: topics a later chapter adds to a
/// dialogue of an earlier chapter (ADR 0018). They are appended.
@JsonSerializable()
class DialogueExtensionDto {
  const DialogueExtensionDto({required this.dialogue, required this.topics});

  factory DialogueExtensionDto.fromJson(Map<String, dynamic> json) =>
      _$DialogueExtensionDtoFromJson(json);

  /// ID of the dialogue to extend.
  final String dialogue;
  final List<TopicDto> topics;

  /// [target] with the new topics at the end. Throws a [FormatException]
  /// when a topic ID is already taken.
  DialogueDefinition applyTo(DialogueDefinition target, RuleParser rules) {
    try {
      final added = topics.map((topic) => topic.toEntity(rules)).toList();
      final taken = {for (final topic in target.topics) topic.id};
      for (final topic in added) {
        if (!taken.add(topic.id)) {
          throw FormatException('topic ID "${topic.id}" already exists');
        }
      }
      return DialogueDefinition(
        id: target.id,
        nameKey: target.nameKey,
        portrait: target.portrait,
        greeting: target.greeting,
        noReactionKey: target.noReactionKey,
        topics: List.unmodifiable([...target.topics, ...added]),
      );
    } on FormatException catch (error) {
      throw FormatException(
        'dialogueExtensions "$dialogue": ${error.message}',
      );
    }
  }
}

/// A dialogues file (`dialogues.json` or one file of `dialogues/`): the
/// conversations of one chapter and, optionally, extensions of
/// conversations of earlier chapters.
@JsonSerializable()
class DialoguesFileDto {
  const DialoguesFileDto({
    required this.formatVersion,
    this.dialogues = const [],
    this.dialogueExtensions = const [],
  });

  factory DialoguesFileDto.fromJson(Map<String, dynamic> json) =>
      _$DialoguesFileDtoFromJson(json);

  final int formatVersion;
  final List<DialogueDto> dialogues;
  final List<DialogueExtensionDto> dialogueExtensions;
}
