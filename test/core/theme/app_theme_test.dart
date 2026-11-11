import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme.dark', () {
    final theme = AppTheme.dark();

    test('is dark and built from the color tokens', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.accent);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.warning);
    });

    test('uses the typewriter font for titles and the body font for text', () {
      final text = theme.textTheme;
      expect(text.headlineMedium?.fontFamily, AppFonts.title);
      expect(text.titleLarge?.fontFamily, AppFonts.title);
      expect(text.bodyLarge?.fontFamily, AppFonts.body);
      expect(text.labelLarge?.fontFamily, AppFonts.body);
    });

    test('colors all text with the primary text color', () {
      expect(theme.textTheme.bodyLarge?.color, AppColors.textPrimary);
      expect(theme.textTheme.headlineMedium?.color, AppColors.textPrimary);
    });
  });

  test('scene transitions default to 150 ms fades without a hold', () {
    expect(AppDurations.sceneFadeOut, const Duration(milliseconds: 150));
    expect(AppDurations.sceneHold, Duration.zero);
    expect(AppDurations.sceneFadeIn, const Duration(milliseconds: 150));
  });
}
