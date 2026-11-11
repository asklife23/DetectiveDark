import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A small label at the top center showing the build (e.g. "DEV" or
/// "PROD · STEAM"), so a test build is never mistaken for the real game.
///
/// It ignores pointer events: taps go straight through to the scene below.
/// Top center is the one HUD area that stays free (back button top left,
/// inventory panel on the right, message bar at the bottom).
///
/// [label] is a developer label (`AppConfig.debugLabel`), not game text, so
/// it is not localized.
class FlavorBadge extends StatelessWidget {
  const FlavorBadge({required this.label, super.key});

  final String label;

  static const _alpha = 0.6;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: _alpha),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.sm),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  label.toUpperCase(),
                  style: style?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
