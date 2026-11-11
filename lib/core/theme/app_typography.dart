import 'package:flutter/material.dart';

/// Font family names, as declared in pubspec.yaml.
abstract final class AppFonts {
  /// Typewriter face for titles, case files and documents (Courier Prime).
  static const title = 'CourierPrime';

  /// Readable face for body text, messages and UI labels (IBM Plex Sans).
  static const body = 'IBMPlexSans';
}

/// The text styles of the game. Colors come from the theme, not from here.
///
/// Sizes target a landscape phone (~360 logical pixels tall) and still read
/// well on a desktop window.
abstract final class AppTypography {
  static const _bodyLineHeight = 1.45;
  static const _titleLetterSpacing = 0.5;
  static const _labelLetterSpacing = 0.2;

  static const textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontFamily: AppFonts.title,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: _titleLetterSpacing,
    ),
    headlineSmall: TextStyle(
      fontFamily: AppFonts.title,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: _titleLetterSpacing,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.title,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(fontFamily: AppFonts.title, fontSize: 16),
    titleSmall: TextStyle(fontFamily: AppFonts.title, fontSize: 14),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      height: _bodyLineHeight,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      height: _bodyLineHeight,
    ),
    bodySmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      height: _bodyLineHeight,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: _labelLetterSpacing,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: _labelLetterSpacing,
    ),
    labelSmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: _labelLetterSpacing,
    ),
  );
}
