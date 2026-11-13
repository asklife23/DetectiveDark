import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/start_game.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/tap_hotspot.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clock that always shows the same moment.
class FixedClock implements Clock {
  const FixedClock([this.millis = 1700000000000]);

  final int millis;

  @override
  DateTime nowUtc() => DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

/// A progress repository whose saves fail, to test the failure paths.
class FailingProgressRepository implements ProgressRepository {
  FailingProgressRepository({this.stored});

  final GameProgress? stored;
  int saveCalls = 0;

  @override
  GameProgress? get current => stored;

  @override
  Future<Result<GameProgress?>> load() async => Success(stored);

  @override
  Stream<GameProgress> watch() => const Stream.empty();

  @override
  Future<Result<void>> save(GameProgress progress) async {
    saveCalls++;
    return const Failed(StorageFailure('disk full'));
  }
}

/// The game logic wired together as in the app, but without any UI: real
/// JSON content from the asset bundle, progress in memory, a fixed clock.
class GameHarness {
  GameHarness({
    ProgressRepository? progressRepository,
    SceneContentRepository? contentRepository,
  }) : progress = progressRepository ?? InMemoryProgressRepository(),
       content =
           contentRepository ??
           AssetSceneContentRepository(ContentAssetSource(rootBundle)) {
    bus.events.listen(events.add);
  }

  static const clock = FixedClock();

  final ProgressRepository progress;
  final SceneContentRepository content;
  final bus = GameEventBus();

  /// Every event published so far.
  final events = <GameEvent>[];

  late final enterScene = EnterScene(
    progressRepository: progress,
    eventBus: bus,
    clock: clock,
  );
  late final startGame = StartGame(
    contentRepository: content,
    progressRepository: progress,
    enterScene: enterScene,
  );
  late final tapHotspot = TapHotspot(
    progressRepository: progress,
    eventBus: bus,
    clock: clock,
  );

  SceneBloc createBloc() => SceneBloc(
    caseId: ContentPaths.defaultCaseId,
    startGame: startGame,
    enterScene: enterScene,
    tapHotspot: tapHotspot,
    progressRepository: progress,
  );

  Future<void> dispose() => bus.dispose();
}

/// Drives a [SceneBloc] the way the UI does, for tests without widgets.
extension SceneBlocDriver on SceneBloc {
  /// Lets every queued event and stream callback run.
  Future<void> settle() => pumpEventQueue();

  Future<void> start() async {
    add(const SceneStarted());
    await settle();
  }

  /// Taps a hotspot and plays a started transition to its end.
  Future<void> tap(String hotspotId, {String? usingItemId}) async {
    add(HotspotTapped(hotspotId, usingItemId: usingItemId));
    await settle();
    await finishTransition();
  }

  /// Presses Back and plays a started transition to its end.
  Future<void> back() async {
    add(const BackPressed());
    await settle();
    await finishTransition();
  }

  /// What the transition overlay does: report black, then report done.
  Future<void> finishTransition() async {
    if (state.transitionPhase == TransitionPhase.covering) {
      add(const TransitionCovered());
      await settle();
    }
    if (state.transitionPhase == TransitionPhase.revealing) {
      add(const TransitionFinished());
      await settle();
    }
  }

  String get sceneId => state.scene!.id;

  List<String> get hotspotIds => [
    for (final hotspot in state.visibleHotspots) hotspot.id,
  ];
}
