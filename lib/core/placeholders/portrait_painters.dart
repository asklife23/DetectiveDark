import 'dart:math' as math;

import 'package:detective_dark/core/placeholders/placeholder_brush.dart';
import 'package:detective_dark/core/placeholders/silhouette_painters.dart';
import 'package:flutter/rendering.dart';

/// The portrait of a character in the dialogue panel: head and shoulders,
/// still a silhouette, with the same details as the figure in the scene
/// (`SilhouettePainter`), only closer.
///
/// The bust is designed for a box a little taller than wide. In a box of
/// another shape it is scaled to cover the box and cut off at the sides,
/// like a photograph in a frame; it always stands on the bottom edge.
class PortraitPainter extends CustomPainter {
  const PortraitPainter(this.kind);

  final SilhouetteKind kind;

  /// Height of the design divided by its width.
  static const _designRatio = 1.4;

  static const Color _dark = PlaceholderPalette.black;
  static const Color _detail = PlaceholderPalette.stoneDark;
  static final Color _rimLight = PlaceholderPalette.lampGlow.withValues(
    alpha: 0.45,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final width = math.max(size.width, size.height / _designRatio);
    final area = Rect.fromLTWH(
      (size.width - width) / 2,
      size.height - width * _designRatio,
      width,
      width * _designRatio,
    );

    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    final bust = _Bust(canvas, area);
    switch (kind) {
      case SilhouetteKind.pharmacist:
        _pharmacist(bust);
      case SilhouetteKind.cafeOwner:
        _cafeOwner(bust);
    }
    canvas.restore();
  }

  void _pharmacist(_Bust bust) {
    final head = bust.rect(0.33, 0.17, 0.34, 0.36);
    // Narrow, sloping shoulders in a coat.
    final coat = FractionPath(bust.area)
      ..move(0.40, 0.60)
      ..curve(0.12, 0.64, 0.04, 0.80)
      ..line(0, 1)
      ..line(1, 1)
      ..line(0.96, 0.80)
      ..curve(0.88, 0.64, 0.60, 0.60)
      ..close();
    final tie = FractionPath(bust.area)
      ..move(0.482, 0.635)
      ..line(0.518, 0.635)
      ..line(0.53, 0.775)
      ..line(0.50, 0.805)
      ..line(0.47, 0.775)
      ..close();

    bust
      ..fillPath(coat, _dark)
      ..fillRect(bust.rect(0.43, 0.48, 0.14, 0.15), _dark)
      // Ears, then the long head over them.
      ..fillOval(bust.rect(0.305, 0.31, 0.05, 0.075), _dark)
      ..fillOval(bust.rect(0.645, 0.31, 0.05, 0.075), _dark)
      ..fillOval(head, _dark)
      // Shirt and tie, and the edges of the lapels.
      ..fillPolygon(const [(0.41, 0.615), (0.59, 0.615), (0.50, 0.81)], _detail)
      ..fillPath(tie, _dark)
      ..stroke((0.40, 0.61), (0.475, 0.90), _detail, 0.008)
      ..stroke((0.60, 0.61), (0.525, 0.90), _detail, 0.008)
      // Round glasses that catch the lamp light.
      ..stroke(
        (0.45, 0.325),
        (0.55, 0.325),
        PlaceholderPalette.brassDark,
        0.008,
      )
      ..lens(0.415, 0.33)
      ..lens(0.585, 0.33)
      // The light comes from his right.
      ..arc(head, -math.pi * 0.28, math.pi * 0.56, _rimLight, 0.008)
      ..strokePath(
        FractionPath(bust.area)
          ..move(0.62, 0.605)
          ..curve(0.88, 0.64, 0.955, 0.795),
        _rimLight,
        0.008,
      );
  }

  void _cafeOwner(_Bust bust) {
    final head = bust.rect(0.29, 0.20, 0.42, 0.36);
    // Broad, square shoulders.
    final body = FractionPath(bust.area)
      ..move(0.36, 0.62)
      ..curve(0.06, 0.64, 0, 0.78)
      ..line(0, 1)
      ..line(1, 1)
      ..line(1, 0.78)
      ..curve(0.94, 0.64, 0.64, 0.62)
      ..close();
    final cap = FractionPath(bust.area)
      ..move(0.265, 0.285)
      ..curve(0.27, 0.125, 0.50, 0.125)
      ..curve(0.73, 0.125, 0.735, 0.285)
      ..close();
    final towel = FractionPath(bust.area)
      ..move(0.13, 0.685)
      ..line(0.235, 0.655)
      ..line(0.265, 0.93)
      ..line(0.165, 0.95)
      ..close();

    bust
      ..fillPath(body, _dark)
      ..fillRect(bust.rect(0.38, 0.50, 0.24, 0.14), _dark)
      ..fillOval(head, _dark)
      ..fillPath(cap, _dark)
      // The brim of the cap, pulled to one side, and its band.
      ..fillRounded(bust.rect(0.17, 0.265, 0.58, 0.035), _dark, 0.012)
      ..stroke((0.285, 0.258), (0.715, 0.258), _detail, 0.007)
      // A heavy moustache.
      ..fillOval(bust.rect(0.395, 0.435, 0.21, 0.04), _detail)
      // The bib of the apron and its straps.
      ..fillPolygon(const [
        (0.36, 0.80),
        (0.64, 0.80),
        (0.66, 1),
        (0.34, 1),
      ], _detail)
      ..stroke((0.36, 0.80), (0.42, 0.635), _detail, 0.012)
      ..stroke((0.64, 0.80), (0.58, 0.635), _detail, 0.012)
      // A towel over the shoulder.
      ..fillPath(towel, PlaceholderPalette.paperShade.withValues(alpha: 0.5))
      // The light comes from his left.
      ..arc(head, math.pi * 0.80, math.pi * 0.40, _rimLight, 0.008)
      ..strokePath(
        FractionPath(bust.area)
          ..move(0.34, 0.625)
          ..curve(0.07, 0.645, 0.012, 0.775),
        _rimLight,
        0.008,
      );
  }

  @override
  bool shouldRepaint(PortraitPainter oldDelegate) => oldDelegate.kind != kind;
}

/// Drawing helpers for a bust: every number is a fraction of [area]; line
/// widths and radii are fractions of its width.
class _Bust {
  _Bust(this.canvas, this.area);

  final Canvas canvas;
  final Rect area;

  static const _lensRadius = 0.055;

  Offset _at((double, double) point) => Offset(
    area.left + point.$1 * area.width,
    area.top + point.$2 * area.height,
  );

  Rect rect(double x, double y, double width, double height) =>
      _at((x, y)) & Size(width * area.width, height * area.height);

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width * area.width;

  void fillRect(Rect rect, Color color) =>
      canvas.drawRect(rect, Paint()..color = color);

  void fillOval(Rect rect, Color color) =>
      canvas.drawOval(rect, Paint()..color = color);

  void fillRounded(Rect rect, Color color, double radius) => canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius * area.width)),
    Paint()..color = color,
  );

  void fillPath(FractionPath shape, Color color) =>
      canvas.drawPath(shape.path, Paint()..color = color);

  void fillPolygon(List<(double, double)> points, Color color) =>
      canvas.drawPath(
        Path()..addPolygon([for (final point in points) _at(point)], true),
        Paint()..color = color,
      );

  void stroke(
    (double, double) from,
    (double, double) to,
    Color color,
    double width,
  ) => canvas.drawLine(_at(from), _at(to), _stroke(color, width));

  void strokePath(FractionPath shape, Color color, double width) =>
      canvas.drawPath(shape.path, _stroke(color, width));

  void arc(Rect oval, double start, double sweep, Color color, double width) =>
      canvas.drawArc(oval, start, sweep, false, _stroke(color, width));

  /// One lens of a pair of glasses: dim glass, a brass rim and a bright
  /// reflection in its upper half.
  void lens(double x, double y) {
    final center = _at((x, y));
    final radius = _lensRadius * area.width;
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()..color = PlaceholderPalette.lampGlow.withValues(alpha: 0.30),
      )
      ..drawCircle(
        center.translate(-radius * 0.15, -radius * 0.25),
        radius * 0.55,
        Paint()..color = PlaceholderPalette.lampGlow.withValues(alpha: 0.85),
      )
      ..drawCircle(
        center,
        radius,
        _stroke(PlaceholderPalette.brassDark, 0.008),
      );
  }
}
