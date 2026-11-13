import 'dart:async';

import 'package:detective_dark/app/game/item_inspection.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/flight_layer.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The running game: the scene with the fixed interface (HUD) around it.
///
/// This is where the features are connected, because only the `app/` layer
/// may know several of them:
/// - a tap on the scene is sent to the scene bloc together with the item
///   selected in the inventory, then the selection is cleared;
/// - a long press on an item opens the examine card of the scene engine;
/// - a collected item flies from the scene into the item panel.
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
  final _anchors = FlyAnchors();
  final _flightKey = GlobalKey<FlightLayerState>();

  /// Where each hotspot was on screen when it was last tapped. A pickup
  /// hides its hotspot at once, so the start of the flight is kept here.
  final _tapRects = <String, Rect>{};

  /// Items whose flying copy has not landed yet.
  final _arrivingItems = <String>{};

  bool _showHotspots = false;
  Timer? _exitTimer;
  StreamSubscription<ItemObtained>? _itemObtained;

  @override
  void initState() {
    super.initState();
    _itemObtained = context.read<GameEventBus>().on<ItemObtained>().listen(
      _onItemObtained,
    );
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    unawaited(_itemObtained?.cancel());
    super.dispose();
  }

  void _onHotspotTap(String hotspotId) {
    final inventory = context.read<InventoryCubit>();
    if (_anchors.rectOf(FlyAnchors.hotspot(hotspotId)) case final rect?) {
      _tapRects[hotspotId] = rect;
    }
    context.read<SceneBloc>().add(
      HotspotTapped(hotspotId, usingItemId: inventory.state.selectedItemId),
    );
    inventory.clearSelection();
  }

  Future<void> _onItemObtained(ItemObtained event) async {
    final from = _tapRects[event.hotspotId];
    if (from == null || !mounted) return;
    setState(() => _arrivingItems.add(event.itemId));

    // One frame later the item panel has built the new slot.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final items = context.read<InventoryCubit>().state.items;
    final item = items.where((item) => item.id == event.itemId).firstOrNull;
    if (item != null) {
      // Fly a square icon out of the middle of the hotspot.
      final start = Rect.fromCenter(
        center: from.center,
        width: from.shortestSide,
        height: from.shortestSide,
      );
      await _flightKey.currentState?.fly(
        from: start,
        to: () =>
            _anchors.rectOf(FlyAnchors.item(item.id)) ??
            _anchors.rectOf(FlyAnchors.itemPanel),
        child: ItemIcon(item: item),
      );
    }
    if (mounted) setState(() => _arrivingItems.remove(event.itemId));
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

    return PopScope<void>(
      // The app never pops this screen by itself; Back is game navigation.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onSystemBack();
      },
      child: FlyAnchorScope(
        anchors: _anchors,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                // The scene gets what is left of the item panel, so no
                // hotspot can ever lie under the panel.
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SceneView(
                        showHotspotDebug: _showHotspots,
                        onHotspotTap: _onHotspotTap,
                      ),
                      _SceneButtons(
                        showDebugTools: widget.showDebugTools,
                        showHotspots: _showHotspots,
                        onToggleHotspots: () =>
                            setState(() => _showHotspots = !_showHotspots),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  left: false,
                  child: ItemSidebar(
                    arrivingItemIds: _arrivingItems,
                    onExamine: (item) =>
                        bloc.add(InspectionRequested(inspectionForItem(item))),
                  ),
                ),
              ],
            ),
            FlightLayer(key: _flightKey),
          ],
        ),
      ),
    );
  }
}

/// The buttons that sit on the scene: Back and the developer tools.
class _SceneButtons extends StatelessWidget {
  const _SceneButtons({
    required this.showDebugTools,
    required this.showHotspots,
    required this.onToggleHotspots,
  });

  final bool showDebugTools;
  final bool showHotspots;
  final VoidCallback onToggleHotspots;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      right: false,
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
                        onPressed: () =>
                            context.read<SceneBloc>().add(const BackPressed()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (showDebugTools)
              Align(
                alignment: Alignment.bottomLeft,
                child: HudIconButton(
                  icon: showHotspots ? Icons.grid_off : Icons.grid_on,
                  tooltip: l10n.debugHotspotsTooltip,
                  onPressed: onToggleHotspots,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
