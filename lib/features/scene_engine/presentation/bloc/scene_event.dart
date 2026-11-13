part of 'scene_bloc.dart';

/// Everything that can happen to the scene view.
sealed class SceneEvent extends Equatable {
  const SceneEvent();

  @override
  List<Object?> get props => [];
}

/// Load the content and start (or continue) the game.
final class SceneStarted extends SceneEvent {
  const SceneStarted();
}

/// The player tapped a hotspot, possibly with an item selected.
final class HotspotTapped extends SceneEvent {
  const HotspotTapped(this.hotspotId, {this.usingItemId});

  final String hotspotId;
  final String? usingItemId;

  @override
  List<Object?> get props => [hotspotId, usingItemId];
}

/// Back button, Android system back or Esc.
final class BackPressed extends SceneEvent {
  const BackPressed();
}

/// The transition overlay is fully black: the scene may change now.
final class TransitionCovered extends SceneEvent {
  const TransitionCovered();
}

/// The transition overlay is gone again.
final class TransitionFinished extends SceneEvent {
  const TransitionFinished();
}

/// Open the inspection panel from outside the scene (the examine card of
/// an inventory item).
final class InspectionRequested extends SceneEvent {
  const InspectionRequested(this.inspection);

  final InspectionDefinition inspection;

  @override
  List<Object?> get props => [inspection];
}

/// The inspection panel was closed.
final class InspectionClosed extends SceneEvent {
  const InspectionClosed();
}

/// The stored progress changed (possibly from another feature).
final class _ProgressChanged extends SceneEvent {
  const _ProgressChanged(this.progress);

  final GameProgress progress;

  @override
  List<Object?> get props => [progress];
}
