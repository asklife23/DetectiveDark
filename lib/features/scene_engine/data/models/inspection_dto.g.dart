// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InspectionDto _$InspectionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InspectionDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['id', 'titleKey', 'textKey', 'visual'],
      );
      final val = InspectionDto(
        id: $checkedConvert('id', (v) => v as String),
        textKey: $checkedConvert('textKey', (v) => v as String),
        visual: $checkedConvert(
          'visual',
          (v) => SceneVisualDto.fromJson(v as Map<String, dynamic>),
        ),
        titleKey: $checkedConvert('titleKey', (v) => v as String?),
      );
      return val;
    });

InspectionsFileDto _$InspectionsFileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InspectionsFileDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['formatVersion', 'inspections']);
      final val = InspectionsFileDto(
        formatVersion: $checkedConvert(
          'formatVersion',
          (v) => (v as num).toInt(),
        ),
        inspections: $checkedConvert(
          'inspections',
          (v) => (v as List<dynamic>)
              .map((e) => InspectionDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
