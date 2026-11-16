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

    _cobbles(brush);
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
    const jars = [(0.318, 0.07), (0.343, 0.05), (0.372, 0.08)];
    for (final (x, height) in jars) {
      brush.fill(
        brush.rect(x, 0.68 - height, 0.014, height),
        PlaceholderPalette.woodDark,
      );
    }
    brush
      // The bar across the window and the sill under it.
      ..fill(
        brush.rect(0.305, 0.535, 0.10, 0.006),
        PlaceholderPalette.wallLight,
      )
      ..fill(
        brush.rect(0.298, 0.68, 0.114, 0.014),
        PlaceholderPalette.wallLight,
      );
    _doorDetails(
      brush,
      brush.rect(0.19, 0.44, 0.085, 0.40),
      handleOnRight: true,
    );
  }

  /// Two panels and a brass handle on a shop door.
  void _doorDetails(
    PlaceholderBrush brush,
    Rect door, {
    required bool handleOnRight,
  }) {
    final inset = door.width * 0.16;
    final panelHeight = (door.height - inset * 3) / 2;
    for (final top in [door.top + inset, door.top + inset * 2 + panelHeight]) {
      brush.outline(
        Rect.fromLTWH(
          door.left + inset,
          top,
          door.width - inset * 2,
          panelHeight,
        ),
        PlaceholderPalette.wood,
        0.004,
      );
    }
    brush.canvas.drawCircle(
      Offset(
        handleOnRight ? door.right - inset * 0.55 : door.left + inset * 0.55,
        door.center.dy,
      ),
      brush.unit(0.007),
      Paint()..color = PlaceholderPalette.brass,
    );
  }

  /// The pool of lamp light on the ground and a few rows of cobbles.
  void _cobbles(PlaceholderBrush brush) {
    final pool = brush.rect(0.30, 0.845, 0.40, 0.11);
    // A round glow, squashed flat so it lies on the ground.
    brush.canvas
      ..save()
      ..translate(pool.center.dx, pool.center.dy)
      ..scale(1, pool.height / pool.width);
    final circle = Rect.fromCircle(center: Offset.zero, radius: pool.width / 2);
    brush.canvas
      ..drawOval(
        circle,
        Paint()
          ..shader = RadialGradient(
            colors: [
              PlaceholderPalette.lampGlow.withValues(alpha: 0.16),
              PlaceholderPalette.lampGlow.withValues(alpha: 0),
            ],
          ).createShader(circle),
      )
      ..restore();
    final stone = PlaceholderPalette.stone.withValues(alpha: 0.16);
    const rows = [(0.875, 0.045, 0.0), (0.915, 0.058, 0.5), (0.96, 0.074, 0.0)];
    for (final (y, step, shift) in rows) {
      for (var x = step * shift; x < 1; x += step) {
        brush.line(
          brush.point(x + step * 0.18, y),
          brush.point(x + step * 0.82, y),
          stone,
          0.004,
        );
      }
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
      // The stripes of the awning.
      ..polygon([
        brush.point(0.65, 0.40),
        brush.point(0.72, 0.40),
        brush.point(0.725, 0.46),
        brush.point(0.64, 0.46),
      ], PlaceholderPalette.wood)
      ..polygon([
        brush.point(0.79, 0.40),
        brush.point(0.86, 0.40),
        brush.point(0.89, 0.46),
        brush.point(0.81, 0.46),
      ], PlaceholderPalette.wood)
      // The cross of the window frame and the sill.
      ..fill(
        brush.rect(0.6525, 0.48, 0.005, 0.22),
        PlaceholderPalette.wallLight,
      )
      ..fill(
        brush.rect(0.60, 0.585, 0.11, 0.006),
        PlaceholderPalette.wallLight,
      )
      ..fill(
        brush.rect(0.593, 0.70, 0.124, 0.014),
        PlaceholderPalette.wallLight,
      )
      // A small round table under it, and a chair.
      ..oval(brush.rect(0.60, 0.765, 0.065, 0.02), PlaceholderPalette.stone)
      ..line(
        brush.point(0.6325, 0.775),
        brush.point(0.6325, 0.85),
        PlaceholderPalette.stoneDark,
        0.006,
      )
      ..line(
        brush.point(0.585, 0.73),
        brush.point(0.585, 0.855),
        PlaceholderPalette.woodDark,
        0.006,
      )
      ..line(
        brush.point(0.565, 0.80),
        brush.point(0.585, 0.80),
        PlaceholderPalette.woodDark,
        0.008,
      )
      ..line(
        brush.point(0.565, 0.80),
        brush.point(0.565, 0.855),
        PlaceholderPalette.woodDark,
        0.006,
      );
    _doorDetails(
      brush,
      brush.rect(0.75, 0.46, 0.085, 0.38),
      handleOnRight: false,
    );
  }

  void _roadSign(PlaceholderBrush brush) {
    brush
      ..line(
        brush.point(0.07, 0.56),
        brush.point(0.07, 0.87),
        PlaceholderPalette.wood,
        0.016,
      )
      ..line(
        brush.point(0.0735, 0.60),
        brush.point(0.0735, 0.86),
        PlaceholderPalette.woodLight,
        0.004,
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
      ..fill(brush.rect(0.43, 0.20, 0.14, 0.80), PlaceholderPalette.wood)
      ..fill(brush.rect(0.535, 0.27, 0.035, 0.73), PlaceholderPalette.woodLight)
      // Arrow board pointing left, away from the villa.
      ..polygon([
        brush.point(0, 0.15),
        brush.point(0.14, 0.04),
        brush.point(0.98, 0.04),
        brush.point(0.98, 0.26),
        brush.point(0.14, 0.26),
      ], PlaceholderPalette.paperShade)
      // The two nails that hold the board.
      ..circle(brush.point(0.50, 0.075), 0.006, PlaceholderPalette.woodDark)
      ..circle(brush.point(0.50, 0.225), 0.006, PlaceholderPalette.woodDark);
  }

  @override
  bool shouldRepaint(MarketSignSpritePainter oldDelegate) => false;
}

/// Draws a small medicine bottle inside [area]: brown glass, a brass cap
/// and what is left of a torn label.
void paintPillBottle(PlaceholderBrush brush, Rect area) {
  Rect part(double x, double y, double width, double height) => Rect.fromLTWH(
    area.left + x * area.width,
    area.top + y * area.height,
    width * area.width,
    height * area.height,
  );
  Offset point(double x, double y) =>
      Offset(area.left + x * area.width, area.top + y * area.height);
  const radius = 0.012;

  brush
    ..fillRounded(
      part(0.12, 0.26, 0.76, 0.74),
      PlaceholderPalette.glass,
      radius,
    )
    // The neck and the cap on it.
    ..fill(part(0.32, 0.18, 0.36, 0.10), PlaceholderPalette.glass)
    ..fillRounded(
      part(0.24, 0.03, 0.52, 0.17),
      PlaceholderPalette.brass,
      radius,
    )
    ..fill(part(0.24, 0.145, 0.52, 0.025), PlaceholderPalette.brassDark)
    // The label: its right part is torn off along a ragged edge.
    ..polygon([
      point(0.12, 0.46),
      point(0.70, 0.46),
      point(0.60, 0.55),
      point(0.72, 0.63),
      point(0.58, 0.71),
      point(0.66, 0.80),
      point(0.12, 0.80),
    ], PlaceholderPalette.paper)
    ..fill(part(0.20, 0.55, 0.32, 0.04), PlaceholderPalette.paperShade)
    ..fill(part(0.20, 0.66, 0.26, 0.04), PlaceholderPalette.paperShade)
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
