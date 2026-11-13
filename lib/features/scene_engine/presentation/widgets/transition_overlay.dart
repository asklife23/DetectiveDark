import 'dart:async';

import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/widgets.dart';

/// The black layer of a scene transition. It owns the timing; the bloc
/// only knows the phase (ADR 0007).
///
/// - Phase `covering`: fade to black, wait for the hold time, then call
///   [onCovered]. The bloc swaps the scene while the screen is black.
/// - Phase `revealing`: fade back in, then call [onFinished].
///
/// While a transition runs, the layer swallows every touch.
class TransitionOverlay extends StatefulWidget {
  const TransitionOverlay({
    required this.phase,
    required this.transition,
    required this.onCovered,
    required this.onFinished,
    super.key,
  });

  final TransitionPhase phase;

  /// The running transition; null while [phase] is idle.
  final SceneTransition? transition;

  final VoidCallback onCovered;
  final VoidCallback onFinished;

  @override
  State<TransitionOverlay> createState() => _TransitionOverlayState();
}

class _TransitionOverlayState extends State<TransitionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _darkness = AnimationController(vsync: this);
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void didUpdateWidget(TransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) _run();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _darkness.dispose();
    super.dispose();
  }

  void _run() {
    _holdTimer?.cancel();
    final transition = widget.transition ?? SceneTransition.standard;

    switch (widget.phase) {
      case TransitionPhase.idle:
        _darkness.value = 0;
      case TransitionPhase.covering:
        unawaited(
          _darkness
              .animateTo(1, duration: transition.fadeOut)
              .whenComplete(() => _hold(transition.hold)),
        );
      case TransitionPhase.revealing:
        _darkness.value = 1;
        unawaited(
          _darkness.animateTo(0, duration: transition.fadeIn).whenComplete(() {
            if (mounted && widget.phase == TransitionPhase.revealing) {
              widget.onFinished();
            }
          }),
        );
    }
  }

  /// Stays black for [hold] (e.g. while a door sound plays), then reports.
  void _hold(Duration hold) {
    if (!mounted || widget.phase != TransitionPhase.covering) return;
    if (hold == Duration.zero) {
      widget.onCovered();
      return;
    }
    _holdTimer = Timer(hold, () {
      if (mounted && widget.phase == TransitionPhase.covering) {
        widget.onCovered();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.phase == TransitionPhase.idle,
      child: FadeTransition(
        opacity: _darkness,
        child: const ColoredBox(
          color: AppColors.fade,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
