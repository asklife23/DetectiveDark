import 'dart:async';

import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_view_resolver.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/start_game.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/tap_hotspot.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scene_event.dart';
part 'scene_state.dart';

/// Runs the scene view: which scene is on screen, what it looks like, what
/// a tap does, the navigation stack, transitions, the inspection panel and
/// which conversation is open.
///
/// Events are handled strictly one after another. A save is asynchronous,
/// so without this two quick taps could run the same rule twice.
class SceneBloc extends Bloc<SceneEvent, SceneState> {
  SceneBloc({
    required this._caseId,
    required this._startGame,
    required this._enterScene,
    required this._tapHotspot,
    required this._progressRepository,
    this._viewResolver = const SceneViewResolver(),
  }) : super(const SceneState()) {
    on<SceneEvent>(
      _onEvent,
      // `asyncExpand` waits for one handler to finish before it starts the
      // next: a sequential queue without an extra package.
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final String _caseId;
  final StartGame _startGame;
  final EnterScene _enterScene;
  final TapHotspot _tapHotspot;
  final ProgressRepository _progressRepository;
  final SceneViewResolver _viewResolver;

  StreamSubscription<GameProgress>? _progressSubscription;

  /// The transition type each scene was entered with, for this session.
  /// Back reuses it; a scene restored from a save falls back to a fade.
  final _entryTypes = <String, SceneTransitionType>{};

  Future<void> _onEvent(SceneEvent event, Emitter<SceneState> emit) {
    return switch (event) {
      SceneStarted() => _onStarted(emit),
      HotspotTapped() => _onHotspotTapped(event, emit),
      BackPressed() => _onBackPressed(emit),
      TransitionCovered() => _onTransitionCovered(emit),
      TransitionFinished() => _onTransitionFinished(emit),
      InspectionRequested() => _onInspectionRequested(event, emit),
      InspectionClosed() => _onInspectionClosed(emit),
      DialogueClosed() => _onDialogueClosed(emit),
      _ProgressChanged() => _onProgressChanged(event, emit),
    };
  }

  Future<void> _onStarted(Emitter<SceneState> emit) async {
    emit(const SceneState());
    await _progressSubscription?.cancel();

    switch (await _startGame(_caseId)) {
      case Failed(:final failure):
        emit(SceneState(status: SceneStatus.failed, failure: failure));
      case Success(value: StartedGame(:final content, :final progress)):
        final scene = content.scenes[progress.currentSceneId]!;
        emit(
          SceneState(
            status: SceneStatus.ready,
            content: content,
            progress: progress,
            scene: scene,
            visual: _viewResolver.visualFor(scene, progress),
            visibleHotspots: _viewResolver.visibleHotspots(scene, progress),
          ),
        );
        _progressSubscription = _progressRepository.watch().listen(
          (changed) => add(_ProgressChanged(changed)),
        );
    }
  }

  Future<void> _onHotspotTapped(
    HotspotTapped event,
    Emitter<SceneState> emit,
  ) async {
    final scene = state.scene;
    final progress = state.progress;
    if (!state.acceptsTaps || scene == null || progress == null) return;

    final result = await _tapHotspot(
      scene: scene,
      progress: progress,
      hotspotId: event.hotspotId,
      usingItemId: event.usingItemId,
      triggers: state.content?.triggers ?? const [],
    );

    switch (result) {
      case Failed(:final failure):
        addError(failure);
      case Success(value: final outcome):
        final inspection = state.content?.inspections[outcome.inspectionId];
        emit(
          _withProgress(outcome.progress)._copy(
            activeInspection: () => inspection,
            activeDialogueId: () => outcome.dialogueId,
            shownItemId: () => outcome.shownItemId,
          ),
        );
        if (outcome.navigation case final navigation?) {
          await _startTransition(
            navigation.sceneId,
            navigation.transition,
            emit,
          );
        }
    }
  }

  Future<void> _onBackPressed(Emitter<SceneState> emit) async {
    if (!state.isReady) return;
    if (state.activeInspection != null) {
      emit(state._copy(activeInspection: () => null));
      return;
    }
    // Back closes the conversation first and leaves the scene alone.
    if (state.activeDialogueId != null) {
      emit(_withoutDialogue());
      return;
    }
    if (state.transitionPhase != TransitionPhase.idle || !state.canGoBack) {
      return;
    }

    final stack = state.stack;
    final type = _entryTypes[stack.last] ?? SceneTransitionType.fade;
    await _startTransition(
      stack[stack.length - 2],
      SceneTransition.ofType(type),
      emit,
    );
  }

  /// A fade waits for the UI to report black ([TransitionCovered]); a cut
  /// changes the scene at once.
  Future<void> _startTransition(
    String sceneId,
    SceneTransition transition,
    Emitter<SceneState> emit,
  ) async {
    if (transition.type == SceneTransitionType.cut) {
      await _enter(sceneId, transition, emit, TransitionPhase.idle);
      return;
    }
    emit(
      state._copy(
        transitionPhase: TransitionPhase.covering,
        pendingTransition: () => transition,
        pendingSceneId: () => sceneId,
      ),
    );
  }

  Future<void> _onTransitionCovered(Emitter<SceneState> emit) async {
    final sceneId = state.pendingSceneId;
    final transition = state.pendingTransition;
    if (state.transitionPhase != TransitionPhase.covering ||
        sceneId == null ||
        transition == null) {
      return;
    }
    await _enter(sceneId, transition, emit, TransitionPhase.revealing);
  }

  Future<void> _enter(
    String sceneId,
    SceneTransition transition,
    Emitter<SceneState> emit,
    TransitionPhase nextPhase,
  ) async {
    final content = state.content;
    final progress = state.progress;
    if (content == null || progress == null) return;

    final result = await _enterScene(
      content: content,
      progress: progress,
      sceneId: sceneId,
    );

    switch (result) {
      case Failed(:final failure):
        addError(failure);
        emit(_withoutTransition(state));
      case Success(value: final entered):
        _entryTypes[sceneId] = transition.type;
        final scene = content.scenes[sceneId]!;
        final next = state._copy(
          progress: entered,
          scene: scene,
          visual: _viewResolver.visualFor(scene, entered),
          visibleHotspots: _viewResolver.visibleHotspots(scene, entered),
          transitionPhase: nextPhase,
        );
        emit(
          nextPhase == TransitionPhase.idle ? _withoutTransition(next) : next,
        );
    }
  }

  Future<void> _onTransitionFinished(Emitter<SceneState> emit) async {
    if (state.transitionPhase != TransitionPhase.revealing) return;
    emit(_withoutTransition(state));
  }

  Future<void> _onInspectionRequested(
    InspectionRequested event,
    Emitter<SceneState> emit,
  ) async {
    // Panels never stack: no examine card while a conversation is open.
    if (!state.acceptsTaps) return;
    emit(state._copy(activeInspection: () => event.inspection));
  }

  Future<void> _onInspectionClosed(Emitter<SceneState> emit) async {
    if (state.activeInspection == null) return;
    emit(state._copy(activeInspection: () => null));
  }

  Future<void> _onDialogueClosed(Emitter<SceneState> emit) async {
    if (state.activeDialogueId == null) return;
    emit(_withoutDialogue());
  }

  SceneState _withoutDialogue() =>
      state._copy(activeDialogueId: () => null, shownItemId: () => null);

  Future<void> _onProgressChanged(
    _ProgressChanged event,
    Emitter<SceneState> emit,
  ) async {
    if (!state.isReady || event.progress == state.progress) return;
    emit(_withProgress(event.progress));
  }

  /// The current scene, redrawn for [progress] (variant and hotspots).
  SceneState _withProgress(GameProgress progress) {
    final scene = state.scene;
    if (scene == null) return state;
    return state._copy(
      progress: progress,
      visual: _viewResolver.visualFor(scene, progress),
      visibleHotspots: _viewResolver.visibleHotspots(scene, progress),
    );
  }

  SceneState _withoutTransition(SceneState from) => from._copy(
    transitionPhase: TransitionPhase.idle,
    pendingTransition: () => null,
    pendingSceneId: () => null,
  );

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    return super.close();
  }
}
