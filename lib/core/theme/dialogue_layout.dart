/// Measures of the dialogue panel, in logical pixels.
///
/// The panel must show **four questions without scrolling** on the smallest
/// supported phone: 360 px high, in landscape. There the scene image is
/// about 320 px high and the panel gets what is left above the detective
/// message bar, roughly 278 px. The numbers below are chosen to fit that:
///
/// ```text
/// padding + header + gap + 4 rows + 3 gaps + padding
///    8    +   44   +  4  +  4×44  +  3×4   +    8     = 252
/// ```
abstract final class DialogueLayout {
  /// Space between the edge of the panel and its content.
  static const double padding = 8;

  /// The row with the name of the character and the panel buttons.
  static const double headerHeight = 44;

  /// One question. Not smaller than a comfortable touch target.
  static const double topicRowHeight = 44;

  /// Space between two questions and between header and list.
  static const double gap = 4;

  /// How many questions must be visible without scrolling.
  static const int topicsWithoutScrolling = 4;

  /// The height the question list needs for [topicsWithoutScrolling] rows.
  static const double topicListHeight =
      topicsWithoutScrolling * topicRowHeight +
      (topicsWithoutScrolling - 1) * gap;

  /// The smallest panel height that still shows four questions.
  static const double minPanelHeight =
      2 * padding + headerHeight + gap + topicListHeight;

  /// Width of the portrait as a share of the panel width.
  static const double portraitWidthFactor = 0.22;

  /// Width of the portrait is kept between these, on any screen.
  static const double minPortraitWidth = 84;
  static const double maxPortraitWidth = 200;

  /// The line of the character: font size as a share of the panel height,
  /// within readable limits.
  static const double lineFontSizeFactor = 0.062;
  static const double minLineFontSize = 14;
  static const double maxLineFontSize = 22;
}
