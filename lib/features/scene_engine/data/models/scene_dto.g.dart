// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InteractionRuleDto _$InteractionRuleDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InteractionRuleDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['when', 'do']);
      final val = InteractionRuleDto(
        effects: $checkedConvert(
          'do',
          (v) => (v as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList(),
        ),
        when: $checkedConvert('when', (v) => v as Map<String, dynamic>?),
      );
      return val;
    }, fieldKeyMap: const {'effects': 'do'});

SpriteDto _$SpriteDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SpriteDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const ['rect', 'placeholderStyle', 'image', 'overlays'],
    );
    final val = SpriteDto(
      rect: $checkedConvert(
        'rect',
        (v) => RectDto.fromJson(v as Map<String, dynamic>),
      ),
      placeholderStyle: $checkedConvert('placeholderStyle', (v) => v as String),
      image: $checkedConvert('image', (v) => v as String?),
      overlays: $checkedConvert(
        'overlays',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => OverlayDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
    );
    return val;
  },
);

HotspotDto _$HotspotDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HotspotDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'rect',
          'labelKey',
          'visibleWhen',
          'interactions',
          'glint',
          'sprite',
        ],
      );
      final val = HotspotDto(
        id: $checkedConvert('id', (v) => v as String),
        rect: $checkedConvert(
          'rect',
          (v) => RectDto.fromJson(v as Map<String, dynamic>),
        ),
        labelKey: $checkedConvert('labelKey', (v) => v as String),
        visibleWhen: $checkedConvert(
          'visibleWhen',
          (v) => v as Map<String, dynamic>?,
        ),
        interactions: $checkedConvert(
          'interactions',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) =>
                        InteractionRuleDto.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const [],
        ),
        glint: $checkedConvert('glint', (v) => v as bool? ?? false),
        sprite: $checkedConvert(
          'sprite',
          (v) =>
              v == null ? null : SpriteDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

SceneDto _$SceneDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SceneDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'parentId',
          'titleKey',
          'visual',
          'visualVariants',
          'hotspots',
          'onFirstEnter',
        ],
      );
      final val = SceneDto(
        id: $checkedConvert('id', (v) => v as String),
        titleKey: $checkedConvert('titleKey', (v) => v as String),
        visual: $checkedConvert(
          'visual',
          (v) => SceneVisualDto.fromJson(v as Map<String, dynamic>),
        ),
        parentId: $checkedConvert('parentId', (v) => v as String?),
        visualVariants: $checkedConvert(
          'visualVariants',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) => VisualVariantDto.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const [],
        ),
        hotspots: $checkedConvert(
          'hotspots',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => HotspotDto.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
        onFirstEnter: $checkedConvert(
          'onFirstEnter',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              const [],
        ),
      );
      return val;
    });

ScenesFileDto _$ScenesFileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ScenesFileDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['formatVersion', 'scenes', 'sceneExtensions'],
      );
      final val = ScenesFileDto(
        formatVersion: $checkedConvert(
          'formatVersion',
          (v) => (v as num).toInt(),
        ),
        scenes: $checkedConvert(
          'scenes',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => SceneDto.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
        sceneExtensions: $checkedConvert(
          'sceneExtensions',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) =>
                        SceneExtensionDto.fromJson(e as Map<String, dynamic>),
                  )
                  .toList() ??
              const [],
        ),
      );
      return val;
    });
