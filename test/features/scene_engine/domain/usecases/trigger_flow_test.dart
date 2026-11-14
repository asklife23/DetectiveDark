import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

/// Triggers on the real write path: a tap and the trigger it completes end
/// up in one save. Hand-built content: a room with two clues.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const room = SceneDefinition(
    id: 'villa_exterior',
    titleKey: 'scene_room',
    visual: SceneVisual(placeholderStyle: 'plain'),
    hotspots: [
      HotspotDefinition(
        id: 'ashtray',
        rect: anyRect,
        labelKey: 'hotspot_ashtray',
        interactions: [
          InteractionRule(effects: [SetFlag('clue_a')]),
        ],
      ),
      HotspotDefinition(
        id: 'glass',
        rect: anyRect,
        labelKey: 'hotspot_glass',
        interactions: [
          InteractionRule(effects: [SetFlag('clue_b'), Say('say_glass')]),
        ],
      ),
    ],
  );

  const triggers = [
    TriggerDefinition(
      id: 'both_clues',
      when: AtLeast(2, [FlagSet('clue_a'), FlagSet('clue_b')]),
      effects: [Say('say_two_guests'), AddNote('obs_two_guests')],
    ),
  ];

  late GameHarness game;
  late List<GameProgress> saves;

  setUp(() {
    game = GameHarness(progressRepository: InMemoryProgressRepository());
    saves = [];
    game.progress.watch().listen(saves.add);
  });
  tearDown(() => game.dispose());

  Future<GameProgress> tap(GameProgress progress, String hotspotId) async {
    final result = await game.tapHotspot(
      scene: room,
      progress: progress,
      hotspotId: hotspotId,
      triggers: triggers,
    );
    await pumpEventQueue();
    return result.valueOrNull!.progress;
  }

  test('the second clue fires the trigger once, in the same save as the '
      'tap', () async {
    final afterFirst = await tap(newGame, 'ashtray');
    expect(afterFirst.firedTriggers, isEmpty);
    expect(saves, hasLength(1));

    final afterSecond = await tap(afterFirst, 'glass');

    // One save for the tap and the trigger together.
    expect(saves, hasLength(2));
    expect(saves.last, afterSecond);
    expect(afterSecond.firedTriggers, {'both_clues'});
    expect(afterSecond.hasNote('obs_two_guests'), isTrue);
    // The line of the tap comes first, then what the trigger adds.
    expect(game.events, const [
      DetectiveSaid('say_glass'),
      DetectiveSaid('say_two_guests'),
      NoteAdded('obs_two_guests', sceneId: 'villa_exterior'),
    ]);
  });

  test('it does not fire again on later taps', () async {
    var progress = await tap(newGame, 'ashtray');
    progress = await tap(progress, 'glass');
    game.events.clear();

    progress = await tap(progress, 'glass');
    progress = await tap(progress, 'ashtray');

    expect(game.events, const [DetectiveSaid('say_glass')]);
    expect(progress.notes, hasLength(1));
  });

  test('the order of the clues does not matter', () async {
    var progress = await tap(newGame, 'glass');
    expect(progress.firedTriggers, isEmpty);

    progress = await tap(progress, 'ashtray');

    expect(progress.firedTriggers, {'both_clues'});
  });

  test('a failed save stores nothing: neither the tap nor the fired '
      'mark, and no event', () async {
    final stored = newGame.withFlag('clue_a');
    final failing = GameHarness(
      progressRepository: FailingProgressRepository(stored: stored),
    );
    addTearDown(failing.dispose);

    final result = await failing.tapHotspot(
      scene: room,
      progress: stored,
      hotspotId: 'glass',
      triggers: triggers,
    );
    await pumpEventQueue();

    expect(result.failureOrNull, isNotNull);
    expect(failing.progress.current, stored);
    expect(failing.progress.current!.firedTriggers, isEmpty);
    expect(failing.events, isEmpty);
  });

  test('entering a scene evaluates triggers too', () async {
    final content = (await game.content.loadCase('case01')).valueOrNull!;
    // The real content has no triggers yet; this one is added by hand.
    final withTrigger = content.copyWithTriggers(const [
      TriggerDefinition(
        id: 'reached_the_statue',
        when: InScene('statue_closeup'),
        effects: [SetFlag('statue_seen')],
      ),
    ]);

    final entered = await game.enterScene(
      content: withTrigger,
      progress: newGame,
      sceneId: 'statue_closeup',
    );

    expect(entered.valueOrNull!.firedTriggers, {'reached_the_statue'});
    expect(entered.valueOrNull!.hasFlag('statue_seen'), isTrue);
    expect(saves, hasLength(1));
  });
}
