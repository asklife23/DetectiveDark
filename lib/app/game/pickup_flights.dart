import 'dart:async';

import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/widgets/flight_layer.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:flutter/widgets.dart';

/// Lets collected things fly from the scene to where they are kept: an item
/// into its slot in the item panel, a note into the notebook button.
///
/// It listens to the game events and owns everything a flight needs (the
/// anchor registry, the flight layer, the place of the last tap), so the
/// HUD widget only has to put the pieces on screen. It lives in `app/`
/// because a flight connects three features.
class PickupFlights {
  PickupFlights({
    required GameEventBus eventBus,
    required this._findItem,
  }) {
    _itemObtained = eventBus.on<ItemObtained>().listen(_onItemObtained);
    _noteAdded = eventBus.on<NoteAdded>().listen(_onNoteAdded);
  }

  /// Looks an item up in the inventory (to draw its icon while it flies).
  final ItemDefinition? Function(String itemId) _findItem;

  /// Where the widgets that take part in a flight are on screen.
  final anchors = FlyAnchors();

  /// Key of the [FlightLayer] the HUD puts on top of everything.
  final layerKey = GlobalKey<FlightLayerState>();

  /// Items whose flying copy has not landed yet: their slot stays empty
  /// until it does.
  final arrivingItemIds = ValueNotifier<Set<String>>(const {});

  /// Where each hotspot was on screen when it was last tapped. A pickup
  /// hides its hotspot at once, so the start of the flight is kept here.
  final _tapRects = <String, Rect>{};

  late final StreamSubscription<ItemObtained> _itemObtained;
  late final StreamSubscription<NoteAdded> _noteAdded;
  bool _isDisposed = false;

  /// Call when a hotspot is tapped, before the tap reaches the game logic.
  void rememberTap(String hotspotId) {
    if (anchors.rectOf(FlyAnchors.hotspot(hotspotId)) case final rect?) {
      _tapRects[hotspotId] = rect;
    }
  }

  /// A square in the middle of [rect]: where a flying icon starts.
  Rect _iconRect(Rect rect) => Rect.fromCenter(
    center: rect.center,
    width: rect.shortestSide,
    height: rect.shortestSide,
  );

  Future<void> _onItemObtained(ItemObtained event) async {
    final from = _tapRects[event.hotspotId];
    if (from == null || _isDisposed) return;
    arrivingItemIds.value = {...arrivingItemIds.value, event.itemId};

    // One frame later the item panel has built the new slot.
    await WidgetsBinding.instance.endOfFrame;
    if (_isDisposed) return;
    final item = _findItem(event.itemId);
    if (item != null) {
      await layerKey.currentState?.fly(
        from: _iconRect(from),
        to: () =>
            anchors.rectOf(FlyAnchors.item(item.id)) ??
            anchors.rectOf(FlyAnchors.itemPanel),
        child: ItemIcon(item: item),
      );
    }
    if (_isDisposed) return;
    arrivingItemIds.value = {...arrivingItemIds.value}..remove(event.itemId);
  }

  /// The collected paper flies into the notebook button.
  Future<void> _onNoteAdded(NoteAdded event) async {
    final from = _tapRects[event.hotspotId];
    if (from == null || _isDisposed) return;
    await layerKey.currentState?.fly(
      from: _iconRect(from),
      to: () => anchors.rectOf(FlyAnchors.notebookButton),
      child: const NotePaperIcon(),
    );
  }

  void dispose() {
    _isDisposed = true;
    unawaited(_itemObtained.cancel());
    unawaited(_noteAdded.cancel());
    arrivingItemIds.dispose();
  }
}
