import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/trigger_runner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  const runner = TriggerRunner();
  const now = 1700000000000;

  /// Fires when both flags are set: says a line and adds a note.
  const bothClues = TriggerDefinition(
    id: 'both_clues',
    when: AllOf([FlagSet('clue_a'), FlagSet('clue_b')]),
    effects: [Say('say_it_adds_up'), AddNote('obs_it_adds_up')],
  );

  TriggerRun run(
    GameProgress progress,
    List<TriggerDefinition> triggers, {
    List<GameEvent> events = const [],
    TriggerRunner runner = runner,
  }) => runner.run(
    EffectOutcome(progress: progress, events: events),
    triggers,
    nowUtcMs: now,
  );

  test('nothing fires while the condition does not hold', () {
    final result = run(newGame.withFlag('clue_a'), const [bothClues]);

    expect(result.firedTriggerIds, isEmpty);
    expect(result.outcome.progress, newGame.withFlag('clue_a'));
    expect(result.outcome.events, isEmpty);
    expect(result.hitPassLimit, isFalse);
  });

  test('a trigger fires when its condition holds: effects, events and the '
      'fired mark', () {
    final result = run(newGame.withFlag('clue_a').withFlag('clue_b'), const [
      bothClues,
    ]);

    final progress = result.outcome.progress;
    expect(result.firedTriggerIds, ['both_clues']);
    expect(progress.hasFired('both_clues'), isTrue);
    expect(progress.notes.single.noteId, 'obs_it_adds_up');
    expect(progress.notes.single.addedAtUtcMs, now);
    expect(progress.chatLog.single.textKey, 'say_it_adds_up');
    expect(result.outcome.events, const [
      DetectiveSaid('say_it_adds_up'),
      NoteAdded('obs_it_adds_up', sceneId: 'villa_exterior'),
    ]);
  });

  test('a fired trigger never runs again', () {
    final first = run(newGame.withFlag('clue_a').withFlag('clue_b'), const [
      bothClues,
    ]);

    final second = run(first.outcome.progress, const [bothClues]);

    expect(second.firedTriggerIds, isEmpty);
    expect(second.outcome.progress, first.outcome.progress);
    expect(second.outcome.events, isEmpty);
  });

  test('the events of the triggers follow the events of the action', () {
    final result = run(
      newGame.withFlag('clue_a').withFlag('clue_b'),
      const [bothClues],
      events: const [DetectiveSaid('say_from_the_tap')],
    );

    expect(
      result.outcome.events.first,
      const DetectiveSaid('say_from_the_tap'),
    );
    expect(result.outcome.events, hasLength(3));
  });

  test('navigation and inspection of the action pass through untouched', () {
    final result = runner.run(
      EffectOutcome(
        progress: newGame.withFlag('clue_a').withFlag('clue_b'),
        navigation: const GoToScene('villa_hall'),
        inspectionId: 'statue_plaque',
      ),
      const [bothClues],
      nowUtcMs: now,
    );

    expect(result.outcome.navigation, const GoToScene('villa_hall'));
    expect(result.outcome.inspectionId, 'statue_plaque');
  });

  test('triggers fire in content order', () {
    const first = TriggerDefinition(
      id: 'first',
      when: FlagSet('go'),
      effects: [Say('one')],
    );
    const second = TriggerDefinition(
      id: 'second',
      when: FlagSet('go'),
      effects: [Say('two')],
    );

    final result = run(newGame.withFlag('go'), const [first, second]);

    expect(result.firedTriggerIds, ['first', 'second']);
    expect(result.outcome.events, const [
      DetectiveSaid('one'),
      DetectiveSaid('two'),
    ]);
  });

  group('chains', () {
    const opens = TriggerDefinition(
      id: 'opens',
      when: FlagSet('start'),
      effects: [SetFlag('middle')],
    );
    const follows = TriggerDefinition(
      id: 'follows',
      when: FlagSet('middle'),
      effects: [Say('chain_done')],
    );

    test('a trigger can make the condition of a later one true', () {
      final result = run(newGame.withFlag('start'), const [opens, follows]);

      expect(result.firedTriggerIds, ['opens', 'follows']);
      expect(result.outcome.events, const [DetectiveSaid('chain_done')]);
    });

    test('... and of an earlier one: the walk starts over until nothing '
        'fires', () {
      final result = run(newGame.withFlag('start'), const [follows, opens]);

      expect(result.firedTriggerIds, ['opens', 'follows']);
      expect(result.hitPassLimit, isFalse);
    });

    test('the walk stops at the pass limit and says so', () {
      // Each trigger enables the one written before it: one pass each.
      const chain = [
        TriggerDefinition(
          id: 'third',
          when: FlagSet('two'),
          effects: [SetFlag('three')],
        ),
        TriggerDefinition(
          id: 'second',
          when: FlagSet('one'),
          effects: [SetFlag('two')],
        ),
        TriggerDefinition(
          id: 'first',
          when: FlagSet('start'),
          effects: [SetFlag('one')],
        ),
      ];

      final limited = run(
        newGame.withFlag('start'),
        chain,
        runner: const TriggerRunner(maxPasses: 2),
      );
      final unlimited = run(newGame.withFlag('start'), chain);

      expect(limited.firedTriggerIds, ['first', 'second']);
      expect(limited.hitPassLimit, isTrue);
      expect(unlimited.firedTriggerIds, ['first', 'second', 'third']);
      expect(unlimited.hitPassLimit, isFalse);
    });
  });

  test('a trigger whose effects change nothing still counts as fired', () {
    const quiet = TriggerDefinition(
      id: 'quiet',
      when: HasNote('hall_letter'),
      effects: [AddNote('hall_letter')],
    );
    final progress = newGame.withNote(
      const CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 1),
    );

    final result = run(progress, const [quiet]);

    expect(result.firedTriggerIds, ['quiet']);
    expect(result.outcome.progress.hasFired('quiet'), isTrue);
    expect(result.outcome.events, isEmpty);
  });

  test('triggers see the scene on top of the stack', () {
    const arrival = TriggerDefinition(
      id: 'arrival',
      when: AllOf([InScene('market_square'), Visited('villa_hall')]),
      effects: [GiveItem('coin')],
    );
    final progress = newGame.withVisited('villa_hall').withSceneStack(const [
      'market_square',
    ]);

    final result = run(progress, const [arrival]);

    expect(result.outcome.events, const [
      ItemObtained('coin', sceneId: 'market_square'),
    ]);
  });
}
