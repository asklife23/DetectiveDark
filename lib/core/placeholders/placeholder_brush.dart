import 'package:flutter/painting.dart';

/// Colors of the placeholder drawings. They are temporary art, so they do
/// not belong to the app theme.
abstract final class PlaceholderPalette {
  static const skyTop = Color(0xFF05070D);
  static const skyBottom = Color(0xFF16233A);
  static const moon = Color(0xFFD9DEE8);
  static const fog = Color(0xFF8FA0BC);
  static const ground = Color(0xFF0B0F17);
  static const wall = Color(0xFF1A2130);
  static const wallLight = Color(0xFF262F42);
  static const roof = Color(0xFF0D111A);
  static const windowDark = Color(0xFF0A0D14);
  static const wood = Color(0xFF2B2018);
  static const woodLight = Color(0xFF3B2C20);
  static const woodDark = Color(0xFF17100B);
  static const brass = Color(0xFFB8935A);
  static const brassDark = Color(0xFF6E5530);
  static const brassLight = Color(0xFFE2C48A);
  static const stone = Color(0xFF6C7689);
  static const stoneLight = Color(0xFF9AA4B6);
  static const stoneDark = Color(0xFF3A4252);
  static const lampGlow = Color(0xFFE0A85A);
  static const interiorWall = Color(0xFF241C17);
  static const interiorFloor = Color(0xFF120E0B);
  static const paper = Color(0xFFD8CFB8);
  static const paperShade = Color(0xFF9E957F);
  static const glass = Color(0xFF5C3B22);
  static const black = Color(0xFF000000);
}

/// Drawing helpers that work in fractions of the canvas (0–1), the same
/// coordinate system the hotspots use. A door drawn at `x: 0.36` sits
/// exactly under a hotspot whose rect starts at `x: 0.36`, on every screen.
class PlaceholderBrush {
  PlaceholderBrush(this.canvas, this.size);

  final Canvas canvas;
  final Size size;

  double get _w => size.width;
  double get _h => size.height;

  /// A rectangle from fractions of the canvas.
  Rect rect(double x, double y, double width, double height) =>
      Rect.fromLTWH(x * _w, y * _h, width * _w, height * _h);

  /// A point from fractions of the canvas.
  Offset point(double x, double y) => Offset(x * _w, y * _h);

  /// A length as a fraction of the canvas height (keeps circles round).
  double unit(double fraction) => fraction * _h;

  void fill(Rect area, Color color) =>
      canvas.drawRect(area, Paint()..color = color);

  void fillRounded(Rect area, Color color, double radiusFraction) =>
      canvas.drawRRect(
        RRect.fromRectAndRadius(area, Radius.circular(unit(radiusFraction))),
        Paint()..color = color,
      );

  /// A top-to-bottom gradient.
  void gradient(Rect area, List<Color> colors) => canvas.drawRect(
    area,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(area),
  );

  void circle(Offset center, double radiusFraction, Color color) =>
      canvas.drawCircle(center, unit(radiusFraction), Paint()..color = color);

  void oval(Rect area, Color color) =>
      canvas.drawOval(area, Paint()..color = color);

  /// Soft light that fades out towards [radiusFraction].
  void glow(Offset center, double radiusFraction, Color color) {
    final radius = unit(radiusFraction);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void line(Offset from, Offset to, Color color, double widthFraction) =>
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = color
          ..strokeWidth = unit(widthFraction)
          ..strokeCap = StrokeCap.round,
      );

  void outline(Rect area, Color color, double widthFraction) => canvas.drawRect(
    area,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit(widthFraction),
  );

  /// A closed shape through [points] (fractions of the canvas).
  void polygon(List<Offset> points, Color color) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  /// A horizontal band of fog, densest in its middle.
  void fogBand(double y, double height, double opacity) {
    final area = rect(0, y, 1, height);
    const fog = PlaceholderPalette.fog;
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fog.withValues(alpha: 0),
            fog.withValues(alpha: opacity),
            fog.withValues(alpha: 0),
          ],
        ).createShader(area),
    );
  }

  /// A night sky with a moon and its halo.
  void nightSky({double moonX = 0.84, double moonY = 0.16}) {
    gradient(rect(0, 0, 1, 1), const [
      PlaceholderPalette.skyTop,
      PlaceholderPalette.skyBottom,
    ]);
    final moon = point(moonX, moonY);
    glow(moon, 0.32, PlaceholderPalette.moon.withValues(alpha: 0.22));
    circle(moon, 0.05, PlaceholderPalette.moon);
  }
}
