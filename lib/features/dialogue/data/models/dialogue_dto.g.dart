// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialogue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortraitDto _$PortraitDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PortraitDto',
  json,
  ($checkedConvert) {
    $checkKeys(json, allowedKeys: const ['placeholderStyle', 'image']);
    final val = PortraitDto(
      placeholderStyle: $checkedConvert('placeholderStyle', (v) => v as String),
      image: $checkedConvert('image', (v) => v as String?),
    );
    return val;
  },
);

TopicDto _$TopicDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TopicDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'promptKey',
          'answer',
          'visibleWhen',
          'trigger',
          'do',
        ],
      );
      final val = TopicDto(
        id: $checkedConvert('id', (v) => v as String),
        promptKey: $checkedConvert('promptKey', (v) => v as String),
        answer: $checkedConvert(
          'answer',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        visibleWhen: $checkedConvert(
          'visibleWhen',
          (v) => v as Map<String, dynamic>?,
        ),
        trigger: $checkedConvert('trigger', (v) => v as Map<String, dynamic>?),
        effects: $checkedConvert(
          'do',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              const [],
        ),
      );
      return val;
    }, fieldKeyMap: const {'effects': 'do'});

DialogueDto _$DialogueDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DialogueDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'nameKey',
          'portrait',
          'greeting',
          'noReactionKey',
          'topics',
        ],
      );
      final val = DialogueDto(
        id: $checkedConvert('id', (v) => v as String),
        nameKey: $checkedConvert('nameKey', (v) => v as String),
        portrait: $checkedConvert(
          'portrait',
          (v) => PortraitDto.fromJson(v as Map<String, dynamic>),
        ),
        greeting: $checkedConvert('greeting', (v) => v as Object),
        noReactionKey: $checkedConvert('noReactionKey', (v) => v as String),
        topics: $checkedConvert(
          'topics',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => TopicDto.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
      );
      return val;
    });

DialogueExtensionDto _$DialogueExtensionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DialogueExtensionDto', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['dialogue', 'topics']);
  final val = DialogueExtensionDto(
    dialogue: $checkedConvert('dialogue', (v) => v as String),
    topics: $checkedConvert(
      'topics',
      (v) => (v as List<dynamic>)
          .map((e) => TopicDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

DialoguesFileDto _$DialoguesFileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DialoguesFileDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['formatVersion', 'dialogues', 'dialogueExtensions'],
  );
  final val = DialoguesFileDto(
    formatVersion: $checkedConvert('formatVersion', (v) => (v as num).toInt()),
    dialogues: $checkedConvert(
      'dialogues',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => DialogueDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    ),
    dialogueExtensions: $checkedConvert(
      'dialogueExtensions',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) => DialogueExtensionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    ),
  );
  return val;
});
