import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/noir_filter.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/overlay_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/sprite_layer.dart';
import 'package:flutter/widgets.dart';

/// Draws one [SceneVisual]: the picture, the objects lying in it, the
/// overlay text and the noir filter above them all.
///
/// Scenes and the inspection panel share this widget, so they always go
/// through the same pipeline: background → objects → overlays → filter
/// (only scenes have objects). The
/// [RepaintBoundary] keeps this static picture apart from the animated
/// layers above it (hotspot glimmer, transitions).
class SceneVisualView extends StatelessWidget {
  const SceneVisualView({
    required this.visual,
    this.sprites = const [],
    super.key,
  });

  final SceneVisual visual;

  /// The objects of the visible hotspots (ADR 0012).
  final List<HotspotSprite> sprites;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Background(visual: visual),
          SpriteLayer(sprites: sprites),
          // The text of an object (the word on a signpost) is drawn with
          // the text of the scene: above every object, under the filter.
          OverlayLayer(
            overlays: [
              ...visual.overlays,
              for (final sprite in sprites) ...sprite.overlays,
            ],
          ),
          NoirFilter(preset: NoirFilterPresets.resolve(visual.filterPreset)),
        ],
      ),
    );
  }
}

/// The real artwork when the content names one, otherwise the placeholder
/// drawing. Switching to real art is a one-line change in the JSON.
class _Background extends StatelessWidget {
  const _Background({required this.visual});

  final SceneVisual visual;

  @override
  Widget build(BuildContext context) {
    final placeholder = PlaceholderArt(style: visual.placeholderStyle);
    final background = visual.background;
    if (background == null) return placeholder;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Decode the image at the size it is shown, not at full size: a
        // 4K picture on a phone would waste memory.
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final width = constraints.maxWidth * pixelRatio;
        return Image.asset(
          background,
          fit: BoxFit.cover,
          cacheWidth: width.isFinite && width > 0 ? width.round() : null,
          errorBuilder: (_, _, _) => placeholder,
        );
      },
    );
  }
}
