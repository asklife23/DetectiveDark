/// Animation and timing defaults.
///
/// Scene transitions: fade to black → change scene → fade in. Each
/// `goToScene` effect can override these from JSON (`fadeOutMs`, `holdMs`,
/// `fadeInMs`); these are the values used when it does not.
abstract final class AppDurations {
  static const sceneFadeOut = Duration(milliseconds: 150);
  static const Duration sceneHold = Duration.zero;
  static const sceneFadeIn = Duration(milliseconds: 150);
}
