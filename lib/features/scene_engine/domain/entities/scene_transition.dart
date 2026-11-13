import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:equatable/equatable.dart';

/// How the screen changes from one scene to the next. There is no zoom
/// (ADR 0007).
enum SceneTransitionType {
  /// Fade to black, change the scene, fade back in.
  fade,

  /// Change the scene at once.
  cut,
}

/// The transition of one `goToScene` effect. Content can override every
/// part; the defaults are a 150 ms fade out and a 150 ms fade in.
class SceneTransition extends Equatable {
  const SceneTransition({
    this.type = SceneTransitionType.fade,
    this.fadeOut = AppDurations.sceneFadeOut,
    this.hold = AppDurations.sceneHold,
    this.fadeIn = AppDurations.sceneFadeIn,
    this.sfx,
  });

  /// The default timing with the given [type]. Used by Back.
  const SceneTransition.ofType(this.type)
    : fadeOut = AppDurations.sceneFadeOut,
      hold = AppDurations.sceneHold,
      fadeIn = AppDurations.sceneFadeIn,
      sfx = null;

  /// The default transition.
  static const standard = SceneTransition();

  final SceneTransitionType type;
  final Duration fadeOut;

  /// Time spent in full black, e.g. while a door sound plays.
  final Duration hold;

  final Duration fadeIn;

  /// Optional sound effect ID. Sound is connected in Phase 6.
  final String? sfx;

  @override
  List<Object?> get props => [type, fadeOut, hold, fadeIn, sfx];
}
