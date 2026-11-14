/// Animation and timing defaults.
///
/// Scene transitions: fade to black → change scene → fade in. Each
/// `goToScene` effect can override these from JSON (`fadeOutMs`, `holdMs`,
/// `fadeInMs`); these are the values used when it does not.
abstract final class AppDurations {
  static const sceneFadeOut = Duration(milliseconds: 150);
  static const Duration sceneHold = Duration.zero;
  static const sceneFadeIn = Duration(milliseconds: 150);

  /// The ring that spreads from the point where a hotspot was tapped.
  static const hotspotRipple = Duration(milliseconds: 350);

  /// One slow pulse of the glimmer on something that can be picked up.
  static const glintPulse = Duration(milliseconds: 2400);

  /// The inspection panel fading in.
  static const inspectPanelFade = Duration(milliseconds: 180);

  /// A collected item flying from the scene into its inventory slot.
  static const itemFlight = Duration(milliseconds: 450);

  /// The item icon appearing in its slot once the flying copy has landed.
  static const itemLand = Duration(milliseconds: 200);

  /// A used-up item fading out of the panel.
  static const itemFadeOut = Duration(milliseconds: 250);

  /// The frame of an inventory slot changing when it is selected.
  static const itemSelect = Duration(milliseconds: 150);

  /// The notebook button swelling once when a known note gains a line.
  static const notebookPulse = Duration(milliseconds: 320);

  /// A line of a character in the dialogue panel: time per typed
  /// character. A little slower than the inner voice: somebody is talking.
  static const dialogueTypePerCharacter = Duration(milliseconds: 22);

  /// The detective message bar: time per typed character.
  static const chatTypePerCharacter = Duration(milliseconds: 18);

  /// How long a finished message stays before the bar shrinks: at least
  /// [chatLingerMin], longer for long messages ([chatLingerPerCharacter]).
  static const chatLingerMin = Duration(milliseconds: 2600);
  static const chatLingerPerCharacter = Duration(milliseconds: 45);

  /// The bar opening and shrinking to its button.
  static const chatBarToggle = Duration(milliseconds: 200);

  /// How long "press back again to exit" stays armed.
  static const exitConfirmWindow = Duration(seconds: 2);
}
