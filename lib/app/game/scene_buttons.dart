import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The buttons that sit on the scene: Back and the developer tools.
class SceneButtons extends StatelessWidget {
  const SceneButtons({
    required this.showDebugTools,
    required this.showHotspots,
    required this.onToggleHotspots,
    this.onOpenDevMenu,
    super.key,
  });

  final bool showDebugTools;
  final bool showHotspots;
  final VoidCallback onToggleHotspots;

  /// Opens the developer menu. Null when the build has no menu: then the
  /// button is not drawn. It does not depend on [showDebugTools].
  final VoidCallback? onOpenDevMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      right: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: BlocSelector<SceneBloc, SceneState, bool>(
                selector: (state) => state.canGoBack,
                builder: (context, canGoBack) => canGoBack
                    ? HudIconButton(
                        icon: Icons.arrow_back,
                        tooltip: l10n.backTooltip,
                        onPressed: () =>
                            context.read<SceneBloc>().add(const BackPressed()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Align(
              // Bottom left belongs to the message bar, top center to the
              // flavor badge.
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [
                  if (onOpenDevMenu case final onOpenDevMenu?)
                    HudIconButton(
                      icon: Icons.build,
                      tooltip: l10n.devMenuTooltip,
                      onPressed: onOpenDevMenu,
                    ),
                  if (showDebugTools)
                    HudIconButton(
                      icon: showHotspots ? Icons.grid_off : Icons.grid_on,
                      tooltip: l10n.debugHotspotsTooltip,
                      onPressed: onToggleHotspots,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
