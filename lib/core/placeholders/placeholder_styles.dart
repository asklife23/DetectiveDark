/// Names of the placeholder drawings.
///
/// Until real artwork exists, every scene, inspection and item names one of
/// these styles and the game draws it with a `CustomPainter`. When an
/// asset path is set in the content JSON, the style is no longer used.
abstract final class PlaceholderStyles {
  static const villaExterior = 'villa_exterior';
  static const villaDoorClosed = 'villa_door_closed';
  static const villaDoorOpen = 'villa_door_open';
  static const statueCloseup = 'statue_closeup';
  static const villaHall = 'villa_hall';
  static const statuePlaque = 'statue_plaque';
  static const itemBrassKey = 'item_brass_key';

  /// Objects drawn on top of a scene (hotspot sprites, ADR 0012). They
  /// fill their own small box and have a transparent background.
  static const spriteBrassKey = 'sprite_brass_key';
  static const spriteLetter = 'sprite_letter';

  /// Every style name content may use.
  static const Set<String> names = {
    villaExterior,
    villaDoorClosed,
    villaDoorOpen,
    statueCloseup,
    villaHall,
    statuePlaque,
    itemBrassKey,
    spriteBrassKey,
    spriteLetter,
  };
}
