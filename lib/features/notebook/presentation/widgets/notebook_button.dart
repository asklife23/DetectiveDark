import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/core/widgets/hud_badge.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The HUD button that opens the notebook. A badge shows how many notes
/// have not been read yet.
class NotebookButton extends StatelessWidget {
  const NotebookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FlyAnchor(
      id: FlyAnchors.notebookButton,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          HudIconButton(
            icon: Icons.menu_book,
            tooltip: context.l10n.notebookTooltip,
            onPressed: () => context.read<NotebookCubit>().openNotebook(),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: BlocSelector<NotebookCubit, NotebookState, int>(
              selector: (state) => state.unreadCount,
              builder: (context, unread) => unread == 0
                  ? const SizedBox.shrink()
                  : HudBadge(count: unread),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small sheet of paper: what flies into the notebook when a note is
/// collected.
class NotePaperIcon extends StatelessWidget {
  const NotePaperIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      child: Icon(Icons.description, color: AppColors.paper),
    );
  }
}
