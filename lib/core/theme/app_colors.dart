import 'package:flutter/painting.dart';

/// Noir color tokens. Widgets use these (or the theme built from them),
/// never raw color literals.
abstract final class AppColors {
  /// Near-black base behind everything.
  static const background = Color(0xFF0A0B0D);

  /// Panels and cards (inventory, notebook).
  static const surface = Color(0xFF141519);

  /// Elements above a surface (selected slot, dialog).
  static const surfaceRaised = Color(0xFF1E2026);

  /// Hairlines and borders.
  static const outline = Color(0xFF2E313A);

  /// Main text: warm, paper-like off-white.
  static const textPrimary = Color(0xFFE6DFD0);

  /// Secondary text and hints.
  static const textSecondary = Color(0xFF9C9588);

  /// Faded amber/sepia accent: highlights, selection, the detective's voice.
  static const accent = Color(0xFFC8A46A);

  /// Text and icons on [accent].
  static const onAccent = Color(0xFF1A1408);

  /// Night blue for secondary accents.
  static const nightBlue = Color(0xFF22304A);

  /// Faded red for warnings and wrong answers.
  static const warning = Color(0xFFB5524A);

  /// Semi-transparent [warning] behind the debug flavor badge.
  static const debugBadge = Color(0x99B5524A);

  /// Full black used by scene fade transitions.
  static const fade = Color(0xFF000000);

  /// Semi-transparent black behind overlays (examine card, notebook).
  static const scrim = Color(0xCC000000);
}
