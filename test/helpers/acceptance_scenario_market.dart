import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dialogue_driver.dart';
import 'game_app.dart';

/// Steps 12–20 of the acceptance scenario (plan.md, "the market demo"):
/// the pill bottle, the signpost, the market square, two conversations,
/// handing over an item, showing a note, and the way back.
///
/// Continues where steps 1–11 end: at the close-up of the open front door,
/// with the letter read. Like the first half, it only taps what a player
/// can see and only checks what a player can see.
Future<void> playMarketSteps(
  WidgetTester tester, {
  required PointerDeviceKind pointer,
}) async {
  final l10n = lookupAppLocalizations(const Locale('en'));

  // Hotspots, by their accessibility label.
  final doorway = find.bySemanticsLabel('Open doorway');
  final door = find.bySemanticsLabel('Front door');
  final statue = find.bySemanticsLabel('Garden statue');
  final statueBody = find.bySemanticsLabel('Statue');
  final bottle = find.bySemanticsLabel('Small bottle on the desk');
  final sign = find.bySemanticsLabel('Signpost to the market');
  final road = find.bySemanticsLabel('Road back to the villa');
  final pharmacist = find.bySemanticsLabel('Figure at the pharmacy window');
  final cafeOwner = find.bySemanticsLabel('Figure outside the café');

  // Interface.
  final back = find.byTooltip(l10n.backTooltip);
  final notebookButton = find.byTooltip(l10n.notebookTooltip);
  final panel = find.byType(DialoguePanel);
  final bottleInPanel = tester.itemSlot('Pill bottle');
  final bottleInScene = find.byWidgetPredicate(
    (widget) =>
        widget is PlaceholderArt &&
        widget.style == PlaceholderStyles.spritePillBottle,
  );
  Finder notebookBadge(int unread) => find.descendant(
    of: find.byType(NotebookButton),
    matching: find.text('$unread'),
  );

  /// The line the detective is saying right now (the open message bar).
  Finder says(String start) => find.bySemanticsLabel(RegExp('^$start'));

  Future<void> tap(Finder finder) async {
    await tester.tap(finder, kind: pointer);
    await tester.pumpFor();
  }

  /// Taps the panel until the character says the line starting with
  /// [start]: one tap completes the line being typed, the next moves on.
  Future<void> advanceTo(String start) async {
    for (var taps = 0; taps < 2; taps++) {
      if (tester.dialogueSays(start).evaluate().isNotEmpty) return;
      await tester.tapDialogue(pointer: pointer);
    }
    expect(tester.dialogueSays(start), findsOneWidget);
  }

  Future<void> read() => tester.readDialogue(pointer: pointer);
  Future<void> ask(String question) =>
      tester.askDialogue(question, pointer: pointer);

  /// "Show evidence" → the notebook in selection mode → the letter → Show.
  Future<void> showLetter() async {
    await tap(find.text(l10n.dialogueShowEvidence));
    expect(find.byType(NotebookScreen), findsOneWidget);
    // The notebook remembers the note that was read last. The letter was
    // read in step 9, so it is usually on the page already, with its Show
    // button.
    final show = find.text(l10n.notebookShowButton);
    if (show.evaluate().isEmpty) await tap(find.text('Unsigned letter').first);
    await tap(show);
    // The notebook closes by itself; the character reacts in the panel.
    expect(find.byType(NotebookScreen), findsNothing);
  }

  // 12. The pill bottle in the hall flies into the item panel. Back in
  //     front of the villa a signpost stands there now (the letter was
  //     taken), with its word drawn on it.
  await tap(doorway);
  expect(bottle, findsOneWidget);
  expect(bottleInScene, findsOneWidget);
  await tap(bottle);
  await tester.pumpFor(const Duration(seconds: 1));
  expect(bottle, findsNothing);
  expect(bottleInScene, findsNothing);
  expect(bottleInPanel, findsOneWidget);
  expect(says('A pill bottle'), findsOneWidget);
  await tap(back);
  await tap(back);
  expect(door, findsOneWidget);
  expect(sign, findsOneWidget);
  expect(find.text('MARKET'), findsOneWidget);

  // 13. The signpost leads to the market square: a main location, so no
  //     Back button. Two figures wait there.
  await tap(sign);
  expect(says('The market square'), findsOneWidget);
  expect(back, findsNothing);
  expect(pharmacist, findsOneWidget);
  expect(cafeOwner, findsOneWidget);
  expect(road, findsOneWidget);

  // 14. A tap on the café owner opens the panel directly: two questions,
  //     both new. The answer advances tap by tap; then the question is
  //     marked as asked.
  await tap(cafeOwner);
  expect(panel, findsOneWidget);
  expect(tester.dialogueSays("Kitchen's closed"), findsOneWidget);
  await read();
  expect(tester.dialogueQuestion('Ask about Ashgrove Villa'), findsOneWidget);
  expect(tester.dialogueQuestion('Ask about the pharmacist'), findsOneWidget);
  expect(tester.dialogueQuestion('Show the unsigned letter'), findsNothing);
  expect(tester.dialogueNewTags, findsNWidgets(2));
  expect(tester.dialogueAskedMarks, findsNothing);
  await ask('Ask about Ashgrove Villa');
  expect(tester.dialogueSays('Empty? I carried a tray'), findsOneWidget);
  await advanceTo('Somebody up there likes the coffee strong');
  await read();
  expect(tester.dialogueNewTags, findsOneWidget);
  expect(tester.dialogueAskedMarks, findsOneWidget);
  // His file is new in the notebook.
  expect(notebookBadge(1), findsOneWidget);
  await tester.closeDialogue(pointer: pointer);
  expect(panel, findsNothing);

  // 15. The pharmacist has three questions: two of his own and, because
  //     the bottle is in the pocket, the pills. Asking about the villa
  //     adds a line to his file; and now that both were asked, the trigger
  //     fires: the detective speaks and an observation is written down.
  await tap(pharmacist);
  expect(tester.dialogueSays("We're closed"), findsOneWidget);
  await read();
  expect(tester.dialogueQuestion('Ask about Ashgrove Villa'), findsOneWidget);
  expect(tester.dialogueQuestion('Ask about last night'), findsOneWidget);
  expect(tester.dialogueQuestion('Ask about the pills'), findsOneWidget);
  expect(tester.dialogueNewTags, findsNWidgets(3));
  await ask('Ask about Ashgrove Villa');
  await tester.pumpFor();
  expect(tester.dialogueSays('The Ashgrove place?'), findsOneWidget);
  expect(says('Empty since spring, says one'), findsOneWidget);
  // The café owner's file, the pharmacist's file and the observation.
  expect(notebookBadge(3), findsOneWidget);
  await read();

  // 16. The pills: the answer in the panel, the detective's thought in
  //     the message bar below it.
  await ask('Ask about the pills');
  await tester.pumpFor();
  expect(tester.dialogueSays('Brown glass, no label'), findsOneWidget);
  expect(says('He looked at that bottle'), findsOneWidget);
  await read();

  // 17. With the panel open, one tap on the bottle hands it over: the
  //     pharmacist answers and the bottle leaves the item panel. "Ask
  //     about the pills" stays and can be read again; the hand-over is
  //     listed as asked.
  await tap(bottleInPanel);
  expect(
    tester.dialogueSays('...This is my hand on the label'),
    findsOneWidget,
  );
  expect(bottleInPanel, findsNothing);
  await read();
  expect(tester.dialogueQuestion('Ask about the pills'), findsOneWidget);
  expect(
    tester.dialogueQuestion('Hand over the pill bottle'),
    findsOneWidget,
  );
  expect(tester.dialogueAskedMarks, findsNWidgets(3));
  expect(tester.dialogueNewTags, findsOneWidget);
  await ask('Ask about the pills');
  expect(tester.dialogueSays('Brown glass, no label'), findsOneWidget);
  await read();

  // 18. "Show evidence": the pharmacist only shrugs at the letter, the
  //     café owner recognises the paper.
  await showLetter();
  expect(tester.dialogueSays("I couldn't tell you anything"), findsOneWidget);
  await read();
  expect(tester.dialogueQuestion('Show the unsigned letter'), findsNothing);
  await tester.closeDialogue(pointer: pointer);
  await tap(cafeOwner);
  expect(tester.dialogueSays('Still here?'), findsOneWidget);
  await read();
  await showLetter();
  expect(tester.dialogueSays('Let me see'), findsOneWidget);
  await read();
  expect(tester.dialogueQuestion('Show the unsigned letter'), findsOneWidget);
  await tester.closeDialogue(pointer: pointer);

  // 19. The pharmacist greets a second visit with his other line. The
  //     trigger has not fired again: one observation, and his file holds
  //     both statements.
  await tap(pharmacist);
  expect(tester.dialogueSays('You again. Ask, then.'), findsOneWidget);
  await read();
  await tester.closeDialogue(pointer: pointer);
  await tap(notebookButton);
  await tap(find.text(l10n.notebookTabObservations));
  expect(find.text('Two stories about the villa'), findsOneWidget);
  await tap(find.text(l10n.notebookTabPeople));
  await tap(find.text('The pharmacist'));
  expect(
    find.textContaining('has stood empty since spring'),
    findsOneWidget,
  );
  expect(
    find.textContaining('Made up the sleeping powder himself'),
    findsOneWidget,
  );
  await tap(find.byTooltip(l10n.closeTooltip));
  expect(find.byType(NotebookScreen), findsNothing);

  // 20. The road leads back to the villa. The statue gets the long line
  //     once, then the short one.
  await tap(road);
  expect(door, findsOneWidget);
  expect(back, findsNothing);
  await tap(statue);
  await tap(statueBody);
  expect(says('Marble, cold and patient'), findsOneWidget);
  await tap(statueBody);
  expect(says('Still marble'), findsOneWidget);
}
