import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
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

  group('say with first / then', () {
    const line = Say('statue_long', repeatKey: 'statue_short');

    test('the first time says the long line and remembers it', () {
      final outcome = applier.apply(newGame, const [line], atStatueKey);

      expect(outcome.events, const [DetectiveSaid('statue_long')]);
      expect(outcome.progress.chatLog.single.textKey, 'statue_long');
      expect(outcome.progress.spokenLines, {'statue_long'});
    });

    test('every later time says the short line', () {
      final once = applier.apply(newGame, const [line], atStatueKey).progress;

      final again = applier.apply(once, const [line], atStatueKey);
      final third = applier.apply(again.progress, const [line], atStatueKey);

      expect(again.events, const [DetectiveSaid('statue_short')]);
      expect(third.events, const [DetectiveSaid('statue_short')]);
      expect(third.progress.chatLog.map((entry) => entry.textKey), [
        'statue_long',
        'statue_short',
        'statue_short',
      ]);
      expect(third.progress.spokenLines, {'statue_long'});
    });

    test('twice in one rule: long, then short', () {
      final outcome = applier.apply(newGame, const [line, line], atStatueKey);

      expect(outcome.events, const [
        DetectiveSaid('statue_long'),
        DetectiveSaid('statue_short'),
      ]);
    });

    test('a plain line never touches spokenLines', () {
      final outcome = applier.apply(newGame, const [
        Say('statue_long'),
        Say('statue_long'),
      ], atStatueKey);

      expect(outcome.progress.spokenLines, isEmpty);
      expect(outcome.events, const [
        DetectiveSaid('statue_long'),
        DetectiveSaid('statue_long'),
      ]);
    });
  });

  group('addNoteEntry', () {
    const knowsVilla = AddNoteEntry(
      noteId: 'person_pharmacist',
      entryId: 'knows_villa',
    );
    const pills = AddNoteEntry(
      noteId: 'person_pharmacist',
      entryId: 'pills_prescribed',
    );

    test('without the note: the note is added with the line, as a new '
        'note', () {
      final outcome = applier.apply(newGame, const [knowsVilla], atStatueKey);

      final note = outcome.progress.notes.single;
      expect(note.noteId, 'person_pharmacist');
      expect(note.isRead, isFalse);
      expect(note.entries, const [
        CollectedNoteEntry(entryId: 'knows_villa', addedAtUtcMs: now),
      ]);
      expect(outcome.events, const [
        NoteAdded(
          'person_pharmacist',
          sceneId: 'statue_closeup',
          hotspotId: 'statue_key',
        ),
      ]);
    });

    test('with the note: the line is added, the note is unread again and '
        'NoteUpdated is announced', () {
      final read = applier
          .apply(newGame, const [knowsVilla], atStatueKey)
          .progress
          .withNoteRead('person_pharmacist');

      final outcome = applier.apply(read, const [pills], atStatueKey);

      final note = outcome.progress.notes.single;
      expect(note.isRead, isFalse);
      expect(note.entries.map((entry) => entry.entryId), [
        'knows_villa',
        'pills_prescribed',
      ]);
      expect(outcome.events, const [
        NoteUpdated('person_pharmacist', entryId: 'pills_prescribed'),
      ]);
    });

    test('a line that is already there changes nothing', () {
      final once = applier
          .apply(newGame, const [knowsVilla], atStatueKey)
          .progress
          .withNoteRead('person_pharmacist');

      final again = applier.apply(once, const [knowsVilla], atStatueKey);

      expect(again.progress, same(once));
      expect(again.events, isEmpty);
    });

    test('a note added by addNote gains its first line as an update', () {
      final outcome = applier.apply(newGame, const [
        AddNote('person_pharmacist'),
        knowsVilla,
      ], atStatueKey);

      expect(outcome.progress.notes.single.entries, hasLength(1));
      expect(outcome.events.map((event) => event.runtimeType), [
        NoteAdded,
        NoteUpdated,
      ]);
    });

    test('two lines in one rule keep their order', () {
      final outcome = applier.apply(newGame, const [
        pills,
        knowsVilla,
      ], atStatueKey);

      expect(
        outcome.progress.notes.single.entries.map((entry) => entry.entryId),
        ['pills_prescribed', 'knows_villa'],
      );
    });
  });
}
