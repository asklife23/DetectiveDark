import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/theme/dialogue_layout.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_line.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_topic_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The conversation with a character: the portrait on the left, and on the
/// right either the line the character is saying or the list of questions.
///
/// The widget fills the box its parent gives it (the `app/` layer puts it
/// above the scene, leaving the item panel and the detective message bar
/// free). It is opaque, so the scene underneath cannot be tapped.
///
/// While the character speaks, a tap anywhere on the panel advances.
class DialoguePanel extends StatelessWidget {
  const DialoguePanel({required this.onClose, this.headerActions, super.key});

  /// The close button was pressed.
  final VoidCallback onClose;

  /// Extra controls in the header, left of the close button (the `app/`
  /// layer adds "Show evidence" here).
  final Widget? headerActions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DialogueCubit, DialogueState>(
      builder: (context, state) {
        final dialogue = state.dialogue;
        if (dialogue == null) return const SizedBox.shrink();
        final cubit = context.read<DialogueCubit>();

        return GestureDetector(
          // Opaque also while the player chooses: taps never reach the
          // scene under the panel.
          behavior: HitTestBehavior.opaque,
          onTap: state.isSpeaking ? cubit.advance : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.md),
              ),
              border: Border.all(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DialogueLayout.padding),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width:
                          (constraints.maxWidth *
                                  DialogueLayout.portraitWidthFactor)
                              .clamp(
                                DialogueLayout.minPortraitWidth,
                                DialogueLayout.maxPortraitWidth,
                              ),
                      child: _Portrait(portrait: dialogue.portrait),
                    ),
                    const SizedBox(width: DialogueLayout.padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(
                            nameKey: dialogue.nameKey,
                            onClose: onClose,
                            // Evidence is shown between two answers, not
                            // in the middle of one.
                            actions: state.isSpeaking ? null : headerActions,
                          ),
                          const SizedBox(height: DialogueLayout.gap),
                          Expanded(
                            child: state.isSpeaking
                                ? DialogueLine(
                                    // A new line starts typing again.
                                    key: ValueKey(
                                      '${state.currentLineKey}'
                                      '#${state.lineIndex}',
                                    ),
                                    textKey: state.currentLineKey!,
                                    isComplete: state.isLineComplete,
                                    isLast: state.isLastLine,
                                    onTyped: cubit.lineTyped,
                                  )
                                : DialogueTopicList(
                                    topics: state.topics,
                                    onAsk: cubit.ask,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The name of the character and the buttons of the panel.
class _Header extends StatelessWidget {
  const _Header({
    required this.nameKey,
    required this.onClose,
    required this.actions,
  });

  final String nameKey;
  final VoidCallback onClose;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DialogueLayout.headerHeight,
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.storyTexts.text(nameKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
            ),
          ),
          ?actions,
          HudIconButton(
            icon: Icons.close,
            tooltip: context.l10n.closeTooltip,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// The picture of the character: real artwork when the content names it,
/// otherwise the placeholder silhouette, standing in the light of a lamp.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.portrait});

  final DialoguePortrait portrait;

  @override
  Widget build(BuildContext context) {
    final placeholder = PlaceholderArt(style: portrait.placeholderStyle);
    final image = portrait.image;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sm)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 0.9,
            colors: [AppColors.nightBlue, AppColors.background],
          ),
        ),
        child: image == null
            ? placeholder
            : Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
