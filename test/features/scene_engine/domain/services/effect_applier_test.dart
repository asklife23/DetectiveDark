import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  const applier = EffectApplier();
  const now = 1700000000000;
  const atStatueKey = EffectContext(
    sceneId: 'statue_closeup',
    hotspotId: 'statue_key',
    nowUtcMs: now,
  );

  test('giveItem adds the item and announces where it came from', () {
    final outcome = applier.apply(newGame, const [
      GiveItem(brassKey),
    ], atStatueKey);

    expect(outcome.progress.inventory, [brassKey]);
    expect(outcome.events, const [
      ItemObtained(
        brassKey,
        sceneId: 'statue_closeup',
        hotspotId: 'statue_key',
      ),
    ]);
  });

  test('giveItem is idempotent: no second item, no second event', () {
    final outcome = applier.apply(newGame.withItem(brassKey), const [
      GiveItem(brassKey),
    ], atStatueKey);

    expect(outcome.progress.inventory, [brassKey]);
    expect(outcome.events, isEmpty);
  });

  test('consumeItem removes the item', () {
    final outcome = applier.apply(newGame.withItem(brassKey), const [
      ConsumeItem(brassKey),
    ], atStatueKey);

    expect(outcome.progress.inventory, isEmpty);
  });

  test('addNote stores the note unread with the current time', () {
    final outcome = applier.apply(newGame, const [
      AddNote('hall_letter'),
    ], atStatueKey);

    final note = outcome.progress.notes.single;
    expect(note.noteId, 'hall_letter');
    expect(note.addedAtUtcMs, now);
    expect(note.isRead, isFalse);
    expect(outcome.events.single, isA<NoteAdded>());
  });

  test('addNote is idempotent', () {
    final once = applier.apply(newGame, const [
      AddNote('hall_letter'),
    ], atStatueKey);
    final twice = applier.apply(once.progress, const [
      AddNote('hall_letter'),
    ], atStatueKey);

    expect(twice.progress, once.progress);
    expect(twice.events, isEmpty);
  });

  test('setFlag sets the flag', () {
    final outcome = applier.apply(newGame, const [
      SetFlag(doorOpenFlag),
    ], atStatueKey);

    expect(outcome.progress.hasFlag(doorOpenFlag), isTrue);
  });

  test('hideHotspot hides the tapped hotspot of this scene only', () {
    final outcome = applier.apply(newGame, const [HideHotspot()], atStatueKey);

    expect(
      outcome.progress.isHotspotHidden('statue_closeup', 'statue_key'),
      isTrue,
    );
    expect(
      outcome.progress.isHotspotHidden('villa_hall', 'statue_key'),
      isFalse,
    );
  });

  test('hideHotspot without a tapped hotspot changes nothing', () {
    final outcome = applier.apply(
      newGame,
      const [HideHotspot()],
      const EffectContext(sceneId: 'villa_exterior', nowUtcMs: now),
    );

    expect(outcome.progress, newGame);
  });

  test('say appends to the chat log and announces the message', () {
    final outcome = applier.apply(newGame, const [
      Say('door_locked'),
    ], atStatueKey);

    expect(outcome.progress.chatLog, const [
      ChatLogEntry(textKey: 'door_locked', sentAtUtcMs: now),
    ]);
    expect(outcome.events, const [DetectiveSaid('door_locked')]);
  });

  test('goToScene is returned as a navigation request, not applied', () {
    const effect = GoToScene('villa_hall');
    final outcome = applier.apply(newGame, const [effect], atStatueKey);

    expect(outcome.navigation, effect);
    expect(outcome.progress.sceneStack, newGame.sceneStack);
  });

  test('inspect is returned as the inspection to open', () {
    final outcome = applier.apply(newGame, const [
      Inspect('statue_plaque'),
    ], atStatueKey);

    expect(outcome.inspectionId, 'statue_plaque');
    expect(outcome.progress, newGame);
  });

  test('a used item is announced before the other events', () {
    final outcome = applier.apply(
      newGame.withItem(brassKey),
      const [SetFlag(doorOpenFlag), ConsumeItem(brassKey), Say('unlocked')],
      const EffectContext(
        sceneId: 'villa_door_closeup',
        hotspotId: 'lock',
        usedItemId: brassKey,
        nowUtcMs: now,
      ),
    );

    expect(outcome.events, const [
      ItemUsed(brassKey, hotspotId: 'lock'),
      DetectiveSaid('unlocked'),
    ]);
  });

  test('all effects of a rule end up in one new progress', () {
    final outcome = applier.apply(newGame, const [
      GiveItem(brassKey),
      HideHotspot(),
      SetFlag('statue_key_taken'),
      Say('found_key'),
    ], atStatueKey);

    final progress = outcome.progress;
    expect(progress.hasItem(brassKey), isTrue);
    expect(progress.isHotspotHidden('statue_closeup', 'statue_key'), isTrue);
    expect(progress.hasFlag('statue_key_taken'), isTrue);
    expect(progress.chatLog, hasLength(1));
    // The input is untouched: the applier never mutates.
    expect(newGame.inventory, isEmpty);
  });

  test('no effects: the same progress and nothing to do', () {
    final outcome = applier.apply(newGame, const [], atStatueKey);

    expect(outcome.progress, same(newGame));
    expect(outcome.events, isEmpty);
    expect(outcome.navigation, isNull);
    expect(outcome.inspectionId, isNull);
  });
}
