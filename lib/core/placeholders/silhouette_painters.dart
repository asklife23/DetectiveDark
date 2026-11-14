import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:flutter/rendering.dart';

/// The characters of the market square as silhouettes: dark figures with
/// one small detail each, so they can be told apart at a glance.
///
/// The same drawing is the object in the scene and the portrait in the
/// dialogue panel. It fills its box and leaves the rest transparent.
enum SilhouetteKind {
  /// Tall and narrow, in a long coat, with glasses that catch the light.
  pharmacist,

  /// Broad, in an apron, with a cap.
  cafeOwner,
}

class SilhouettePainter extends CustomPainter {
  const SilhouettePainter(this.kind);

  final SilhouetteKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    switch (kind) {
      case SilhouetteKind.pharmacist:
        _pharmacist(brush);
      case SilhouetteKind.cafeOwner:
        _cafeOwner(brush);
    }
  }

  void _pharmacist(PlaceholderBrush brush) {
    const dark = PlaceholderPalette.black;
    brush
      // Long coat, narrow at the shoulders.
      ..polygon([
        brush.point(0.30, 0.25),
        brush.point(0.70, 0.25),
        brush.point(0.80, 1),
        brush.point(0.20, 1),
      ], dark)
      ..fill(brush.rect(0.44, 0.17, 0.12, 0.10), dark)
      ..oval(brush.rect(0.34, 0.02, 0.32, 0.19), dark)
      // The lapels of a white coat, barely lit.
      ..polygon([
        brush.point(0.50, 0.27),
        brush.point(0.44, 0.27),
        brush.point(0.49, 0.50),
      ], PlaceholderPalette.stoneDark)
      ..polygon([
        brush.point(0.50, 0.27),
        brush.point(0.56, 0.27),
        brush.point(0.51, 0.50),
      ], PlaceholderPalette.stoneDark)
      // Round glasses.
      ..oval(
        brush.rect(0.385, 0.085, 0.085, 0.035),
        PlaceholderPalette.lampGlow,
      )
      ..oval(
        brush.rect(0.53, 0.085, 0.085, 0.035),
        PlaceholderPalette.lampGlow,
      );
  }

  void _cafeOwner(PlaceholderBrush brush) {
    const dark = PlaceholderPalette.black;
    brush
      // Broad shoulders, sleeves rolled up.
      ..polygon([
        brush.point(0.16, 0.30),
        brush.point(0.84, 0.30),
        brush.point(0.80, 1),
        brush.point(0.20, 1),
      ], dark)
      ..fill(brush.rect(0.43, 0.21, 0.14, 0.11), dark)
      ..oval(brush.rect(0.33, 0.06, 0.34, 0.19), dark)
      // A flat cap.
      ..fill(brush.rect(0.31, 0.055, 0.42, 0.045), dark)
      // The apron, a shade lighter than the figure.
      ..polygon([
        brush.point(0.34, 0.46),
        brush.point(0.66, 0.46),
        brush.point(0.70, 0.96),
        brush.point(0.30, 0.96),
      ], PlaceholderPalette.stoneDark)
      ..line(
        brush.point(0.34, 0.46),
        brush.point(0.44, 0.31),
        PlaceholderPalette.stoneDark,
        0.012,
      )
      ..line(
        brush.point(0.66, 0.46),
        brush.point(0.56, 0.31),
        PlaceholderPalette.stoneDark,
        0.012,
      );
  }

  @override
  bool shouldRepaint(SilhouettePainter oldDelegate) => oldDelegate.kind != kind;
}
