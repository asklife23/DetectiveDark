import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/note_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The open notebook: three tabs (documents, observations, people), the
/// notes of the tab on the left page and the selected note on the right
/// page.
///
/// It lies above the scene (it is not a route), so the game underneath
/// stays exactly as it was. A tap outside or the close button closes it.
///
/// In selection mode (`NotebookState.isSelecting`) the open note carries a
/// "Show" button that calls [onShowNote]: the player picks a note as
/// evidence. The notebook does not know who it is shown to.
class NotebookScreen extends StatelessWidget {
  const NotebookScreen({this.onShowNote, super.key});

  /// Called with the ID of the note the player wants to show.
  final ValueChanged<String>? onShowNote;

  /// Share of the width used by the list; the note gets the rest.
  static const _listFlex = 2;
  static const _noteFlex = 3;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotebookCubit>();

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: cubit.closeNotebook,
          child: const ColoredBox(color: AppColors.scrim),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GestureDetector(
              // Taps on the pages must not reach the scrim.
              onTap: () {},
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
                ),
                child: BlocBuilder<NotebookCubit, NotebookState>(
                  builder: (context, state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Tabs(selected: state.category),
                      const Divider(height: 1, color: AppColors.paperShade),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: _listFlex,
                              child: _NoteList(state: state),
                            ),
                            const VerticalDivider(
                              width: 1,
                              color: AppColors.paperShade,
                            ),
                            Expanded(
                              flex: _noteFlex,
                              child: NotePage(
                                entry: state.selectedEntry,
                                highlightedLineId: state.highlightedLineId,
                                onShow: state.isSelecting ? onShowNote : null,
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
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: HudIconButton(
                icon: Icons.close,
                tooltip: context.l10n.closeTooltip,
                onPressed: cubit.closeNotebook,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _tabLabel(AppLocalizations l10n, NoteCategory category) =>
    switch (category) {
      NoteCategory.document => l10n.notebookTabDocuments,
      NoteCategory.observation => l10n.notebookTabObservations,
      NoteCategory.person => l10n.notebookTabPeople,
    };

String _emptyText(AppLocalizations l10n, NoteCategory category) =>
    switch (category) {
      NoteCategory.document => l10n.notebookEmptyDocuments,
      NoteCategory.observation => l10n.notebookEmptyObservations,
      NoteCategory.person => l10n.notebookEmptyPeople,
    };

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected});

  final NoteCategory selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.titleSmall;

    return Padding(
      // Room on the right for the close button.
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSizes.hudButton + AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final category in NoteCategory.values)
            Semantics(
              button: true,
              selected: category == selected,
              child: InkWell(
                onTap: () =>
                    context.read<NotebookCubit>().selectCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: category == selected
                            ? AppColors.ink
                            : AppColors.paper,
                        width: AppSizes.selectedBorder,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabLabel(l10n, category),
                    style: style?.copyWith(
                      color: category == selected
                          ? AppColors.ink
                          : AppColors.inkFaded,
                      fontWeight: category == selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  const _NoteList({required this.state});

  final NotebookState state;

  @override
  Widget build(BuildContext context) {
    final entries = state.visibleEntries;
    final textTheme = Theme.of(context).textTheme;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          _emptyText(context.l10n, state.category),
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.inkFaded,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final texts = context.storyTexts;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      children: [
        for (final entry in entries)
          Semantics(
            button: true,
            selected: entry.note.id == state.selectedNoteId,
            child: InkWell(
              onTap: () =>
                  context.read<NotebookCubit>().selectNote(entry.note.id),
              child: Container(
                color: entry.note.id == state.selectedNoteId
                    ? AppColors.paperShade
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  texts.text(entry.note.titleKey),
                  // An unread note is written in bold.
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: entry.isRead
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
