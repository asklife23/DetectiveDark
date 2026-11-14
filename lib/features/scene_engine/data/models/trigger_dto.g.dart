// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerDto _$TriggerDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TriggerDto',
  json,
  ($checkedConvert) {
    $checkKeys(json, allowedKeys: const ['id', 'when', 'do']);
    final val = TriggerDto(
      id: $checkedConvert('id', (v) => v as String),
      when: $checkedConvert('when', (v) => v as Map<String, dynamic>),
      effects: $checkedConvert(
        'do',
        (v) =>
            (v as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'effects': 'do'},
);

TriggersFileDto _$TriggersFileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TriggersFileDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['formatVersion', 'triggers']);
      final val = TriggersFileDto(
        formatVersion: $checkedConvert(
          'formatVersion',
          (v) => (v as num).toInt(),
        ),
        triggers: $checkedConvert(
          'triggers',
          (v) => (v as List<dynamic>)
              .map((e) => TriggerDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
