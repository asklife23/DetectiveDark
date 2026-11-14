import 'package:detective_dark/features/scene_engine/data/models/scene_dto.dart';
import 'package:detective_dark/features/scene_engine/data/models/scene_visual_dto.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scene_extension_dto.g.dart';

/// New rules for one existing hotspot, inside a [SceneExtensionDto].
@JsonSerializable()
class RuleExtensionDto {
  const RuleExtensionDto({required this.hotspot, required this.interactions});

  factory RuleExtensionDto.fromJson(Map<String, dynamic> json) =>
      _$RuleExtensionDtoFromJson(json);

  /// ID of the hotspot that gets the rules.
  final String hotspot;
  final List<InteractionRuleDto> interactions;
}

/// One entry of `sceneExtensions`: what a later chapter adds to a scene of
/// an earlier chapter (ADR 0018), without touching that chapter's files.
///
/// ```json
/// {"scene": "villa_hall",
///  "hotspots": [ ...new hotspots, appended... ],
///  "rules": [{"hotspot": "chest", "interactions": [ ...placed first... ]}],
///  "visualVariants": [ ...placed first... ]}
/// ```
///
/// New rules and visual variants go **in front of** the existing ones,
/// because the first match wins: the newer chapter gets the first say. New
/// hotspots go at the end (they lie on top where areas overlap).
@JsonSerializable()
class SceneExtensionDto {
  const SceneExtensionDto({
    required this.scene,
    this.hotspots = const [],
    this.rules = const [],
    this.visualVariants = const [],
  });

  factory SceneExtensionDto.fromJson(Map<String, dynamic> json) =>
      _$SceneExtensionDtoFromJson(json);

  /// ID of the scene to extend.
  final String scene;
  final List<HotspotDto> hotspots;
  final List<RuleExtensionDto> rules;
  final List<VisualVariantDto> visualVariants;

  /// [target] with this extension merged in. The scene keeps its ID, its
  /// parent and its chapter.
  ///
  /// Throws a [FormatException] when a new hotspot ID is already taken or
  /// a rule names a hotspot the scene does not have.
  SceneDefinition applyTo(SceneDefinition target) {
    try {
      final hotspotsById = {
        for (final hotspot in target.hotspots) hotspot.id: hotspot,
      };
      for (final added in hotspots.map((hotspot) => hotspot.toEntity())) {
        if (hotspotsById.containsKey(added.id)) {
          throw FormatException('hotspot ID "${added.id}" already exists');
        }
        // A map literal keeps insertion order: new hotspots come last.
        hotspotsById[added.id] = added;
      }

      for (final rule in rules) {
        final hotspot = hotspotsById[rule.hotspot];
        if (hotspot == null) {
          throw FormatException(
            'rules: the scene has no hotspot "${rule.hotspot}"',
          );
        }
        hotspotsById[rule.hotspot] = _withRulesInFront(
          hotspot,
          rule.interactions.map((rule) => rule.toEntity()),
        );
      }

      return SceneDefinition(
        id: target.id,
        parentId: target.parentId,
        titleKey: target.titleKey,
        visual: target.visual,
        visualVariants: List.unmodifiable([
          ...visualVariants.map((variant) => variant.toEntity()),
          ...target.visualVariants,
        ]),
        hotspots: List.unmodifiable(hotspotsById.values),
        onFirstEnter: target.onFirstEnter,
      );
    } on FormatException catch (error) {
      throw FormatException('sceneExtensions "$scene": ${error.message}');
    }
  }

  static HotspotDefinition _withRulesInFront(
    HotspotDefinition hotspot,
    Iterable<InteractionRule> rules,
  ) => HotspotDefinition(
    id: hotspot.id,
    rect: hotspot.rect,
    labelKey: hotspot.labelKey,
    visibleWhen: hotspot.visibleWhen,
    glint: hotspot.glint,
    sprite: hotspot.sprite,
    interactions: List.unmodifiable([...rules, ...hotspot.interactions]),
  );
}
