import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:flutter/rendering.dart';

/// Draws a brass key whose bow (ring) is centered on [center]; the shaft
/// points down. [scale] is the height of the key as a fraction of the
/// canvas height.
void paintBrassKey(PlaceholderBrush brush, Offset center, double scale) {
  final unit = brush.unit(scale);
  final ringRadius = unit * 0.22;
  final shaftTop = center.translate(0, ringRadius * 0.8);
  final shaftBottom = center.translate(0, unit * 0.78);
  final paint = Paint()
    ..color = PlaceholderPalette.brass
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = unit * 0.085;

  brush.canvas
    ..drawCircle(center, ringRadius, paint)
    ..drawLine(shaftTop, shaftBottom, paint)
    // Two teeth.
    ..drawLine(
      shaftBottom,
      shaftBottom.translate(unit * 0.16, 0),
      paint,
    )
    ..drawLine(
      shaftBottom.translate(0, -unit * 0.16),
      shaftBottom.translate(unit * 0.12, -unit * 0.16),
      paint,
    )
    // A highlight on the ring.
    ..drawArc(
      Rect.fromCircle(center: center, radius: ringRadius),
      3.6,
      1,
      false,
      Paint()
        ..color = PlaceholderPalette.brassLight
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = unit * 0.04,
    );
}

/// The garden statue up close: a marble bust on a pedestal with a plaque.
/// The key behind its ear is a separate object ([BrassKeySpritePainter]).
class StatueCloseupPainter extends CustomPainter {
  const StatueCloseupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size)
      ..nightSky(moonX: 0.16, moonY: 0.18);

    // Hedge silhouettes behind the statue.
    brush
      ..oval(brush.rect(-0.08, 0.50, 0.40, 0.50), PlaceholderPalette.roof)
      ..oval(brush.rect(0.70, 0.44, 0.44, 0.60), PlaceholderPalette.roof)
      ..fill(brush.rect(0, 0.90, 1, 0.10), PlaceholderPalette.ground)
      ..glow(
        brush.point(0.50, 0.36),
        0.60,
        PlaceholderPalette.moon.withValues(alpha: 0.10),
      )
      // Pedestal with its cornice.
      ..fill(brush.rect(0.37, 0.72, 0.26, 0.24), PlaceholderPalette.stoneDark)
      ..fill(brush.rect(0.35, 0.69, 0.30, 0.04), PlaceholderPalette.stone)
      // Brass plaque (its words are overlay text in the inspection).
      ..fillRounded(
        brush.rect(0.405, 0.775, 0.19, 0.10),
        PlaceholderPalette.brassDark,
        0.008,
      )
      ..line(
        brush.point(0.43, 0.81),
        brush.point(0.57, 0.81),
        PlaceholderPalette.brass,
        0.006,
      )
      ..line(
        brush.point(0.45, 0.84),
        brush.point(0.55, 0.84),
        PlaceholderPalette.brass,
        0.006,
      )
      // Shoulders, neck and head.
      ..polygon([
        brush.point(0.37, 0.69),
        brush.point(0.39, 0.56),
        brush.point(0.46, 0.50),
        brush.point(0.54, 0.50),
        brush.point(0.61, 0.56),
        brush.point(0.63, 0.69),
      ], PlaceholderPalette.stone)
      ..fill(brush.rect(0.475, 0.43, 0.05, 0.09), PlaceholderPalette.stone)
      ..oval(brush.rect(0.435, 0.14, 0.13, 0.32), PlaceholderPalette.stoneLight)
      // Hair, brow shadow and the ear the key hangs on.
      ..oval(brush.rect(0.43, 0.12, 0.14, 0.16), PlaceholderPalette.stone)
      ..oval(
        brush.rect(0.455, 0.27, 0.035, 0.022),
        PlaceholderPalette.stoneDark,
      )
      ..oval(brush.rect(0.51, 0.27, 0.035, 0.022), PlaceholderPalette.stoneDark)
      ..line(
        brush.point(0.488, 0.385),
        brush.point(0.512, 0.385),
        PlaceholderPalette.stoneDark,
        0.006,
      )
      ..oval(brush.rect(0.558, 0.25, 0.022, 0.07), PlaceholderPalette.stone)
      ..fogBand(0.78, 0.22, 0.16);
  }

  @override
  bool shouldRepaint(StatueCloseupPainter oldDelegate) => false;
}

/// The brass plaque of the statue, filling the picture. The inscription is
/// overlay text drawn by the game.
class StatuePlaquePainter extends CustomPainter {
  const StatuePlaquePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush
      ..gradient(brush.rect(0, 0, 1, 1), const [
        PlaceholderPalette.stone,
        PlaceholderPalette.stoneDark,
      ])
      ..fillRounded(
        brush.rect(0.08, 0.16, 0.84, 0.68),
        PlaceholderPalette.brassDark,
        0.03,
      )
      ..fillRounded(
        brush.rect(0.10, 0.19, 0.80, 0.62),
        PlaceholderPalette.brass,
        0.02,
      )
      ..outline(
        brush.rect(0.125, 0.235, 0.75, 0.53),
        PlaceholderPalette.brassDark,
        0.008,
      );

    // A screw in each corner.
    for (final x in const [0.145, 0.855]) {
      for (final y in const [0.27, 0.73]) {
        brush
          ..circle(brush.point(x, y), 0.018, PlaceholderPalette.brassDark)
          ..circle(brush.point(x, y), 0.008, PlaceholderPalette.brassLight);
      }
    }
  }

  @override
  bool shouldRepaint(StatuePlaquePainter oldDelegate) => false;
}

/// The brass key on its own: inventory icon and examine card.
class BrassKeyPainter extends CustomPainter {
  const BrassKeyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush.glow(
      brush.point(0.5, 0.5),
      0.55,
      PlaceholderPalette.lampGlow.withValues(alpha: 0.16),
    );
    paintBrassKey(brush, brush.point(0.5, 0.26), 0.62);
  }

  @override
  bool shouldRepaint(BrassKeyPainter oldDelegate) => false;
}

/// The brass key as an object in a scene: it fills its box and leaves the
/// rest transparent, so the scene shows through.
class BrassKeySpritePainter extends CustomPainter {
  const BrassKeySpritePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    paintBrassKey(brush, brush.point(0.457, 0.233), 0.933);
  }

  @override
  bool shouldRepaint(BrassKeySpritePainter oldDelegate) => false;
}
