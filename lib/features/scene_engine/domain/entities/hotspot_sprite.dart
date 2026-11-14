import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:equatable/equatable.dart';

/// The picture of an object that belongs to a hotspot: the key hooked
/// behind the ear of the statue, the letter on the desk (ADR 0012).
///
/// It is drawn on top of the scene background while its hotspot is visible
/// and disappears with it, so a scene needs one background instead of one
/// per combination of collected objects.
class HotspotSprite extends Equatable {
  const HotspotSprite({
    required this.rect,
    required this.placeholderStyle,
    this.image,
    this.overlays = const [],
  });

  /// Where the object is drawn, relative to the scene image. Independent of
  /// the tap area of the hotspot, which is usually a little larger.
  final NormalizedRect rect;

  /// Name of the placeholder drawing, used while [image] is null.
  final String placeholderStyle;

  /// Real artwork with a transparent background (asset path).
  final String? image;

  /// Text that belongs to the object (the word on a signpost, ADR 0017).
  /// The rectangles are relative to the **scene image**, like the overlays
  /// of the scene itself. They are drawn in the overlay layer, above the
  /// objects and under the noir filter, and they appear and disappear
  /// together with the object.
  final List<VisualOverlay> overlays;

  @override
  List<Object?> get props => [rect, placeholderStyle, image, overlays];
}
