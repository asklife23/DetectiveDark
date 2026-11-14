import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:flutter/material.dart';

/// The right page of the notebook: the selected note with its title, its
/// text and, below, the lines it has gained so far (ADR 0015), oldest
/// first.
class NotePage extends StatelessWidget {
  const NotePage({
    required this.entry,
    this.highlightedLineId,
    this.onShow,
    super.key,
  });

  /// Key of the line that is marked as new, for tests.
  static const Key highlightKey = ValueKey('note_page_new_line');

  static const _bodyLineHeight = 1.5;

  final NotebookEntry? entry;

  /// The line that made the note unread; drawn marked.
  final String? highlightedLineId;

  /// When set, the page offers a "Show" button that calls this with the ID
  /// of the note (the notebook was opened to pick evidence).
  final ValueChanged<String>? onShow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final entry = this.entry;
    final onShow = this.onShow;

    if (entry == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            onShow == null
                ? context.l10n.notebookSelectHint
                : context.l10n.notebookPickEvidenceHint,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.inkFaded),
          ),
        ),
      );
    }

    final texts = context.storyTexts;
    final bodyStyle = textTheme.titleSmall?.copyWith(
      color: AppColors.ink,
      height: _bodyLineHeight,
    );
    final page = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.text(entry.note.titleKey),
            style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(texts.text(entry.note.bodyKey), style: bodyStyle),
          for (final line in entry.lines)
            _NoteLine(
              key: line.id == highlightedLineId ? highlightKey : null,
              text: texts.text(line.textKey),
              style: bodyStyle,
              isNew: line.id == highlightedLineId,
            ),
        ],
      ),
    );

    if (onShow == null) return page;
    // Picking evidence: the button stays under the text, always in reach.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: page),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.paper,
            ),
            onPressed: () => onShow(entry.note.id),
            icon: const Icon(Icons.front_hand_outlined),
            label: Text(context.l10n.notebookShowButton),
          ),
        ),
      ],
    );
  }
}

/// One added line: a short rule on the left, like a margin note. The
/// newest line of an updated note lies on shaded paper.
class _NoteLine extends StatelessWidget {
  const _NoteLine({
    required this.text,
    required this.style,
    required this.isNew,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isNew ? AppColors.paperShade : null,
          border: const Border(
            left: BorderSide(
              color: AppColors.inkFaded,
              width: AppSizes.selectedBorder,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            text,
            style: style?.copyWith(
              fontWeight: isNew ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
