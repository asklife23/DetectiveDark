import 'dart:async';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The running game: the scene with the fixed interface (HUD) around it.
///
/// It also owns the system back button: Back first closes what is open,
/// then leaves the close-up; in a main scene a second press exits the app.
class GameHud extends StatefulWidget {
  const GameHud({this.showDebugTools = false, super.key});

  final bool showDebugTools;

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  bool _showHotspots = false;
  Timer? _exitTimer;

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  /// Android system back (button or gesture).
  void _onSystemBack() {
    final bloc = context.read<SceneBloc>();
    final state = bloc.state;
    final hasSomethingToClose =
        state.canGoBack ||
        state.activeInspection != null ||
        state.transitionPhase != TransitionPhase.idle;
    if (hasSomethingToClose) {
      bloc.add(const BackPressed());
      return;
    }

    // Main scene: leave the app only on a second press.
    if (_exitTimer?.isActive ?? false) {
      unawaited(SystemNavigator.pop());
      return;
    }
    _exitTimer = Timer(AppDurations.exitConfirmWindow, () {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.exitHint),
          duration: AppDurations.exitConfirmWindow,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SceneBloc>();
    final l10n = context.l10n;

    return PopScope<void>(
      // The app never pops this screen by itself; Back is game navigation.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onSystemBack();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          SceneView(
            showHotspotDebug: _showHotspots,
            onHotspotTap: (hotspotId) => bloc.add(HotspotTapped(hotspotId)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: BlocSelector<SceneBloc, SceneState, bool>(
                      selector: (state) => state.canGoBack,
                      builder: (context, canGoBack) => canGoBack
                          ? HudIconButton(
                              icon: Icons.arrow_back,
                              tooltip: l10n.backTooltip,
                              onPressed: () => bloc.add(const BackPressed()),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (widget.showDebugTools)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: HudIconButton(
                        icon: _showHotspots ? Icons.grid_off : Icons.grid_on,
                        tooltip: l10n.debugHotspotsTooltip,
                        onPressed: () =>
                            setState(() => _showHotspots = !_showHotspots),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
