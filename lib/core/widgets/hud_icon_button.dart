import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A round, half-transparent button that sits on top of the scene: Back,
/// close, notebook. [tooltip] is also its accessibility label.
class HudIconButton extends StatelessWidget {
  const HudIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: AppSizes.hudIcon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.hudSurface,
        foregroundColor: AppColors.textPrimary,
        fixedSize: const Size.square(AppSizes.hudButton),
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.outline),
        ),
      ),
    );
  }
}
