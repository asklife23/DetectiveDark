import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:equatable/equatable.dart';

/// Something the game draws on top of an image, under the noir filter
/// (ADR 0011). `sealed`, so new kinds (e.g. analog clock hands) are added
/// deliberately when a puzzle needs them.
sealed class VisualOverlay extends Equatable {
  const VisualOverlay({required this.rect});

  /// Where it is drawn, relative to the image.
  final NormalizedRect rect;
}

/// Readable or puzzle-critical text, never baked into the image: a clock
/// time, a house number, the words on a plaque.
final class TextOverlay extends VisualOverlay {
  const TextOverlay({
    required super.rect,
    required this.textKey,
    required this.style,
    this.rotation = 0,
  });

  final String textKey;

  /// Name of a text style preset defined in code (typewriter, engraved...).
  final String style;

  /// Clockwise rotation in degrees.
  final double rotation;

  @override
  List<Object?> get props => [rect, textKey, style, rotation];
}

/// What is drawn for a scene, a visual variant or an inspection.
class SceneVisual extends Equatable {
  const SceneVisual({
    required this.placeholderStyle,
    this.background,
    this.overlays = const [],
    this.filterPreset,
  });

  /// Real artwork (asset path). While null, the placeholder is drawn.
  final String? background;

  /// Name of the placeholder drawing.
  final String placeholderStyle;

  final List<VisualOverlay> overlays;

  /// Name of a noir filter preset. Null means the default preset.
  final String? filterPreset;

  @override
  List<Object?> get props => [
    background,
    placeholderStyle,
    overlays,
    filterPreset,
  ];
}

/// A different look for a scene while [when] holds (the door stands open).
class VisualVariant extends Equatable {
  const VisualVariant({required this.when, required this.visual});

  final Condition when;
  final SceneVisual visual;

  @override
  List<Object?> get props => [when, visual];
}
