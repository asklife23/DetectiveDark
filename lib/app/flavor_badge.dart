import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A small label at the top center showing the flavor (e.g. "DEV"), so a
/// dev build is never mistaken for the real game.
///
/// It ignores pointer events: taps go straight through to the scene below.
/// Top center is the one HUD area that stays free (back button top left,
/// inventory panel on the right, message bar at the bottom).
///
/// The flavor name is a developer label, not game text, so it is not
/// localized.
class FlavorBadge extends StatelessWidget {
  const FlavorBadge({required this.flavor, super.key});

  final Flavor flavor;

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
                  flavor.name.toUpperCase(),
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
