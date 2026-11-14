// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_extension_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleExtensionDto _$RuleExtensionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RuleExtensionDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['hotspot', 'interactions']);
      final val = RuleExtensionDto(
        hotspot: $checkedConvert('hotspot', (v) => v as String),
        interactions: $checkedConvert(
          'interactions',
          (v) => (v as List<dynamic>)
              .map(
                (e) => InteractionRuleDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

SceneExtensionDto _$SceneExtensionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SceneExtensionDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['scene', 'hotspots', 'rules', 'visualVariants'],
  );
  final val = SceneExtensionDto(
    scene: $checkedConvert('scene', (v) => v as String),
    hotspots: $checkedConvert(
      'hotspots',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => HotspotDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    ),
    rules: $checkedConvert(
      'rules',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => RuleExtensionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    ),
    visualVariants: $checkedConvert(
      'visualVariants',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => VisualVariantDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    ),
  );
  return val;
});
