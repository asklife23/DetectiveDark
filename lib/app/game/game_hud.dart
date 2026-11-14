import 'dart:async';

import 'package:detective_dark/app/game/item_inspection.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/flight_layer.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
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
/// - a collected item flies from the scene into the item panel, a
///   collected note into the notebook button;
/// - the notebook opens above the scene.
///
/// It also owns Back from outside the scene: the Android system back
/// button and the Esc key first close what is open, then leave the
/// close-up. In a main scene a second press of the system button exits the
/// app; Esc does nothing there.
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
  StreamSubscription<NoteAdded>? _noteAdded;

  @override
  void initState() {
    super.initState();
    final bus = context.read<GameEventBus>();
    _itemObtained = bus.on<ItemObtained>().listen(_onItemObtained);
    _noteAdded = bus.on<NoteAdded>().listen(_onNoteAdded);
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    unawaited(_itemObtained?.cancel());
    unawaited(_noteAdded?.cancel());
    super.dispose();
  }

  /// A square in the middle of [rect]: where a flying icon starts.
  Rect _iconRect(Rect rect) => Rect.fromCenter(
    center: rect.center,
    width: rect.shortestSide,
    height: rect.shortestSide,
  );

  /// The collected paper flies into the notebook button.
  Future<void> _onNoteAdded(NoteAdded event) async {
    final from = _tapRects[event.hotspotId];
    if (from == null || !mounted) return;
    await _flightKey.currentState?.fly(
      from: _iconRect(from),
      to: () => _anchors.rectOf(FlyAnchors.notebookButton),
      child: const NotePaperIcon(),
    );
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
      await _flightKey.currentState?.fly(
        from: _iconRect(from),
        to: () =>
            _anchors.rectOf(FlyAnchors.item(item.id)) ??
            _anchors.rectOf(FlyAnchors.itemPanel),
        child: ItemIcon(item: item),
      );
    }
    if (mounted) setState(() => _arrivingItems.remove(event.itemId));
  }

  /// Closes the topmost open thing or leaves the close-up. Returns false
  /// when there was nothing to go back from (a main scene, nothing open).
  bool _goBack() {
    final notebook = context.read<NotebookCubit>();
    if (notebook.state.isOpen) {
      notebook.closeNotebook();
      return true;
    }

    final bloc = context.read<SceneBloc>();
    final state = bloc.state;
    final hasSomethingToClose =
        state.canGoBack ||
        state.activeInspection != null ||
        state.transitionPhase != TransitionPhase.idle;
    if (hasSomethingToClose) bloc.add(const BackPressed());
    return hasSomethingToClose;
  }

  /// Android system back (button or gesture).
  void _onSystemBack() {
    if (_goBack()) return;

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
        child: _BackShortcut(
          onBack: _goBack,
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
                  ColoredBox(
                    color: AppColors.surface,
                    child: SafeArea(
                      left: false,
                      child: SizedBox(
                        width: AppSizes.sidebarWidth,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              child: NotebookButton(),
                            ),
                            Expanded(
                              child: ItemSidebar(
                                arrivingItemIds: _arrivingItems,
                                onExamine: (item) => bloc.add(
                                  InspectionRequested(inspectionForItem(item)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              BlocSelector<NotebookCubit, NotebookState, bool>(
                selector: (state) => state.isOpen,
                builder: (context, isOpen) =>
                    isOpen ? const NotebookScreen() : const SizedBox.shrink(),
              ),
              FlightLayer(key: _flightKey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Esc works like the Back button, wherever the keyboard focus is inside
/// the game. Plain keyboard input, not tied to a platform.
class _BackShortcut extends StatelessWidget {
  const _BackShortcut({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    onBack();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    // Key events travel from the focused widget up to this node, which
    // takes the focus as soon as the game is on screen. It is not a control
    // of its own, so it stays out of the accessibility tree (a semantics
    // node here would swallow the labels of the hotspots below it).
    return Focus(
      autofocus: true,
      includeSemantics: false,
      onKeyEvent: _onKey,
      child: child,
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
