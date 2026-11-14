import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:flutter/rendering.dart';

/// The market square at night: the pharmacy on the left, the café on the
/// right, a street lamp between them and, on the far left, the road back
/// to the villa with its signpost.
///
/// The words on the three signs are overlay text drawn by the game. The
/// people standing in the square are separate objects (silhouette sprites).
class MarketSquarePainter extends CustomPainter {
  const MarketSquarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size)
      ..nightSky(moonX: 0.50, moonY: 0.11);

    // Roofs of the town behind the square.
    for (final (x, width, top) in const [
      (0.00, 0.16, 0.34),
      (0.44, 0.12, 0.30),
      (0.88, 0.12, 0.36),
    ]) {
      brush.fill(brush.rect(x, top, width, 0.56), PlaceholderPalette.roof);
    }

    _pharmacy(brush);
    _cafe(brush);

    brush
      // Cobbled ground.
      ..gradient(brush.rect(0, 0.84, 1, 0.16), const [
        PlaceholderPalette.ground,
        PlaceholderPalette.black,
      ])
      // The road that leaves the square on the left.
      ..polygon([
        brush.point(0, 0.86),
        brush.point(0.16, 0.86),
        brush.point(0.06, 1),
        brush.point(0, 1),
      ], PlaceholderPalette.stoneDark.withValues(alpha: 0.45));

    _roadSign(brush);
    _streetLamp(brush);

    brush
      ..fogBand(0.70, 0.24, 0.18)
      ..fogBand(0.48, 0.18, 0.07);
  }

  void _pharmacy(PlaceholderBrush brush) {
    brush
      ..fill(brush.rect(0.15, 0.22, 0.29, 0.62), PlaceholderPalette.wall)
      ..polygon([
        brush.point(0.13, 0.23),
        brush.point(0.295, 0.10),
        brush.point(0.46, 0.23),
      ], PlaceholderPalette.roof)
      // Board for the shop name.
      ..fillRounded(
        brush.rect(0.185, 0.30, 0.22, 0.075),
        PlaceholderPalette.paperShade,
        0.006,
      )
      // Door (dark) and the lit shop window next to it.
      ..fill(brush.rect(0.19, 0.44, 0.085, 0.40), PlaceholderPalette.woodDark)
      ..outline(
        brush.rect(0.19, 0.44, 0.085, 0.40),
        PlaceholderPalette.wallLight,
        0.006,
      )
      ..glow(
        brush.point(0.355, 0.56),
        0.34,
        PlaceholderPalette.lampGlow.withValues(alpha: 0.22),
      )
      ..fill(
        brush.rect(0.305, 0.44, 0.10, 0.24),
        PlaceholderPalette.lampGlow.withValues(alpha: 0.55),
      )
      ..outline(
        brush.rect(0.305, 0.44, 0.10, 0.24),
        PlaceholderPalette.wallLight,
        0.006,
      );
    // Jars on the window shelf.
    for (final x in const [0.32, 0.345, 0.37]) {
      brush.fill(brush.rect(x, 0.60, 0.014, 0.07), PlaceholderPalette.woodDark);
    }
  }

  void _cafe(PlaceholderBrush brush) {
    brush
      ..fill(brush.rect(0.57, 0.26, 0.30, 0.58), PlaceholderPalette.wall)
      ..fill(brush.rect(0.55, 0.24, 0.34, 0.03), PlaceholderPalette.roof)
      // Board for the name, above the awning.
      ..fillRounded(
        brush.rect(0.63, 0.295, 0.18, 0.075),
        PlaceholderPalette.paperShade,
        0.006,
      )
      // Lit window and the door.
      ..glow(
        brush.point(0.655, 0.58),
        0.34,
        PlaceholderPalette.lampGlow.withValues(alpha: 0.20),
      )
      ..fill(
        brush.rect(0.60, 0.48, 0.11, 0.22),
        PlaceholderPalette.lampGlow.withValues(alpha: 0.50),
      )
      ..outline(
        brush.rect(0.60, 0.48, 0.11, 0.22),
        PlaceholderPalette.wallLight,
        0.006,
      )
      ..fill(brush.rect(0.75, 0.46, 0.085, 0.38), PlaceholderPalette.woodDark)
      // Awning.
      ..polygon([
        brush.point(0.58, 0.40),
        brush.point(0.86, 0.40),
        brush.point(0.89, 0.46),
        brush.point(0.55, 0.46),
      ], PlaceholderPalette.woodLight)
      // A small round table under it.
      ..oval(brush.rect(0.605, 0.76, 0.07, 0.022), PlaceholderPalette.stone)
      ..line(
        brush.point(0.64, 0.77),
        brush.point(0.64, 0.85),
        PlaceholderPalette.stoneDark,
        0.006,
      );
  }

  void _roadSign(PlaceholderBrush brush) {
    brush
      ..line(
        brush.point(0.07, 0.56),
        brush.point(0.07, 0.87),
        PlaceholderPalette.woodDark,
        0.012,
      )
      // Arrow board pointing out of the square.
      ..polygon([
        brush.point(0.012, 0.555),
        brush.point(0.03, 0.52),
        brush.point(0.12, 0.52),
        brush.point(0.12, 0.59),
        brush.point(0.03, 0.59),
      ], PlaceholderPalette.paperShade);
  }

  void _streetLamp(PlaceholderBrush brush) {
    brush
      ..line(
        brush.point(0.50, 0.36),
        brush.point(0.50, 0.87),
        PlaceholderPalette.roof,
        0.012,
      )
      ..glow(
        brush.point(0.50, 0.34),
        0.30,
        PlaceholderPalette.lampGlow.withValues(alpha: 0.30),
      )
      ..fillRounded(
        brush.rect(0.487, 0.30, 0.026, 0.07),
        PlaceholderPalette.lampGlow,
        0.008,
      )
      ..fill(brush.rect(0.482, 0.29, 0.036, 0.012), PlaceholderPalette.roof);
  }

  @override
  bool shouldRepaint(MarketSquarePainter oldDelegate) => false;
}

/// A wooden signpost as an object in a scene: a post with a board at its
/// top. It fills its box and leaves the rest transparent; the word on the
/// board is overlay text that belongs to the sprite.
class MarketSignSpritePainter extends CustomPainter {
  const MarketSignSpritePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush
      ..fill(brush.rect(0.44, 0.20, 0.12, 0.80), PlaceholderPalette.woodDark)
      // Arrow board pointing left, away from the villa.
      ..polygon([
        brush.point(0, 0.15),
        brush.point(0.14, 0.04),
        brush.point(0.98, 0.04),
        brush.point(0.98, 0.26),
        brush.point(0.14, 0.26),
      ], PlaceholderPalette.paperShade);
  }

  @override
  bool shouldRepaint(MarketSignSpritePainter oldDelegate) => false;
}

/// Draws a small medicine bottle inside [area]: brown glass, a pale label
/// and a cap.
void paintPillBottle(PlaceholderBrush brush, Rect area) {
  Rect part(double x, double y, double width, double height) => Rect.fromLTWH(
    area.left + x * area.width,
    area.top + y * area.height,
    width * area.width,
    height * area.height,
  );
  const radius = 0.012;

  brush
    ..fillRounded(
      part(0.12, 0.26, 0.76, 0.74),
      PlaceholderPalette.glass,
      radius,
    )
    ..fillRounded(
      part(0.26, 0.04, 0.48, 0.24),
      PlaceholderPalette.paper,
      radius,
    )
    ..fill(part(0.12, 0.48, 0.76, 0.30), PlaceholderPalette.paper)
    ..fill(part(0.24, 0.57, 0.52, 0.045), PlaceholderPalette.paperShade)
    ..fill(part(0.24, 0.67, 0.36, 0.045), PlaceholderPalette.paperShade)
    // A streak of light on the glass.
    ..fill(
      part(0.20, 0.30, 0.07, 0.16),
      PlaceholderPalette.brassLight.withValues(alpha: 0.45),
    );
}

/// The pill bottle as an object in a scene: it fills its box.
class PillBottleSpritePainter extends CustomPainter {
  const PillBottleSpritePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    paintPillBottle(brush, brush.rect(0, 0, 1, 1));
  }

  @override
  bool shouldRepaint(PillBottleSpritePainter oldDelegate) => false;
}

/// The pill bottle on its own: inventory icon and examine card.
class PillBottlePainter extends CustomPainter {
  const PillBottlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush.glow(
      brush.point(0.5, 0.5),
      0.55,
      PlaceholderPalette.lampGlow.withValues(alpha: 0.16),
    );
    // A bottle is about half as wide as it is tall, on any canvas shape.
    final height = size.height * 0.68;
    paintPillBottle(
      brush,
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: height * 0.5,
        height: height,
      ),
    );
  }

  @override
  bool shouldRepaint(PillBottlePainter oldDelegate) => false;
}
