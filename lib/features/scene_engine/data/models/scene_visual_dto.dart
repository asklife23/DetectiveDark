import 'package:detective_dark/features/scene_engine/data/models/condition_codec.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:json_annotation/json_annotation.dart';

part 'scene_visual_dto.g.dart';

/// JSON form of a [NormalizedRect].
@JsonSerializable()
class RectDto {
  const RectDto({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory RectDto.fromJson(Map<String, dynamic> json) =>
      _$RectDtoFromJson(json);

  final double x;
  final double y;
  final double width;
  final double height;

  NormalizedRect toEntity() =>
      NormalizedRect(x: x, y: y, width: width, height: height);
}

/// JSON form of a [VisualOverlay]. `type` names the kind; only `text`
/// exists so far.
@JsonSerializable()
class OverlayDto {
  const OverlayDto({
    required this.rect,
    required this.textKey,
    required this.style,
    this.type = 'text',
    this.rotation = 0,
  });

  factory OverlayDto.fromJson(Map<String, dynamic> json) =>
      _$OverlayDtoFromJson(json);

  static const textType = 'text';

  final String type;
  final RectDto rect;
  final String textKey;
  final String style;
  final double rotation;

  VisualOverlay toEntity() {
    if (type != textType) {
      throw FormatException(
        'Unknown overlay type "$type". Known: $textType.',
      );
    }
    return TextOverlay(
      rect: rect.toEntity(),
      textKey: textKey,
      style: style,
      rotation: rotation,
    );
  }
}

/// JSON form of a [SceneVisual].
@JsonSerializable()
class SceneVisualDto {
  const SceneVisualDto({
    required this.placeholderStyle,
    this.background,
    this.overlays = const [],
    this.filterPreset,
  });

  factory SceneVisualDto.fromJson(Map<String, dynamic> json) =>
      _$SceneVisualDtoFromJson(json);

  final String? background;
  final String placeholderStyle;
  final List<OverlayDto> overlays;
  final String? filterPreset;

  SceneVisual toEntity() => SceneVisual(
    background: background,
    placeholderStyle: placeholderStyle,
    overlays: List.unmodifiable(overlays.map((overlay) => overlay.toEntity())),
    filterPreset: filterPreset,
  );
}

/// JSON form of a [VisualVariant].
@JsonSerializable()
class VisualVariantDto {
  const VisualVariantDto({required this.when, required this.visual});

  factory VisualVariantDto.fromJson(Map<String, dynamic> json) =>
      _$VisualVariantDtoFromJson(json);

  final Map<String, dynamic> when;
  final SceneVisualDto visual;

  VisualVariant toEntity() => VisualVariant(
    when: ConditionCodec.parse(when),
    visual: visual.toEntity(),
  );
}
