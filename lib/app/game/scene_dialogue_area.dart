import 'dart:async';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/scene_layout.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Puts the dialogue panel above the scene while a conversation is open.
///
/// The panel covers the scene image **except its bottom strip**
/// ([SceneLayout.chatStripHeight]): the detective message bar lives there,
/// and the detective comments on answers while the conversation goes on.
/// The item panel lies outside the scene area, so it stays free too: an
/// item is shown to the character by tapping it there. A note is shown
/// through the "Show evidence" button this widget puts into the panel.
///
/// It lives in `app/` because it joins features: the open conversation is
/// part of the scene bloc's state, the panel belongs to `dialogue`.
class SceneDialogueArea extends StatelessWidget {
  const SceneDialogueArea({super.key});

  /// Opens the conversation. If it could not be opened (the save failed,
  /// the content has no such dialogue) the scene is told, so it does not
  /// stay locked under a panel that never appeared.
  static Future<void> _open(
    DialogueCubit cubit,
    SceneBloc bloc,
    String dialogueId, {
    String? showItemId,
  }) async {
    await cubit.open(dialogueId, showItemId: showItemId);
    if (!cubit.state.isOpen && !bloc.isClosed) {
      bloc.add(const DialogueClosed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SceneBloc, SceneState>(
      // The scene bloc says which conversation is open; the dialogue cubit
      // runs it.
      listenWhen: (previous, current) =>
          previous.activeDialogueId != current.activeDialogueId,
      listener: (context, state) {
        final dialogueId = state.activeDialogueId;
        if (dialogueId == null) {
          context.read<DialogueCubit>().leave();
        } else {
          unawaited(
            _open(
              context.read<DialogueCubit>(),
              context.read<SceneBloc>(),
              dialogueId,
              showItemId: state.shownItemId,
            ),
          );
        }
      },
      child: BlocSelector<DialogueCubit, DialogueState, bool>(
        selector: (state) => state.isOpen,
        builder: (context, isOpen) {
          if (!isOpen) return const SizedBox.shrink();
          return SafeArea(
            right: false,
            child: Center(
              child: AspectRatio(
                aspectRatio: SceneViewport.aspectRatio,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 1 - SceneLayout.chatStripHeight,
                    child: DialoguePanel(
                      // Notes are shown from the notebook, opened in
                      // selection mode.
                      headerActions: TextButton.icon(
                        onPressed: () =>
                            context.read<NotebookCubit>().openForSelection(),
                        icon: const Icon(Icons.menu_book),
                        label: Text(context.l10n.dialogueShowEvidence),
                      ),
                      onClose: () =>
                          context.read<SceneBloc>().add(const DialogueClosed()),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
