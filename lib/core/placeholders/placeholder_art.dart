import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/core/placeholders/statue_painters.dart';
import 'package:detective_dark/core/placeholders/villa_painters.dart';
import 'package:flutter/widgets.dart';

/// Draws the placeholder picture called [style] (see [PlaceholderStyles]).
///
/// Scenes, inspections and inventory icons all use this one widget, so no
/// feature needs to import drawing code from another feature. Grain and
/// vignette are not drawn here: the shared noir filter adds them.
class PlaceholderArt extends StatelessWidget {
  const PlaceholderArt({required this.style, super.key});

  final String style;

  /// The painter registered for [style]. An unknown name gets a plain dark
  /// picture; the content validation test reports unknown names.
  static CustomPainter painterFor(String style) => switch (style) {
    PlaceholderStyles.villaExterior => const VillaExteriorPainter(),
    PlaceholderStyles.villaDoorClosed => const VillaDoorPainter(isOpen: false),
    PlaceholderStyles.villaDoorOpen => const VillaDoorPainter(isOpen: true),
    PlaceholderStyles.statueCloseup => const StatueCloseupPainter(),
    PlaceholderStyles.villaHall => const VillaHallPainter(),
    PlaceholderStyles.statuePlaque => const StatuePlaquePainter(),
    PlaceholderStyles.itemBrassKey => const BrassKeyPainter(),
    PlaceholderStyles.spriteBrassKey => const BrassKeySpritePainter(),
    PlaceholderStyles.spriteLetter => const LetterSpritePainter(),
    _ => const UnknownPlaceholderPainter(),
  };

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: painterFor(style), size: Size.infinite);
  }
}

/// Fallback for a style name that has no drawing.
class UnknownPlaceholderPainter extends CustomPainter {
  const UnknownPlaceholderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final brush = PlaceholderBrush(canvas, size);
    brush.gradient(brush.rect(0, 0, 1, 1), const [
      PlaceholderPalette.skyTop,
      PlaceholderPalette.skyBottom,
    ]);
  }

  @override
  bool shouldRepaint(UnknownPlaceholderPainter oldDelegate) => false;
}
