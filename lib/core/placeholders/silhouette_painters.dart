import 'dart:math' as math;

import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:flutter/rendering.dart';

/// The characters of the market square.
enum SilhouetteKind {
  /// Tall and narrow, in a long coat, with glasses that catch the light.
  pharmacist,

  /// Broad, in an apron, with a flat cap.
  cafeOwner,
}

/// A character standing in a scene: a dark figure with one or two details,
/// so the two can be told apart at a glance. A thin edge of lamp light on
/// one side lifts the figure off the dark wall behind it.
///
/// The figure fills its box and leaves the rest transparent. The portrait
/// in the dialogue panel is a different drawing (`PortraitPainter`).
class SilhouettePainter extends CustomPainter {
  const SilhouettePainter(this.kind);

  final SilhouetteKind kind;

  static const Color _dark = PlaceholderPalette.black;
  static const Color _detail = PlaceholderPalette.stoneDark;
  static final Color _rimLight = PlaceholderPalette.lampGlow.withValues(
    alpha: 0.42,
  );
  static const _rimWidth = 0.006;

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
    final area = brush.rect(0, 0, 1, 1);
    final head = brush.rect(0.36, 0.015, 0.28, 0.115);
    // A long coat: sloping shoulders, arms at the sides, hem at the knee.
    final coat = FractionPath(area)
      ..move(0.45, 0.16)
      ..curve(0.24, 0.165, 0.20, 0.225)
      ..line(0.15, 0.56)
      ..line(0.21, 0.575)
      ..line(0.20, 0.80)
      ..line(0.80, 0.80)
      ..line(0.79, 0.575)
      ..line(0.85, 0.56)
      ..line(0.80, 0.225)
      ..curve(0.76, 0.165, 0.55, 0.16)
      ..close();

    _legs(brush, left: 0.30, right: 0.53, width: 0.17, top: 0.79);
    brush.canvas.drawPath(coat.path, Paint()..color = _dark);
    brush
      ..fill(brush.rect(0.45, 0.12, 0.10, 0.05), _dark)
      ..oval(head, _dark)
      // Shirt and tie in the opening of the coat, barely lit.
      ..polygon([
        brush.point(0.44, 0.165),
        brush.point(0.56, 0.165),
        brush.point(0.50, 0.30),
      ], _detail)
      ..line(brush.point(0.50, 0.185), brush.point(0.50, 0.285), _dark, 0.008)
      ..line(
        brush.point(0.50, 0.31),
        brush.point(0.50, 0.79),
        _detail.withValues(alpha: 0.55),
        0.004,
      )
      // Round glasses: two small lenses and the bridge between them.
      ..line(
        brush.point(0.44, 0.068),
        brush.point(0.56, 0.068),
        PlaceholderPalette.brassDark,
        0.003,
      )
      ..circle(brush.point(0.425, 0.068), 0.0125, PlaceholderPalette.lampGlow)
      ..circle(brush.point(0.575, 0.068), 0.0125, PlaceholderPalette.lampGlow)
      // The street lamp stands to his right.
      ..line(
        brush.point(0.81, 0.24),
        brush.point(0.845, 0.55),
        _rimLight,
        0.006,
      )
      ..line(
        brush.point(0.795, 0.585),
        brush.point(0.80, 0.79),
        _rimLight,
        0.006,
      );
    _rimOnHead(brush, head, litFromRight: true);
  }

  void _cafeOwner(PlaceholderBrush brush) {
    final area = brush.rect(0, 0, 1, 1);
    final head = brush.rect(0.33, 0.07, 0.34, 0.125);
    // Broad shoulders and thick arms.
    final body = FractionPath(area)
      ..move(0.42, 0.205)
      ..curve(0.12, 0.21, 0.08, 0.29)
      ..line(0.05, 0.58)
      ..line(0.14, 0.60)
      ..line(0.17, 0.82)
      ..line(0.83, 0.82)
      ..line(0.86, 0.60)
      ..line(0.95, 0.58)
      ..line(0.92, 0.29)
      ..curve(0.88, 0.21, 0.58, 0.205)
      ..close();
    final cap = FractionPath(area)
      ..move(0.30, 0.10)
      ..curve(0.31, 0.045, 0.50, 0.045)
      ..curve(0.70, 0.045, 0.71, 0.10)
      ..close();

    _legs(brush, left: 0.25, right: 0.54, width: 0.21, top: 0.81);
    brush.canvas.drawPath(body.path, Paint()..color = _dark);
    brush
      ..fill(brush.rect(0.42, 0.18, 0.16, 0.04), _dark)
      ..oval(head, _dark);
    brush.canvas.drawPath(cap.path, Paint()..color = _dark);
    brush
      // The brim of the cap, pulled to one side.
      ..fillRounded(brush.rect(0.20, 0.09, 0.52, 0.017), _dark, 0.004)
      // The apron, a shade lighter than the figure, with its straps and
      // the cord around the waist.
      ..polygon([
        brush.point(0.36, 0.34),
        brush.point(0.64, 0.34),
        brush.point(0.72, 0.88),
        brush.point(0.28, 0.88),
      ], _detail)
      ..line(brush.point(0.36, 0.34), brush.point(0.44, 0.215), _detail, 0.007)
      ..line(brush.point(0.64, 0.34), brush.point(0.56, 0.215), _detail, 0.007)
      ..line(
        brush.point(0.31, 0.52),
        brush.point(0.69, 0.52),
        PlaceholderPalette.wall,
        0.007,
      )
      // The street lamp stands to his left.
      ..line(
        brush.point(0.085, 0.30),
        brush.point(0.058, 0.57),
        _rimLight,
        0.006,
      )
      ..line(
        brush.point(0.145, 0.61),
        brush.point(0.172, 0.81),
        _rimLight,
        0.006,
      );
    _rimOnHead(brush, head, litFromRight: false);
  }

  /// Two legs and the shoes under them.
  void _legs(
    PlaceholderBrush brush, {
    required double left,
    required double right,
    required double width,
    required double top,
  }) {
    const shoeTop = 0.965;
    const shoeOverhang = 0.05;
    for (final x in [left, right]) {
      brush
        ..fill(brush.rect(x, top, width, shoeTop - top + 0.01), _dark)
        ..fillRounded(
          brush.rect(
            x - shoeOverhang,
            shoeTop,
            width + shoeOverhang * 1.4,
            1 - shoeTop,
          ),
          _dark,
          0.008,
        );
    }
  }

  /// The edge of light on the side of the head that faces the lamp.
  void _rimOnHead(
    PlaceholderBrush brush,
    Rect head, {
    required bool litFromRight,
  }) {
    const sweep = math.pi * 0.55;
    final start = litFromRight ? -sweep / 2 : math.pi - sweep / 2;
    brush.canvas.drawArc(
      head,
      start,
      sweep,
      false,
      Paint()
        ..color = _rimLight
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = brush.unit(_rimWidth),
    );
  }

  @override
  bool shouldRepaint(SilhouettePainter oldDelegate) => oldDelegate.kind != kind;
}
