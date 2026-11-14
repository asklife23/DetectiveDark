import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// The notebook on the real game screen (acceptance scenario steps 8–9).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  Finder badge() => find.descendant(
    of: find.byType(NotebookButton),
    matching: find.text('1'),
  );

  /// Starts the game in the hall with the door already open.
  Future<void> pumpGameInHall(WidgetTester tester) async {
    await GetIt.instance<ProgressRepository>().save(
      const GameProgress(
        caseId: 'case01',
        chapterId: 'ch01',
        sceneStack: ['villa_exterior', 'villa_door_closeup', 'villa_hall'],
        flags: {'front_door_open'},
        visitedSceneIds: {'villa_exterior', 'villa_door_closeup', 'villa_hall'},
      ),
    );
    tester.useLandscapePhone();
    await tester.pumpGame();
  }

  Future<void> takeLetter(WidgetTester tester) async {
    await pumpGameInHall(tester);
    await tester.tapHotspot('Sheet of paper on the desk');
    await tester.pumpFor(const Duration(seconds: 1));
  }

  testWidgets('the notebook starts empty and without a badge', (tester) async {
    await pumpGameInHall(tester);
    expect(badge(), findsNothing);

    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();

    expect(find.byType(NotebookScreen), findsOneWidget);
    expect(find.text(l10n.notebookEmptyDocuments), findsOneWidget);
    expect(find.text(l10n.notebookSelectHint), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('taking the paper removes it from the scene and shows a badge', (
    tester,
  ) async {
    await takeLetter(tester);

    expect(find.bySemanticsLabel('Sheet of paper on the desk'), findsNothing);
    expect(badge(), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('reading the note shows its text and clears the badge', (
    tester,
  ) async {
    await takeLetter(tester);
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();

    await tester.tap(find.text('Unsigned letter'));
    await tester.pumpFor();

    expect(find.textContaining('leave the door on the latch'), findsOneWidget);
    final notes = GetIt.instance<ProgressRepository>().current!.notes;
    expect(notes, [
      isA<CollectedNote>()
          .having((note) => note.noteId, 'noteId', 'hall_letter')
          .having((note) => note.isRead, 'isRead', isTrue),
    ]);

    await tester.tap(find.byTooltip(l10n.closeTooltip));
    await tester.pumpFor();
    expect(find.byType(NotebookScreen), findsNothing);
    expect(badge(), findsNothing);

    await tester.closeGame();
  });

  testWidgets('the tabs show their own notes and empty texts', (tester) async {
    await takeLetter(tester);
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();
    expect(find.text('Unsigned letter'), findsOneWidget);

    await tester.tap(find.text(l10n.notebookTabPeople));
    await tester.pumpFor();
    expect(find.text('Unsigned letter'), findsNothing);
    expect(find.text(l10n.notebookEmptyPeople), findsOneWidget);

    await tester.tap(find.text(l10n.notebookTabObservations));
    await tester.pumpFor();
    expect(find.text(l10n.notebookEmptyObservations), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('Back closes the notebook first and leaves the scene alone', (
    tester,
  ) async {
    await pumpGameInHall(tester);
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();

    await tester.binding.handlePopRoute();
    await tester.pumpFor();

    expect(find.byType(NotebookScreen), findsNothing);
    expect(find.bySemanticsLabel('Sheet of paper on the desk'), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('a tap outside the pages closes the notebook', (tester) async {
    await pumpGameInHall(tester);
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();

    await tester.tapAt(const Offset(4, 200));
    await tester.pumpFor();

    expect(find.byType(NotebookScreen), findsNothing);
    await tester.closeGame();
  });

  testWidgets('the scene cannot be tapped through the open notebook', (
    tester,
  ) async {
    await pumpGameInHall(tester);
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();

    await tester.tap(
      find.bySemanticsLabel('Sheet of paper on the desk'),
      warnIfMissed: false,
    );
    await tester.pumpFor();

    expect(GetIt.instance<ProgressRepository>().current!.notes, isEmpty);
    await tester.closeGame();
  });
}
