/// Names of the placeholder drawings.
///
/// Until real artwork exists, every scene, inspection and item names one of
/// these styles and the game draws it with a `CustomPainter`. When an
/// asset path is set in the content JSON, the style is no longer used.
abstract final class PlaceholderStyles {
  static const villaExterior = 'villa_exterior';
  static const villaDoorClosed = 'villa_door_closed';
  static const villaDoorOpen = 'villa_door_open';
  static const statueCloseupWithKey = 'statue_closeup_key';
  static const statueCloseup = 'statue_closeup';
  static const villaHallWithLetter = 'villa_hall_letter';
  static const villaHall = 'villa_hall';
  static const statuePlaque = 'statue_plaque';
  static const itemBrassKey = 'item_brass_key';

  /// Every style name content may use.
  static const Set<String> names = {
    villaExterior,
    villaDoorClosed,
    villaDoorOpen,
    statueCloseupWithKey,
    statueCloseup,
    villaHallWithLetter,
    villaHall,
    statuePlaque,
    itemBrassKey,
  };
}
