import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Builds the game's single, dark noir theme from the tokens.
abstract final class AppTheme {
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.nightBlue,
      onSecondary: AppColors.textPrimary,
      error: AppColors.warning,
      onError: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: AppColors.surfaceRaised,
      outline: AppColors.outline,
      scrim: AppColors.scrim,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
