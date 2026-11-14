import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/theme/dialogue_layout.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:flutter/material.dart';

/// The questions the player can ask, one row each.
///
/// A question that was never asked carries a "new" label, an asked one a
/// check mark. Four rows fit without scrolling on the smallest supported
/// phone ([DialogueLayout]); more than that scroll.
class DialogueTopicList extends StatelessWidget {
  const DialogueTopicList({
    required this.topics,
    required this.onAsk,
    super.key,
  });

  final List<TopicView> topics;

  /// Called with the ID of the tapped question.
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return Center(
        child: Text(
          context.l10n.dialogueNoTopics,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: topics.length,
      separatorBuilder: (_, _) => const SizedBox(height: DialogueLayout.gap),
      itemBuilder: (context, index) {
        final view = topics[index];
        return _TopicRow(view: view, onTap: () => onAsk(view.topic.id));
      },
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.view, required this.onTap});

  final TopicView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final prompt = context.storyTexts.text(view.topic.promptKey);

    return Semantics(
      button: true,
      label: prompt,
      value: view.isNew ? l10n.dialogueTopicNew : l10n.dialogueTopicAsked,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surfaceRaised,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
            onTap: onTap,
            child: SizedBox(
              height: DialogueLayout.topicRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          // An asked question steps back a little.
                          color: view.isNew
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (view.isNew)
                      _NewLabel(text: l10n.dialogueTopicNew)
                    else
                      const Icon(
                        Icons.check,
                        color: AppColors.textSecondary,
                        size: AppSizes.hudIcon,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The small "new" tag on a question that was never asked.
class _NewLabel extends StatelessWidget {
  const _NewLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}
