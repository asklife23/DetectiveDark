/// Fixed proportions of the scene area, as fractions of the scene image.
abstract final class SceneLayout {
  /// Height of the strip along the bottom edge of the scene that belongs to
  /// the detective message bar, as a fraction of the scene height.
  ///
  /// The bar (and the small button it shrinks to) is laid out inside this
  /// strip and nowhere else, and the content validation test rejects every
  /// hotspot that reaches into it. Together the two rules guarantee that
  /// the bar can never cover something the player has to tap.
  static const double chatStripHeight = 0.13;
}
