import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_typography.dart';
import 'package:flutter/painting.dart';

/// Named styles for text the game draws on top of images (ADR 0011):
/// clock times, house numbers, the words on a plaque.
///
/// Content picks a style by name; the look is defined here, so every piece
/// of overlay text in the game stays consistent. The font size is not part
/// of a style: overlay text is scaled to fit its rectangle.
abstract final class OverlayTextStyles {
  /// Typed text on paper: letters, files, labels.
  static const typewriter = 'typewriter';

  /// Letters cut into stone or metal: plaques, tombstones.
  static const engraved = 'engraved';

  /// Raised brass letters and digits: house numbers, door plates.
  static const brass = 'brass';

  static const _engravedLetterSpacing = 1.5;

  static const Map<String, TextStyle> _styles = {
    typewriter: TextStyle(
      fontFamily: AppFonts.title,
      color: AppColors.ink,
    ),
    engraved: TextStyle(
      fontFamily: AppFonts.title,
      fontWeight: FontWeight.w700,
      color: AppColors.engraving,
      letterSpacing: _engravedLetterSpacing,
    ),
    brass: TextStyle(
      fontFamily: AppFonts.title,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    ),
  };

  /// Every style name content may use.
  static Set<String> get names => _styles.keys.toSet();

  /// The style called [name]; an unknown name falls back to [typewriter]
  /// (the content validation test reports it).
  ///
  /// Overlay text is part of the picture, so it never inherits interface
  /// styling such as underlines.
  static TextStyle resolve(String name) =>
      (_styles[name] ?? _styles[typewriter]!).copyWith(
        inherit: false,
        decoration: TextDecoration.none,
      );
}
