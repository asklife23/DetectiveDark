import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

/// An in-memory repository that remembers every save.
class _RecordingRepository extends InMemoryProgressRepository {
  final saved = <GameProgress>[];

  @override
  Future<Result<void>> save(GameProgress progress) {
    saved.add(progress);
    return super.save(progress);
  }
}

void main() {
  const context = EffectContext(
    sceneId: 'statue_closeup',
    hotspotId: 'statue_key',
    nowUtcMs: 1700000000000,
  );

  late GameEventBus bus;
  late List<GameEvent> events;

  setUp(() {
    bus = GameEventBus();
    events = [];
    bus.events.listen(events.add);
  });
  tearDown(() => bus.dispose());

  test('effects end up in one save, then their events are published', () async {
    final repository = _RecordingRepository();
    final pipeline = EffectPipeline(
      progressRepository: repository,
      eventBus: bus,
    );

    final result = await pipeline.run(
      progress: newGame,
      effects: const [GiveItem(brassKey), HideHotspot(), Say('found')],
      context: context,
    );
    await pumpEventQueue();

    final outcome = result.valueOrNull!;
    expect(repository.saved, [outcome.progress]);
    expect(outcome.progress.inventory, [brassKey]);
    expect(
      outcome.progress.isHotspotHidden('statue_closeup', 'statue_key'),
      isTrue,
    );
    expect(events, const [
      ItemObtained(
        brassKey,
        sceneId: 'statue_closeup',
        hotspotId: 'statue_key',
      ),
      DetectiveSaid('found'),
    ]);
    expect(outcome.events, events);
  });

  test('the prepare change and the effects share the one save', () async {
    final repository = _RecordingRepository();
    final pipeline = EffectPipeline(
      progressRepository: repository,
      eventBus: bus,
    );

    final result = await pipeline.run(
      progress: newGame,
      prepare: (progress) => progress.withVisited('statue_closeup'),
      effects: const [SetFlag('seen')],
      context: context,
    );

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.hasVisited('statue_closeup'), isTrue);
    expect(repository.saved.single.hasFlag('seen'), isTrue);
    expect(result.valueOrNull!.progress, repository.saved.single);
  });

  test('leading events come first, then the events of the effects', () async {
    final pipeline = EffectPipeline(
      progressRepository: InMemoryProgressRepository(),
      eventBus: bus,
    );

    await pipeline.run(
      progress: newGame,
      effects: const [Say('hello'), GiveItem(brassKey)],
      context: const EffectContext(sceneId: 'villa_hall', nowUtcMs: 1),
      leadingEvents: const [SceneEntered('villa_hall', isFirstVisit: true)],
    );
    await pumpEventQueue();

    expect(events, const [
      SceneEntered('villa_hall', isFirstVisit: true),
      DetectiveSaid('hello'),
      ItemObtained(brassKey, sceneId: 'villa_hall'),
    ]);
  });

  test('nothing changed: no save, but the outcome is still returned', () async {
    final repository = _RecordingRepository();
    final pipeline = EffectPipeline(
      progressRepository: repository,
      eventBus: bus,
    );

    final result = await pipeline.run(
      progress: newGame,
      effects: const [Inspect('statue_plaque')],
      context: context,
    );
    await pumpEventQueue();

    expect(repository.saved, isEmpty);
    expect(result.valueOrNull!.progress, same(newGame));
    expect(result.valueOrNull!.inspectionId, 'statue_plaque');
    expect(events, isEmpty);
  });

  test('a scene change is handed back to the caller', () async {
    final pipeline = EffectPipeline(
      progressRepository: InMemoryProgressRepository(),
      eventBus: bus,
    );

    final result = await pipeline.run(
      progress: newGame,
      effects: const [GoToScene('villa_hall')],
      context: context,
    );

    expect(result.valueOrNull!.navigation, const GoToScene('villa_hall'));
  });

  test('a failed save: Failed, and no event at all', () async {
    final repository = FailingProgressRepository();
    final pipeline = EffectPipeline(
      progressRepository: repository,
      eventBus: bus,
    );

    final result = await pipeline.run(
      progress: newGame,
      effects: const [GiveItem(brassKey), Say('found')],
      context: context,
      leadingEvents: const [SceneEntered('villa_hall', isFirstVisit: true)],
    );
    await pumpEventQueue();

    expect(result.failureOrNull, isA<StorageFailure>());
    expect(repository.saveCalls, 1);
    expect(events, isEmpty);
  });
}
