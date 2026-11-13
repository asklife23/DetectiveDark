import 'package:equatable/equatable.dart';

/// A rectangle in normalized coordinates: every value is a fraction (0–1) of
/// the scene image, not of the screen. `x: 0.5` is the horizontal middle of
/// the image on every device.
class NormalizedRect extends Equatable {
  const NormalizedRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;

  double get bottom => y + height;

  double get centerX => x + width / 2;

  double get centerY => y + height / 2;

  /// Whether the rectangle has a size and lies completely inside the image.
  bool get isValid =>
      x >= 0 &&
      y >= 0 &&
      width > 0 &&
      height > 0 &&
      right <= 1 + _tolerance &&
      bottom <= 1 + _tolerance;

  /// Absorbs floating point noise such as `0.7 + 0.3 = 1.0000000000000002`.
  static const _tolerance = 1e-9;

  /// Whether the normalized point ([px], [py]) is inside the rectangle.
  bool contains(double px, double py) =>
      px >= x && px <= right && py >= y && py <= bottom;

  @override
  List<Object?> get props => [x, y, width, height];
}
