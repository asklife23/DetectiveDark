// Runs on a real device or desktop window, not in the headless test runner:
//
//   flutter test integration_test/notebook_mouse_test.dart -d windows
//
// Drives the notebook (plan step 1.6) with MOUSE pointer events in the real
// Windows build: real engine, real window, real asset bundle.
import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/game_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mouse = PointerDeviceKind.mouse;
  const paper = 'Sheet of paper on the desk';
  final l10n = lookupAppLocalizations(const Locale('en'));

  tearDown(GetIt.instance.reset);

  testWidgets('the notebook works with the mouse', (tester) async {
    await setUpGameDependencies(assetBundle: rootBundle);
    await GetIt.instance<ProgressRepository>().save(
      const GameProgress(
        caseId: 'case01',
        chapterId: 'ch01',
        sceneStack: ['villa_exterior', 'villa_door_closeup', 'villa_hall'],
        flags: {'front_door_open'},
        visitedSceneIds: {'villa_exterior', 'villa_door_closeup', 'villa_hall'},
      ),
    );
    await tester.pumpGame();

    Finder badge() => find.descendant(
      of: find.byType(NotebookButton),
      matching: find.text('1'),
    );
    Future<void> click(Finder finder) async {
      await tester.tap(finder, kind: mouse);
      await tester.pumpFor();
    }

    // Click the paper: it leaves the scene and the badge appears.
    await click(find.bySemanticsLabel(paper));
    await tester.pumpFor(const Duration(seconds: 1));
    expect(find.bySemanticsLabel(paper), findsNothing);
    expect(badge(), findsOneWidget);

    // Notebook button opens the notebook on the Documents tab.
    await click(find.byTooltip(l10n.notebookTooltip));
    expect(find.byType(NotebookScreen), findsOneWidget);
    expect(find.text('Unsigned letter'), findsOneWidget);

    // Tabs.
    await click(find.text(l10n.notebookTabSuspects));
    expect(find.text(l10n.notebookEmptySuspects), findsOneWidget);
    await click(find.text(l10n.notebookTabObservations));
    expect(find.text(l10n.notebookEmptyObservations), findsOneWidget);
    await click(find.text(l10n.notebookTabDocuments));

    // Clicking the note shows its text and marks it as read.
    await click(find.text('Unsigned letter'));
    expect(find.textContaining('leave the door on the latch'), findsOneWidget);
    final notes = GetIt.instance<ProgressRepository>().current!.notes;
    expect(notes.single.isRead, isTrue);

    // A click on the page does not close the notebook...
    await click(find.textContaining('leave the door on the latch'));
    expect(find.byType(NotebookScreen), findsOneWidget);

    // ...a click outside the pages does, and the badge is gone.
    await tester.tapAt(const Offset(4, 200), kind: mouse);
    await tester.pumpFor();
    expect(find.byType(NotebookScreen), findsNothing);
    expect(badge(), findsNothing);

    // The close button works as well.
    await click(find.byTooltip(l10n.notebookTooltip));
    await click(find.byTooltip(l10n.closeTooltip));
    expect(find.byType(NotebookScreen), findsNothing);

    await tester.closeGame();
  });
}
