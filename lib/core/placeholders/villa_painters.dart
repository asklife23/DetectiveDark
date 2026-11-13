import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:flutter/rendering.dart';

/// The villa from the garden: facade with the front door in the middle and
/// the garden statue on the right.
class VillaExteriorPainter extends CustomPainter {
  const VillaExteriorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size)..nightSky();

    // Distant tree line.
    for (final (x, height) in const [
      (0.0, 0.26),
      (0.07, 0.34),
      (0.88, 0.30),
      (0.95, 0.38),
    ]) {
      brush.oval(
        brush.rect(x - 0.04, 0.66 - height, 0.16, height + 0.1),
        PlaceholderPalette.roof,
      );
    }

    brush
      // Facade and roof.
      ..fill(brush.rect(0.14, 0.26, 0.52, 0.60), PlaceholderPalette.wall)
      ..polygon([
        brush.point(0.10, 0.27),
        brush.point(0.40, 0.08),
        brush.point(0.70, 0.27),
      ], PlaceholderPalette.roof)
      ..fill(brush.rect(0.56, 0.10, 0.04, 0.12), PlaceholderPalette.roof);

    // Dark windows: nobody is home.
    for (final x in const [0.19, 0.55]) {
      for (final y in const [0.33, 0.56]) {
        brush
          ..fill(brush.rect(x, y, 0.08, 0.16), PlaceholderPalette.windowDark)
          ..outline(
            brush.rect(x, y, 0.08, 0.16),
            PlaceholderPalette.wallLight,
            0.006,
          )
          ..line(
            brush.point(x + 0.04, y),
            brush.point(x + 0.04, y + 0.16),
            PlaceholderPalette.wallLight,
            0.004,
          );
      }
    }

    brush
      // Front door with its frame and steps.
      ..fill(
        brush.rect(0.345, 0.385, 0.17, 0.475),
        PlaceholderPalette.wallLight,
      )
      ..fill(brush.rect(0.36, 0.40, 0.14, 0.44), PlaceholderPalette.wood)
      ..fill(brush.rect(0.375, 0.43, 0.045, 0.17), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.44, 0.43, 0.045, 0.17), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.375, 0.63, 0.11, 0.17), PlaceholderPalette.woodDark)
      ..circle(brush.point(0.485, 0.62), 0.009, PlaceholderPalette.brass)
      ..fill(brush.rect(0.33, 0.84, 0.20, 0.03), PlaceholderPalette.stoneDark)
      // Plate for the house number (the number itself is overlay text).
      ..fillRounded(
        brush.rect(0.512, 0.515, 0.056, 0.08),
        PlaceholderPalette.woodDark,
        0.008,
      )
      // Ground.
      ..gradient(brush.rect(0, 0.86, 1, 0.14), const [
        PlaceholderPalette.ground,
        PlaceholderPalette.black,
      ])
      // Path to the door.
      ..polygon([
        brush.point(0.36, 0.87),
        brush.point(0.50, 0.87),
        brush.point(0.62, 1),
        brush.point(0.22, 1),
      ], PlaceholderPalette.stoneDark.withValues(alpha: 0.45));

    _statue(brush);

    brush
      ..fogBand(0.70, 0.22, 0.20)
      ..fogBand(0.52, 0.18, 0.08);
  }

  void _statue(PlaceholderBrush brush) {
    brush
      ..glow(
        brush.point(0.78, 0.50),
        0.30,
        PlaceholderPalette.moon.withValues(alpha: 0.10),
      )
      ..fill(brush.rect(0.735, 0.74, 0.09, 0.12), PlaceholderPalette.stoneDark)
      ..fill(brush.rect(0.725, 0.72, 0.11, 0.03), PlaceholderPalette.stone)
      ..polygon([
        brush.point(0.745, 0.72),
        brush.point(0.76, 0.50),
        brush.point(0.80, 0.50),
        brush.point(0.815, 0.72),
      ], PlaceholderPalette.stone)
      ..oval(brush.rect(0.752, 0.46, 0.056, 0.10), PlaceholderPalette.stone)
      ..circle(brush.point(0.78, 0.42), 0.035, PlaceholderPalette.stoneLight);
  }

  @override
  bool shouldRepaint(VillaExteriorPainter oldDelegate) => false;
}

/// The front door seen up close, shut or standing open.
class VillaDoorPainter extends CustomPainter {
  const VillaDoorPainter({required this.isOpen});

  final bool isOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush
      // Wall and stone door frame.
      ..gradient(brush.rect(0, 0, 1, 1), const [
        PlaceholderPalette.wall,
        PlaceholderPalette.roof,
      ])
      ..fill(brush.rect(0.29, 0.06, 0.42, 0.90), PlaceholderPalette.stoneDark)
      ..fill(brush.rect(0, 0.92, 1, 0.08), PlaceholderPalette.ground);

    final doorway = brush.rect(0.32, 0.10, 0.36, 0.82);
    if (isOpen) {
      _open(brush, doorway);
    } else {
      _closed(brush, doorway);
    }

    brush.fogBand(0.80, 0.20, 0.14);
  }

  void _closed(PlaceholderBrush brush, Rect doorway) {
    brush
      ..gradient(doorway, const [
        PlaceholderPalette.woodLight,
        PlaceholderPalette.wood,
      ])
      // Panels.
      ..fill(brush.rect(0.355, 0.15, 0.12, 0.30), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.525, 0.15, 0.12, 0.30), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.355, 0.54, 0.12, 0.32), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.525, 0.70, 0.12, 0.16), PlaceholderPalette.woodDark)
      // Lock plate, knob and keyhole.
      ..fillRounded(
        brush.rect(0.605, 0.46, 0.07, 0.17),
        PlaceholderPalette.brassDark,
        0.012,
      )
      ..circle(brush.point(0.64, 0.50), 0.028, PlaceholderPalette.brass)
      ..circle(brush.point(0.636, 0.494), 0.010, PlaceholderPalette.brassLight)
      ..circle(brush.point(0.64, 0.575), 0.011, PlaceholderPalette.black)
      ..fill(brush.rect(0.6365, 0.575, 0.007, 0.03), PlaceholderPalette.black);
  }

  void _open(PlaceholderBrush brush, Rect doorway) {
    brush
      // The dark hall beyond, with lamp light somewhere inside.
      ..fill(doorway, PlaceholderPalette.black)
      ..glow(
        brush.point(0.47, 0.56),
        0.42,
        PlaceholderPalette.lampGlow.withValues(alpha: 0.30),
      )
      ..polygon([
        brush.point(0.32, 0.92),
        brush.point(0.60, 0.92),
        brush.point(0.54, 0.80),
        brush.point(0.38, 0.80),
      ], PlaceholderPalette.lampGlow.withValues(alpha: 0.10))
      // The door leaf, swung inwards to the right.
      ..polygon([
        brush.point(0.68, 0.10),
        brush.point(0.59, 0.16),
        brush.point(0.59, 0.86),
        brush.point(0.68, 0.92),
      ], PlaceholderPalette.wood)
      ..circle(brush.point(0.605, 0.52), 0.012, PlaceholderPalette.brass);
  }

  @override
  bool shouldRepaint(VillaDoorPainter oldDelegate) =>
      oldDelegate.isOpen != isOpen;
}

/// The entrance hall: a desk under a lamp, with or without the letter.
class VillaHallPainter extends CustomPainter {
  const VillaHallPainter({required this.hasLetter});

  final bool hasLetter;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush
      ..gradient(brush.rect(0, 0, 1, 0.70), const [
        PlaceholderPalette.black,
        PlaceholderPalette.interiorWall,
      ])
      ..fill(brush.rect(0, 0.70, 1, 0.30), PlaceholderPalette.interiorFloor)
      // Wainscoting line and a tall dark doorway on the left.
      ..fill(brush.rect(0, 0.685, 1, 0.015), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.08, 0.20, 0.14, 0.50), PlaceholderPalette.black)
      ..outline(
        brush.rect(0.08, 0.20, 0.14, 0.50),
        PlaceholderPalette.wood,
        0.01,
      )
      // A picture frame on the right.
      ..fill(brush.rect(0.76, 0.24, 0.13, 0.22), PlaceholderPalette.woodDark)
      ..outline(
        brush.rect(0.76, 0.24, 0.13, 0.22),
        PlaceholderPalette.brassDark,
        0.008,
      )
      // Lamp light over the desk.
      ..glow(
        brush.point(0.50, 0.40),
        0.62,
        PlaceholderPalette.lampGlow.withValues(alpha: 0.26),
      )
      ..line(
        brush.point(0.50, 0),
        brush.point(0.50, 0.24),
        PlaceholderPalette.woodDark,
        0.006,
      )
      ..polygon([
        brush.point(0.455, 0.31),
        brush.point(0.475, 0.24),
        brush.point(0.525, 0.24),
        brush.point(0.545, 0.31),
      ], PlaceholderPalette.brassDark)
      ..circle(brush.point(0.50, 0.325), 0.018, PlaceholderPalette.brassLight)
      // Desk: top, front and legs.
      ..polygon([
        brush.point(0.30, 0.60),
        brush.point(0.70, 0.60),
        brush.point(0.76, 0.72),
        brush.point(0.24, 0.72),
      ], PlaceholderPalette.woodLight)
      ..fill(brush.rect(0.24, 0.72, 0.52, 0.06), PlaceholderPalette.wood)
      ..fill(brush.rect(0.27, 0.78, 0.035, 0.20), PlaceholderPalette.woodDark)
      ..fill(brush.rect(0.695, 0.78, 0.035, 0.20), PlaceholderPalette.woodDark)
      // An inkwell, so the desk is not empty once the letter is gone.
      ..fillRounded(
        brush.rect(0.62, 0.615, 0.03, 0.045),
        PlaceholderPalette.black,
        0.006,
      );

    if (hasLetter) {
      brush
        ..polygon([
          brush.point(0.452, 0.622),
          brush.point(0.548, 0.616),
          brush.point(0.558, 0.694),
          brush.point(0.444, 0.700),
        ], PlaceholderPalette.paper)
        ..line(
          brush.point(0.465, 0.642),
          brush.point(0.535, 0.638),
          PlaceholderPalette.paperShade,
          0.004,
        )
        ..line(
          brush.point(0.464, 0.660),
          brush.point(0.538, 0.656),
          PlaceholderPalette.paperShade,
          0.004,
        )
        ..line(
          brush.point(0.463, 0.678),
          brush.point(0.515, 0.675),
          PlaceholderPalette.paperShade,
          0.004,
        );
    }
  }

  @override
  bool shouldRepaint(VillaHallPainter oldDelegate) =>
      oldDelegate.hasLetter != hasLetter;
}
