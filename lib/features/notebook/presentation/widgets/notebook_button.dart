import 'dart:async';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/core/widgets/hud_badge.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The HUD button that opens the notebook. A badge shows how many notes
/// have not been read yet.
///
/// When a note that is already in the notebook gains a line, the button
/// swells once: nothing flies in (that is for new notes), but the player
/// sees that the notebook changed.
class NotebookButton extends StatefulWidget {
  const NotebookButton({this.onPressed, super.key});

  /// What a tap does; by default it opens the notebook.
  final VoidCallback? onPressed;

  @override
  State<NotebookButton> createState() => _NotebookButtonState();
}

class _NotebookButtonState extends State<NotebookButton>
    with SingleTickerProviderStateMixin {
  /// How much the button grows at the peak of the pulse.
  static const _pulseScale = 1.25;

  late final _controller = AnimationController(
    vsync: this,
    duration: AppDurations.notebookPulse,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: _pulseScale), weight: 1),
    TweenSequenceItem(tween: Tween(begin: _pulseScale, end: 1), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotebookCubit, NotebookState>(
      listenWhen: (previous, current) =>
          previous.updatePulse != current.updatePulse,
      listener: (context, state) => unawaited(_controller.forward(from: 0)),
      child: FlyAnchor(
        id: FlyAnchors.notebookButton,
        child: ScaleTransition(
          scale: _scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HudIconButton(
                icon: Icons.menu_book,
                tooltip: context.l10n.notebookTooltip,
                onPressed:
                    widget.onPressed ??
                    () => context.read<NotebookCubit>().openNotebook(),
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
        ),
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
