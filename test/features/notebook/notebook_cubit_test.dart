import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/game_app.dart';
import '../../helpers/game_harness.dart';
import '../../helpers/slice_fixtures.dart';

void main() {
  const letter = CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 1);
  late InMemoryProgressRepository progress;
  late GameEventBus bus;

  setUp(() {
    progress = InMemoryProgressRepository();
    bus = GameEventBus();
  });
  tearDown(() async {
    await progress.dispose();
    await bus.dispose();
  });

  group('MarkNoteRead', () {
    test('saves the note as read', () async {
      await progress.save(newGame.withNote(letter));

      final result = await MarkNoteRead(progress)('hall_letter');

      expect(result.isSuccess, isTrue);
      expect(progress.current!.notes.single.isRead, isTrue);
    });

    test('saves nothing for a read or unknown note', () async {
      await progress.save(newGame.withNote(letter.markedRead()));
      var saves = 0;
      progress.watch().skip(1).listen((_) => saves++);

      await MarkNoteRead(progress)('hall_letter');
      await MarkNoteRead(progress)('diary');
      await pumpEventQueue();

      expect(saves, 0);
    });

    test('does nothing before a game exists', () async {
      final result = await MarkNoteRead(progress)('hall_letter');

      expect(result.isSuccess, isTrue);
      expect(progress.current, isNull);
    });

    test('reports a failed save', () async {
      final failing = FailingProgressRepository(
        stored: newGame.withNote(letter),
      );

      final result = await MarkNoteRead(failing)('hall_letter');

      expect(result.failureOrNull, isA<StorageFailure>());
    });
  });

  group('NotebookCubit', () {
    Future<NotebookCubit> cubitWithLetter() async {
      final cubit = NotebookCubit(
        catalogRepository: AssetNoteCatalogRepository(
          ContentAssetSource(realContentBundle()),
        ),
        progressRepository: progress,
        markNoteRead: MarkNoteRead(progress),
        caseId: 'case01',
        eventBus: bus,
      );
      addTearDown(cubit.close);
      await cubit.load();
      await progress.save(newGame.withNote(letter));
      await pumpEventQueue();
      return cubit;
    }

    test('starts closed, on the documents tab, without notes', () async {
      final cubit = NotebookCubit(
        catalogRepository: AssetNoteCatalogRepository(
          ContentAssetSource(realContentBundle()),
        ),
        progressRepository: progress,
        markNoteRead: MarkNoteRead(progress),
        caseId: 'case01',
        eventBus: bus,
      );
      addTearDown(cubit.close);
      await cubit.load();

      expect(cubit.state, const NotebookState());
      expect(cubit.state.unreadCount, 0);
    });

    test('a collected note appears unread and counts on the badge', () async {
      final cubit = await cubitWithLetter();

      final entry = cubit.state.entries.single;
      expect(entry.note.titleKey, 'note_hall_letter_title');
      expect(entry.isRead, isFalse);
      expect(cubit.state.unreadCount, 1);
    });

    test('notes are listed under their category', () async {
      final cubit = await cubitWithLetter();
      expect(cubit.state.visibleEntries, hasLength(1));

      cubit.selectCategory(NoteCategory.person);
      expect(cubit.state.visibleEntries, isEmpty);

      cubit.selectCategory(NoteCategory.document);
      expect(cubit.state.visibleEntries, hasLength(1));
    });

    test(
      'selecting a note shows it and marks it read in the progress',
      () async {
        final cubit = await cubitWithLetter();

        await cubit.selectNote('hall_letter');
        await pumpEventQueue();

        expect(cubit.state.selectedEntry?.note.id, 'hall_letter');
        expect(cubit.state.selectedEntry?.isRead, isTrue);
        expect(cubit.state.unreadCount, 0);
        expect(progress.current!.unreadNoteCount, 0);
      },
    );

    test('a note the player does not have cannot be selected', () async {
      final cubit = await cubitWithLetter();

      await cubit.selectNote('diary');

      expect(cubit.state.selectedNoteId, isNull);
    });

    test('switching the tab clears the open note', () async {
      final cubit = await cubitWithLetter();
      await cubit.selectNote('hall_letter');

      cubit.selectCategory(NoteCategory.observation);

      expect(cubit.state.selectedNoteId, isNull);
    });

    test('open and close only change the visibility', () async {
      final cubit = await cubitWithLetter()
        ..openNotebook();
      expect(cubit.state.isOpen, isTrue);
      expect(cubit.state.entries, hasLength(1));

      cubit.closeNotebook();
      expect(cubit.state.isOpen, isFalse);
      expect(cubit.state.entries, hasLength(1));
    });
  });

  group('picking evidence (selection mode)', () {
    Future<NotebookCubit> cubitWithLetter() async {
      final cubit = NotebookCubit(
        catalogRepository: AssetNoteCatalogRepository(
          ContentAssetSource(realContentBundle()),
        ),
        progressRepository: progress,
        markNoteRead: MarkNoteRead(progress),
        caseId: 'case01',
        eventBus: bus,
      );
      addTearDown(cubit.close);
      await cubit.load();
      await progress.save(newGame.withNote(letter));
      await pumpEventQueue();
      return cubit;
    }

    test('openForSelection opens the notebook in selection mode', () async {
      final cubit = await cubitWithLetter()
        ..openForSelection();

      expect(cubit.state.isOpen, isTrue);
      expect(cubit.state.isSelecting, isTrue);
    });

    test('openNotebook opens it for reading', () async {
      final cubit = await cubitWithLetter()
        ..openForSelection()
        ..closeNotebook()
        ..openNotebook();

      expect(cubit.state.isOpen, isTrue);
      expect(cubit.state.isSelecting, isFalse);
    });

    test('closing leaves selection mode', () async {
      final cubit = await cubitWithLetter()
        ..openForSelection()
        ..closeNotebook();

      expect(cubit.state.isOpen, isFalse);
      expect(cubit.state.isSelecting, isFalse);
    });

    test(
      'tabs and notes can be browsed without leaving selection mode',
      () async {
        final cubit = await cubitWithLetter()
          ..openForSelection()
          ..selectCategory(NoteCategory.person)
          ..selectCategory(NoteCategory.document);
        await cubit.selectNote('hall_letter');

        expect(cubit.state.isSelecting, isTrue);
        expect(cubit.state.selectedNoteId, 'hall_letter');
      },
    );

    test('a note that is looked at while picking is marked read', () async {
      final cubit = await cubitWithLetter()
        ..openForSelection();

      await cubit.selectNote('hall_letter');
      await pumpEventQueue();

      expect(progress.current!.unreadNoteCount, 0);
    });
  });
}
