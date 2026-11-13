// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_visual_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectDto _$RectDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RectDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['x', 'y', 'width', 'height']);
      final val = RectDto(
        x: $checkedConvert('x', (v) => (v as num).toDouble()),
        y: $checkedConvert('y', (v) => (v as num).toDouble()),
        width: $checkedConvert('width', (v) => (v as num).toDouble()),
        height: $checkedConvert('height', (v) => (v as num).toDouble()),
      );
      return val;
    });

OverlayDto _$OverlayDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OverlayDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['type', 'rect', 'textKey', 'style', 'rotation'],
      );
      final val = OverlayDto(
        rect: $checkedConvert(
          'rect',
          (v) => RectDto.fromJson(v as Map<String, dynamic>),
        ),
        textKey: $checkedConvert('textKey', (v) => v as String),
        style: $checkedConvert('style', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String? ?? 'text'),
        rotation: $checkedConvert(
          'rotation',
          (v) => (v as num?)?.toDouble() ?? 0,
        ),
      );
      return val;
    });

SceneVisualDto _$SceneVisualDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SceneVisualDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'background',
          'placeholderStyle',
          'overlays',
          'filterPreset',
        ],
      );
      final val = SceneVisualDto(
        placeholderStyle: $checkedConvert(
          'placeholderStyle',
          (v) => v as String,
        ),
        background: $checkedConvert('background', (v) => v as String?),
        overlays: $checkedConvert(
          'overlays',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => OverlayDto.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
        filterPreset: $checkedConvert('filterPreset', (v) => v as String?),
      );
      return val;
    });

VisualVariantDto _$VisualVariantDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VisualVariantDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['when', 'visual']);
      final val = VisualVariantDto(
        when: $checkedConvert('when', (v) => v as Map<String, dynamic>),
        visual: $checkedConvert(
          'visual',
          (v) => SceneVisualDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });
