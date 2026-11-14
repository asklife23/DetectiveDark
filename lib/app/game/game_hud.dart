import 'dart:async';

import 'package:detective_dark/app/game/back_shortcut.dart';
import 'package:detective_dark/app/game/hud_side_panel.dart';
import 'package:detective_dark/app/game/pickup_flights.dart';
import 'package:detective_dark/app/game/scene_buttons.dart';
import 'package:detective_dark/app/game/scene_chat_strip.dart';
import 'package:detective_dark/app/game/scene_dialogue_area.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/widgets/flight_layer.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_history_sheet.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
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
///   collected note into the notebook button ([PickupFlights]);
/// - the notebook and the message history open above the scene;
/// - the detective message bar lies on the bottom strip of the scene;
/// - the dialogue panel opens above the scene, leaving that strip and the
///   item panel free; while it is open, a tap on an item shows it to the
///   character and the notebook opens to pick a note as evidence.
///
/// It also owns Back from outside the scene: the Android system back
/// button and the Esc key first close what is open (notebook or message
/// history, then the dialogue or inspection panel), then leave the
/// close-up. In a main scene a second press of the system button exits the
/// app; Esc does nothing there.
class GameHud extends StatefulWidget {
  const GameHud({this.showDebugTools = false, super.key});

  final bool showDebugTools;

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  late final PickupFlights _flights;
  bool _showHotspots = false;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _flights = PickupFlights(
      eventBus: context.read<GameEventBus>(),
      findItem: (itemId) => context
          .read<InventoryCubit>()
          .state
          .items
          .where((item) => item.id == itemId)
          .firstOrNull,
    );
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _flights.dispose();
    super.dispose();
  }

  void _onHotspotTap(String hotspotId) {
    final inventory = context.read<InventoryCubit>();
    _flights.rememberTap(hotspotId);
    context.read<SceneBloc>().add(
      HotspotTapped(hotspotId, usingItemId: inventory.state.selectedItemId),
    );
    inventory.clearSelection();
  }

  /// The player picked a note as evidence: the notebook closes and the
  /// character reacts.
  void _showNote(String noteId) {
    context.read<NotebookCubit>().closeNotebook();
    unawaited(context.read<DialogueCubit>().show(ShowNote(noteId)));
  }

  /// Closes the topmost open thing or leaves the close-up. Returns false
  /// when there was nothing to go back from (a main scene, nothing open).
  bool _goBack() {
    final notebook = context.read<NotebookCubit>();
    if (notebook.state.isOpen) {
      notebook.closeNotebook();
      return true;
    }
    final chat = context.read<ChatCubit>();
    if (chat.state.isHistoryOpen) {
      chat.closeHistory();
      return true;
    }

    final bloc = context.read<SceneBloc>();
    final state = bloc.state;
    final hasSomethingToClose =
        state.canGoBack ||
        state.activeInspection != null ||
        state.activeDialogueId != null ||
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
    return PopScope<void>(
      // The app never pops this screen by itself; Back is game navigation.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onSystemBack();
      },
      child: FlyAnchorScope(
        anchors: _flights.anchors,
        child: BackShortcut(
          onBack: _goBack,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                children: [
                  // The scene gets what is left of the side panel, so no
                  // hotspot can ever lie under the panel.
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SceneView(
                          showHotspotDebug: _showHotspots,
                          onHotspotTap: _onHotspotTap,
                        ),
                        const SceneChatStrip(),
                        SceneButtons(
                          showDebugTools: widget.showDebugTools,
                          showHotspots: _showHotspots,
                          onToggleHotspots: () =>
                              setState(() => _showHotspots = !_showHotspots),
                        ),
                        const SceneDialogueArea(),
                      ],
                    ),
                  ),
                  HudSidePanel(arrivingItemIds: _flights.arrivingItemIds),
                ],
              ),
              BlocSelector<NotebookCubit, NotebookState, bool>(
                selector: (state) => state.isOpen,
                builder: (context, isOpen) => isOpen
                    ? NotebookScreen(onShowNote: _showNote)
                    : const SizedBox.shrink(),
              ),
              BlocSelector<ChatCubit, ChatState, bool>(
                selector: (state) => state.isHistoryOpen,
                builder: (context, isOpen) =>
                    isOpen ? const ChatHistorySheet() : const SizedBox.shrink(),
              ),
              FlightLayer(key: _flights.layerKey),
            ],
          ),
        ),
      ),
    );
  }
}
