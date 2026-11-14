import 'package:detective_dark/features/scene_engine/data/models/condition_codec.dart';
import 'package:detective_dark/features/scene_engine/data/models/effect_codec.dart';
import 'package:detective_dark/features/scene_engine/data/models/scene_visual_dto.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scene_dto.g.dart';

/// JSON form of an [InteractionRule]: `when` (optional) and `do`.
@JsonSerializable()
class InteractionRuleDto {
  const InteractionRuleDto({required this.effects, this.when});

  factory InteractionRuleDto.fromJson(Map<String, dynamic> json) =>
      _$InteractionRuleDtoFromJson(json);

  final Map<String, dynamic>? when;

  @JsonKey(name: 'do')
  final List<Map<String, dynamic>> effects;

  InteractionRule toEntity() => InteractionRule(
    when: when == null ? null : ConditionCodec.parse(when),
    effects: EffectCodec.parseList(effects),
  );
}

/// JSON form of a [HotspotSprite].
@JsonSerializable()
class SpriteDto {
  const SpriteDto({
    required this.rect,
    required this.placeholderStyle,
    this.image,
  });

  factory SpriteDto.fromJson(Map<String, dynamic> json) =>
      _$SpriteDtoFromJson(json);

  final RectDto rect;
  final String placeholderStyle;
  final String? image;

  HotspotSprite toEntity() => HotspotSprite(
    rect: rect.toEntity(),
    placeholderStyle: placeholderStyle,
    image: image,
  );
}

/// JSON form of a [HotspotDefinition].
@JsonSerializable()
class HotspotDto {
  const HotspotDto({
    required this.id,
    required this.rect,
    required this.labelKey,
    this.visibleWhen,
    this.interactions = const [],
    this.glint = false,
    this.sprite,
  });

  factory HotspotDto.fromJson(Map<String, dynamic> json) =>
      _$HotspotDtoFromJson(json);

  final String id;
  final RectDto rect;
  final String labelKey;
  final Map<String, dynamic>? visibleWhen;
  final List<InteractionRuleDto> interactions;
  final bool glint;
  final SpriteDto? sprite;

  HotspotDefinition toEntity() {
    try {
      return HotspotDefinition(
        id: id,
        rect: rect.toEntity(),
        labelKey: labelKey,
        visibleWhen: visibleWhen == null
            ? null
            : ConditionCodec.parse(visibleWhen),
        interactions: List.unmodifiable(
          interactions.map((rule) => rule.toEntity()),
        ),
        glint: glint,
        sprite: sprite?.toEntity(),
      );
    } on FormatException catch (error) {
      throw FormatException('hotspot "$id": ${error.message}');
    }
  }
}

/// JSON form of a [SceneDefinition].
@JsonSerializable()
class SceneDto {
  const SceneDto({
    required this.id,
    required this.titleKey,
    required this.visual,
    this.parentId,
    this.visualVariants = const [],
    this.hotspots = const [],
    this.onFirstEnter = const [],
  });

  factory SceneDto.fromJson(Map<String, dynamic> json) =>
      _$SceneDtoFromJson(json);

  final String id;
  final String? parentId;
  final String titleKey;
  final SceneVisualDto visual;
  final List<VisualVariantDto> visualVariants;
  final List<HotspotDto> hotspots;
  final List<Map<String, dynamic>> onFirstEnter;

  SceneDefinition toEntity() {
    try {
      return SceneDefinition(
        id: id,
        parentId: parentId,
        titleKey: titleKey,
        visual: visual.toEntity(),
        visualVariants: List.unmodifiable(
          visualVariants.map((variant) => variant.toEntity()),
        ),
        hotspots: List.unmodifiable(
          hotspots.map((hotspot) => hotspot.toEntity()),
        ),
        onFirstEnter: EffectCodec.parseList(onFirstEnter),
      );
    } on FormatException catch (error) {
      throw FormatException('scene "$id": ${error.message}');
    }
  }
}

/// `scenes.json`: the scenes of one chapter.
@JsonSerializable()
class ScenesFileDto {
  const ScenesFileDto({required this.formatVersion, required this.scenes});

  factory ScenesFileDto.fromJson(Map<String, dynamic> json) =>
      _$ScenesFileDtoFromJson(json);

  final int formatVersion;
  final List<SceneDto> scenes;
}
