import 'dart:math' as math;

import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/theme/overlay_text_styles.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:flutter/widgets.dart';

/// Draws the overlays of a visual: text and numbers that are not part of
/// the image (ADR 0011), placed with the same normalized coordinates as the
/// image itself.
class OverlayLayer extends StatelessWidget {
  const OverlayLayer({required this.overlays, super.key});

  final List<VisualOverlay> overlays;

  /// The text is laid out at this size and then scaled to fit its
  /// rectangle, so the size never has to be written in content.
  static const _layoutFontSize = 48.0;

  static const double _degreesToRadians = math.pi / 180;

  @override
  Widget build(BuildContext context) {
    if (overlays.isEmpty) return const SizedBox.expand();
    final texts = context.storyTexts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          children: [
            for (final overlay in overlays)
              Positioned(
                left: overlay.rect.x * size.width,
                top: overlay.rect.y * size.height,
                width: overlay.rect.width * size.width,
                height: overlay.rect.height * size.height,
                child: switch (overlay) {
                  TextOverlay(:final textKey, :final style, :final rotation) =>
                    Transform.rotate(
                      angle: rotation * _degreesToRadians,
                      child: FittedBox(
                        child: Text(
                          texts.text(textKey),
                          maxLines: 1,
                          style: OverlayTextStyles.resolve(
                            style,
                          ).copyWith(fontSize: _layoutFontSize),
                        ),
                      ),
                    ),
                },
              ),
          ],
        );
      },
    );
  }
}
