import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A small round counter on the corner of a HUD button: unread notes,
/// unread messages. Taps go through to the button underneath.
class HudBadge extends StatelessWidget {
  const HudBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppSizes.badge,
          minHeight: AppSizes.badge,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.badge)),
        ),
        child: Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.onAccent),
        ),
      ),
    );
  }
}
