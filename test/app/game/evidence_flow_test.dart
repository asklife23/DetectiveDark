import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_bar.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/dialogue_driver.dart';
import '../../helpers/game_app.dart';

/// Giving items and showing evidence on the real game screen (acceptance
/// scenario steps 17 and 18).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  const pharmacist = 'Figure at the pharmacy window';
  const cafeOwner = 'Figure outside the café';

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  ProgressRepository progress() => GetIt.instance<ProgressRepository>();

  /// Starts in the market square with the bottle and the (read) letter.
  Future<void> pumpAtMarket(WidgetTester tester) async {
    await progress().save(
      const GameProgress(
        caseId: 'case01',
        chapterId: 'ch01',
        sceneStack: ['market_square'],
        visitedSceneIds: {'villa_exterior', 'market_square'},
        inventory: ['pill_bottle'],
        notes: [
          CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 1, isRead: true),
        ],
      ),
    );
    tester.useLandscapePhone();
    await tester.pumpGame();
  }

  Future<void> open(WidgetTester tester, String figure) async {
    await tester.tapHotspot(figure);
    await tester.readDialogue();
  }

  bool isSelected(WidgetTester tester, Finder item) =>
      tester.getSemantics(item).flagsCollection.isSelected.toBoolOrNull()!;

  group('17. giving an item', () {
    testWidgets('with the panel open, one tap on the bottle in the item '
        'panel hands it over: the pharmacist answers, the bottle is gone, '
        'his file gains a line', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);
      await tester.askDialogue('Ask about the pills');
      await tester.readDialogue();

      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();

      // A single tap shows the item; nothing was selected first.
      expect(
        tester.dialogueSays('...This is my hand on the label'),
        findsOneWidget,
      );
      expect(tester.itemSlot('Pill bottle'), findsNothing);
      final saved = progress().current!;
      expect(saved.hasItem('pill_bottle'), isFalse);
      expect(
        saved.hasNoteEntry('person_pharmacist', 'pills_prescribed'),
        isTrue,
      );

      await tester.readDialogue();

      // "Ask about the pills" was asked before the bottle left: it stays
      // and can be read again. The hand-over is listed as asked.
      expect(tester.dialogueQuestion('Ask about the pills'), findsOneWidget);
      expect(
        tester.dialogueQuestion('Hand over the pill bottle'),
        findsOneWidget,
      );
      expect(tester.dialogueAskedMarks, findsNWidgets(2));
      expect(tester.dialogueNewTags, findsNWidgets(2));

      await tester.askDialogue('Ask about the pills');
      expect(tester.dialogueSays('Brown glass, no label'), findsOneWidget);
      await tester.readDialogue();
      await tester.askDialogue('Hand over the pill bottle');
      expect(
        tester.dialogueSays('...This is my hand on the label'),
        findsOneWidget,
      );

      await tester.closeGame();
    });

    testWidgets('now the pharmacist shows four questions without '
        'scrolling', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);
      await tester.askDialogue('Ask about the pills');
      await tester.readDialogue();
      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();
      await tester.readDialogue();

      final list = tester.getRect(
        find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
      );
      for (final text in [
        'Ask about Ashgrove Villa',
        'Ask about last night',
        'Ask about the pills',
        'Hand over the pill bottle',
      ]) {
        final row = tester.getRect(tester.dialogueQuestion(text));
        expect(row.bottom, lessThanOrEqualTo(list.bottom), reason: text);
      }

      await tester.closeGame();
    });

    testWidgets('an item nobody asks for gets a shrug and stays with the '
        'player', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);
      final before = progress().current;

      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();

      expect(tester.dialogueSays('Means nothing to me'), findsOneWidget);
      expect(tester.itemSlot('Pill bottle'), findsOneWidget);
      expect(isSelected(tester, tester.itemSlot('Pill bottle')), isFalse);
      expect(progress().current, same(before));

      await tester.closeGame();
    });

    testWidgets('a tap on an item while the character speaks does '
        'nothing', (tester) async {
      await pumpAtMarket(tester);
      await tester.tapHotspot(pharmacist);
      expect(tester.dialogueSays("We're closed"), findsOneWidget);

      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();

      expect(tester.dialogueSays("We're closed"), findsOneWidget);
      expect(progress().current!.hasItem('pill_bottle'), isTrue);

      await tester.closeGame();
    });

    testWidgets('from the scene: with the bottle selected, a tap on the '
        'pharmacist opens the panel, he greets and then takes the bottle', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();
      expect(isSelected(tester, tester.itemSlot('Pill bottle')), isTrue);

      await tester.tapHotspot(pharmacist);

      // No "That won't do anything here": the conversation opens.
      expect(find.byType(DialoguePanel), findsOneWidget);
      expect(tester.dialogueSays("We're closed"), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ChatBar),
          matching: find.bySemanticsLabel(RegExp("^That won't do anything")),
        ),
        findsNothing,
      );

      await tester.tapDialogue();
      await tester.tapDialogue();
      await tester.pumpFor();

      expect(
        tester.dialogueSays('...This is my hand on the label'),
        findsOneWidget,
      );
      expect(tester.itemSlot('Pill bottle'), findsNothing);

      await tester.closeGame();
    });

    testWidgets('with the panel closed a tap on an item selects it as '
        'before', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);
      await tester.closeDialogue();

      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();

      expect(isSelected(tester, tester.itemSlot('Pill bottle')), isTrue);
      expect(progress().current!.hasItem('pill_bottle'), isTrue);

      await tester.closeGame();
    });
  });

  group('18. showing a note', () {
    Future<void> showLetter(WidgetTester tester) async {
      await tester.tap(find.text(l10n.dialogueShowEvidence));
      await tester.pumpFor();
      expect(find.byType(NotebookScreen), findsOneWidget);
      await tester.tap(find.text('Unsigned letter'));
      await tester.pumpFor();
      await tester.tap(find.text(l10n.notebookShowButton));
      await tester.pumpFor();
    }

    testWidgets('"Show evidence" opens the notebook to pick a note; the '
        'café owner recognises the letter', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);

      await tester.tap(find.text(l10n.dialogueShowEvidence));
      await tester.pumpFor();

      // The notebook is in selection mode: a hint, and a Show button once
      // a note is open.
      expect(find.byType(NotebookScreen), findsOneWidget);
      expect(find.text(l10n.notebookPickEvidenceHint), findsOneWidget);
      expect(find.text(l10n.notebookShowButton), findsNothing);
      await tester.tap(find.text('Unsigned letter'));
      await tester.pumpFor();
      expect(find.text(l10n.notebookShowButton), findsOneWidget);

      await tester.tap(find.text(l10n.notebookShowButton));
      await tester.pumpFor();

      // The notebook closed by itself and the character reacts.
      expect(find.byType(NotebookScreen), findsNothing);
      expect(tester.dialogueSays('Let me see'), findsOneWidget);
      await tester.readDialogue();
      expect(
        tester.dialogueQuestion('Show the unsigned letter'),
        findsOneWidget,
      );
      expect(tester.dialogueAskedMarks, findsOneWidget);
      final saved = progress().current!;
      expect(saved.hasAsked('cafe_owner', 'show_letter'), isTrue);
      expect(
        saved.hasNoteEntry('person_cafe_owner', 'recognised_paper'),
        isTrue,
      );
      expect(saved.hasNote('hall_letter'), isTrue);

      await tester.closeGame();
    });

    testWidgets('the pharmacist has nothing to say about it: his shrug, '
        'nothing is saved', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);
      final before = progress().current;

      await showLetter(tester);

      expect(
        tester.dialogueSays("I couldn't tell you anything"),
        findsOneWidget,
      );
      await tester.readDialogue();
      expect(tester.dialogueQuestion('Show the unsigned letter'), findsNothing);
      expect(progress().current, same(before));

      await tester.closeGame();
    });

    testWidgets('the notebook button of the HUD opens the notebook in '
        'selection mode too, while the panel is open', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);

      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      await tester.tap(find.text('Unsigned letter'));
      await tester.pumpFor();

      expect(find.text(l10n.notebookShowButton), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('without a conversation the notebook has no Show button', (
      tester,
    ) async {
      await pumpAtMarket(tester);

      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      await tester.tap(find.text('Unsigned letter'));
      await tester.pumpFor();

      expect(find.text(l10n.notebookShowButton), findsNothing);
      expect(find.text(l10n.notebookPickEvidenceHint), findsNothing);

      await tester.closeGame();
    });

    testWidgets('Back in the selection notebook returns to the panel and '
        'shows nothing', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);
      await tester.tap(find.text(l10n.dialogueShowEvidence));
      await tester.pumpFor();
      await tester.tap(find.text('Unsigned letter'));
      await tester.pumpFor();

      await tester.binding.handlePopRoute();
      await tester.pumpFor();

      expect(find.byType(NotebookScreen), findsNothing);
      expect(find.byType(DialoguePanel), findsOneWidget);
      expect(tester.dialogueIsChoosing, isTrue);
      expect(progress().current!.askedTopics, isEmpty);

      // The next time the notebook is opened for reading again.
      await tester.closeDialogue();
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      expect(find.text(l10n.notebookShowButton), findsNothing);

      await tester.closeGame();
    });

    testWidgets('"Show evidence" is not offered while the character '
        'speaks', (tester) async {
      await pumpAtMarket(tester);
      await tester.tapHotspot(cafeOwner);

      expect(tester.dialogueSays("Kitchen's closed"), findsOneWidget);
      expect(find.text(l10n.dialogueShowEvidence), findsNothing);

      await tester.readDialogue();
      expect(find.text(l10n.dialogueShowEvidence), findsOneWidget);

      await tester.closeGame();
    });
  });
}
