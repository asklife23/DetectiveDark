import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Everything the detective has said so far, newest at the bottom.
///
/// Like the notebook it lies above the scene and is not a route, so the
/// game underneath stays exactly as it was. A tap outside or the close
/// button closes it.
class ChatHistorySheet extends StatelessWidget {
  const ChatHistorySheet({super.key});

  /// The panel never grows wider than a comfortable line of text.
  static const _maxWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: cubit.closeHistory,
          child: const ColoredBox(color: AppColors.scrim),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: GestureDetector(
                  // Taps on the panel must not reach the scrim.
                  onTap: () {},
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadii.md),
                      ),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.xs,
                            top: AppSpacing.xs,
                            bottom: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.chatTooltip,
                                  style: titleStyle?.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              HudIconButton(
                                icon: Icons.close,
                                tooltip: context.l10n.closeTooltip,
                                onPressed: cubit.closeHistory,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.outline),
                        Expanded(
                          child:
                              BlocSelector<
                                ChatCubit,
                                ChatState,
                                List<ChatLogEntry>
                              >(
                                selector: (state) => state.messages,
                                builder: (context, messages) =>
                                    _MessageList(messages: messages),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  /// Oldest first.
  final List<ChatLogEntry> messages;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            context.l10n.chatHistoryEmpty,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final texts = context.storyTexts;
    final newestFirst = messages.reversed.toList();
    return ListView.separated(
      // A reversed list starts at its end: the newest message is visible
      // without scrolling, older ones are above it.
      reverse: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: newestFirst.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = newestFirst[index];
        final isSystem = entry.sender == ChatSender.system;
        return Text(
          texts.text(entry.textKey, params: entry.params),
          style: textTheme.bodyMedium?.copyWith(
            color: isSystem ? AppColors.textSecondary : AppColors.textPrimary,
            fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
          ),
        );
      },
    );
  }
}
