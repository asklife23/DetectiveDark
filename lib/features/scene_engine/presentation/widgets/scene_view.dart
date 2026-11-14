import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/hotspot_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_visual_view.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/transition_overlay.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The scene on screen, built from the state of the [SceneBloc].
///
/// Layer order, bottom to top: picture (background → objects → overlays →
/// noir filter) → hotspots → inspection panel → transition. Each layer listens
/// only to the part of the state it draws, so a pulsing hotspot or a fade
/// never repaints the picture.
class SceneView extends StatelessWidget {
  const SceneView({
    required this.onHotspotTap,
    this.showHotspotDebug = false,
    super.key,
  });

  /// Called with the ID of the tapped hotspot. The screen that owns this
  /// view adds the selected inventory item and sends the event to the bloc.
  final ValueChanged<String> onHotspotTap;

  final bool showHotspotDebug;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SceneBloc>();

    return SceneViewport(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BlocBuilder<SceneBloc, SceneState>(
            // The picture changes with the visual and with the objects in
            // it: a collected object disappears together with its hotspot.
            buildWhen: (previous, current) =>
                previous.visual != current.visual ||
                previous.visibleHotspots != current.visibleHotspots,
            builder: (context, state) {
              final visual = state.visual;
              if (visual == null) return const SizedBox.expand();
              return SceneVisualView(
                visual: visual,
                sprites: [
                  for (final hotspot in state.visibleHotspots) ?hotspot.sprite,
                ],
              );
            },
          ),
          RepaintBoundary(
            child: BlocSelector<SceneBloc, SceneState, List<HotspotDefinition>>(
              selector: (state) => state.visibleHotspots,
              builder: (context, hotspots) => HotspotLayer(
                hotspots: hotspots,
                showDebug: showHotspotDebug,
                onTap: onHotspotTap,
              ),
            ),
          ),
          BlocSelector<SceneBloc, SceneState, InspectionDefinition?>(
            selector: (state) => state.activeInspection,
            builder: (context, inspection) => inspection == null
                ? const SizedBox.shrink()
                : InspectPanel(
                    // A new inspection fades in again.
                    key: ValueKey(inspection.id),
                    inspection: inspection,
                    onClose: () => bloc.add(const InspectionClosed()),
                  ),
          ),
          BlocBuilder<SceneBloc, SceneState>(
            buildWhen: (previous, current) =>
                previous.transitionPhase != current.transitionPhase,
            builder: (context, state) => TransitionOverlay(
              phase: state.transitionPhase,
              transition: state.pendingTransition,
              onCovered: () => bloc.add(const TransitionCovered()),
              onFinished: () => bloc.add(const TransitionFinished()),
            ),
          ),
        ],
      ),
    );
  }
}
