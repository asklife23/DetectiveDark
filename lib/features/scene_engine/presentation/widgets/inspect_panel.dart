import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_visual_view.dart';
import 'package:flutter/material.dart';

/// The inspection panel (ADR 0010): a picture and a short text above the
/// scene, for details that only need a look.
///
/// The scene stays where it is. A tap outside the panel or on the close
/// button calls [onClose]; Back is handled by the bloc.
class InspectPanel extends StatelessWidget {
  const InspectPanel({
    required this.inspection,
    required this.onClose,
    super.key,
  });

  final InspectionDefinition inspection;
  final VoidCallback onClose;

  /// Size of the panel relative to the scene.
  static const _widthFactor = 0.84;
  static const _heightFactor = 0.72;

  /// Share of the panel width used by the picture; the text gets the rest.
  static const _imageFlex = 3;
  static const _textFlex = 2;

  @override
  Widget build(BuildContext context) {
    final texts = context.storyTexts;
    final textTheme = Theme.of(context).textTheme;
    final title = inspection.titleKey;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.inspectPanelFade,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scrim: darkens the scene and closes the panel when tapped.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: const ColoredBox(color: AppColors.scrim),
          ),
          FractionallySizedBox(
            widthFactor: _widthFactor,
            heightFactor: _heightFactor,
            child: GestureDetector(
              // Taps on the panel itself must not reach the scrim.
              onTap: () {},
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.md),
                  ),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: _imageFlex,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: SceneViewport.aspectRatio,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(AppRadii.sm),
                              ),
                              child: SceneVisualView(visual: inspection.visual),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: _textFlex,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xs,
                            right: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null) ...[
                                Text(
                                  texts.text(title),
                                  style: textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              Text(
                                texts.text(inspection.textKey),
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: HudIconButton(
                icon: Icons.close,
                tooltip: context.l10n.closeTooltip,
                onPressed: onClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
