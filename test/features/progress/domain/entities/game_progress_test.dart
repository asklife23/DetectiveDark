import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  const letter = CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 10);

  test('a new game stands in its first scene with nothing collected', () {
    expect(newGame.currentSceneId, 'villa_exterior');
    expect(newGame.inventory, isEmpty);
    expect(newGame.notes, isEmpty);
    expect(newGame.unreadNoteCount, 0);
  });

  group('items', () {
    test('are kept in pick-up order', () {
      final progress = newGame.withItem('brass_key').withItem('torch');

      expect(progress.inventory, ['brass_key', 'torch']);
    });

    test('adding one twice changes nothing', () {
      final once = newGame.withItem('brass_key');

      expect(once.withItem('brass_key'), same(once));
    });

    test('removing keeps the order of the rest', () {
      final progress = newGame
          .withItem('a')
          .withItem('b')
          .withItem('c')
          .withoutItem('b');

      expect(progress.inventory, ['a', 'c']);
      expect(progress.withoutItem('missing'), same(progress));
    });
  });

  group('notes', () {
    test('start unread and count towards the badge', () {
      final progress = newGame.withNote(letter);

      expect(progress.hasNote('hall_letter'), isTrue);
      expect(progress.unreadNoteCount, 1);
    });

    test('adding the same note ID twice keeps the first one', () {
      final progress = newGame
          .withNote(letter)
          .withNote(
            const CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 99),
          );

      expect(progress.notes, [letter]);
    });

    test('marking as read clears the badge and is idempotent', () {
      final read = newGame.withNote(letter).withNoteRead('hall_letter');

      expect(read.notes.single.isRead, isTrue);
      expect(read.unreadNoteCount, 0);
      expect(read.withNoteRead('hall_letter'), same(read));
      expect(read.withNoteRead('unknown'), same(read));
    });
  });

  test('flags are set once', () {
    final progress = newGame.withFlag('front_door_open');

    expect(progress.hasFlag('front_door_open'), isTrue);
    expect(progress.withFlag('front_door_open'), same(progress));
  });

  test('hidden hotspots are stored per scene', () {
    final progress = newGame.withHiddenHotspot('statue_closeup', 'key');

    expect(progress.isHotspotHidden('statue_closeup', 'key'), isTrue);
    expect(progress.isHotspotHidden('villa_hall', 'key'), isFalse);
    expect(progress.hiddenHotspots, {'statue_closeup/key'});
    expect(progress.withHiddenHotspot('statue_closeup', 'key'), same(progress));
  });

  test('the scene stack is replaced as a whole', () {
    final progress = newGame.withSceneStack(['villa_exterior', 'statue']);

    expect(progress.currentSceneId, 'statue');
    expect(newGame.currentSceneId, 'villa_exterior');
  });

  test('visited scenes are remembered', () {
    final progress = newGame.withVisited('villa_exterior');

    expect(progress.hasVisited('villa_exterior'), isTrue);
    expect(progress.hasVisited('villa_hall'), isFalse);
    expect(progress.withVisited('villa_exterior'), same(progress));
  });

  test('chat entries are appended, even when repeated', () {
    const line = ChatLogEntry(textKey: 'door_locked', sentAtUtcMs: 1);
    final progress = newGame.withChatEntry(line).withChatEntry(line);

    expect(progress.chatLog, [line, line]);
  });

  test('changes never touch the original', () {
    newGame
        .withItem('brass_key')
        .withFlag('x')
        .withNote(letter)
        .withVisited('villa_exterior');

    expect(newGame.inventory, isEmpty);
    expect(newGame.flags, isEmpty);
    expect(newGame.notes, isEmpty);
    expect(newGame.visitedSceneIds, isEmpty);
  });

  test('two progresses with the same content are equal', () {
    expect(
      newGame.withItem('brass_key').withFlag('x'),
      newGame.withItem('brass_key').withFlag('x'),
    );
    expect(newGame.withItem('brass_key'), isNot(newGame));
  });
}
