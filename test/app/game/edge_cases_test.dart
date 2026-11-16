import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/dialogue_driver.dart';
import '../../helpers/game_app.dart';

/// The rough handling a real player gives the game: the manual checklists
/// of plan steps 1.8 and 1.20, as far as a test can press the buttons.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  List<String> sceneStack() =>
      GetIt.instance<ProgressRepository>().current!.sceneStack;

  Finder keySlot() => find.descendant(
    of: find.byType(ItemSidebar),
    matching: find.bySemanticsLabel('Brass key'),
  );

  testWidgets('a quick double tap on a door enters the close-up once', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    final door = find.bySemanticsLabel('Front door');
    await tester.tap(door);
    await tester.tap(door, warnIfMissed: false);
    await tester.pumpFor();

    expect(sceneStack(), ['villa_exterior', 'villa_door_closeup']);
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);
    await tester.closeGame();
  });

  testWidgets('a quick double tap on a pickup gives the item once', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Garden statue');

    final key = find.bySemanticsLabel("Something behind the statue's ear");
    await tester.tap(key);
    await tester.tap(key, warnIfMissed: false);
    await tester.pumpFor(const Duration(seconds: 1));

    final progress = GetIt.instance<ProgressRepository>().current!;
    expect(progress.inventory, ['brass_key']);
    expect(keySlot(), findsOneWidget);
    await tester.closeGame();
  });

  testWidgets('a tap during a scene transition is ignored', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    await tester.tap(find.bySemanticsLabel('Front door'));
    // Half way into the fade to black.
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.bySemanticsLabel('Garden statue'),
      warnIfMissed: false,
    );
    await tester.pumpFor();

    expect(sceneStack(), ['villa_exterior', 'villa_door_closeup']);
    await tester.closeGame();
  });

  testWidgets('Back keeps the selected item selected', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Garden statue');
    await tester.tapHotspot("Something behind the statue's ear");
    await tester.pumpFor(const Duration(seconds: 1));
    await tester.tap(keySlot());
    await tester.pumpFor();

    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();

    // The player can carry the selected key to where it belongs.
    expect(sceneStack(), ['villa_exterior']);
    final isSelected = tester
        .getSemantics(keySlot())
        .flagsCollection
        .isSelected
        .toBoolOrNull();
    expect(isSelected, isTrue);
    await tester.closeGame();
  });

  testWidgets('the system back button in a main scene warns before leaving', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    await tester.binding.handlePopRoute();
    await tester.pumpFor();

    expect(find.text(l10n.exitHint), findsOneWidget);
    expect(find.bySemanticsLabel('Front door'), findsOneWidget);
    await tester.pumpFor(const Duration(seconds: 3));
    await tester.closeGame();
  });

  testWidgets('the game is unchanged after going to the background and back', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Front door');
    final before = GetIt.instance<ProgressRepository>().current;

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    await tester.pumpFor();

    expect(GetIt.instance<ProgressRepository>().current, before);
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);
    // And it still reacts.
    await tester.tapHotspot('Door lock');
    expect(
      find.bySemanticsLabel('Locked. Of course it is.'),
      findsOneWidget,
    );
    await tester.closeGame();
  });

  group('in a conversation', () {
    const pharmacist = 'Figure at the pharmacy window';
    const cafeOwner = 'Figure outside the café';

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

    testWidgets('a quick double tap while a line is typed completes it and '
        'moves on once: no line is skipped', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);
      await tester.askDialogue('Ask about Ashgrove Villa');
      expect(tester.dialogueSays('Empty? I carried a tray'), findsOneWidget);

      // Two taps with no frame in between.
      final center = tester.getCenter(tester.dialoguePanel);
      await tester.tapAt(center);
      await tester.tapAt(center);
      await tester.pumpFor(const Duration(milliseconds: 100));

      // The second of the two lines, not the question list.
      expect(
        tester.dialogueSays('Somebody up there likes the coffee strong'),
        findsOneWidget,
      );
      expect(tester.dialogueIsChoosing, isFalse);
      await tester.closeGame();
    });

    testWidgets('a quick double tap on a question asks it once and starts '
        'at its first line', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);

      final question = tester.dialogueQuestion('Ask about Ashgrove Villa');
      await tester.tap(question);
      await tester.tap(question, warnIfMissed: false);
      await tester.pumpFor(const Duration(milliseconds: 100));

      expect(tester.dialogueSays('Empty? I carried a tray'), findsOneWidget);
      final saved = progress().current!;
      expect(saved.askedTopics, {'cafe_owner/about_villa'});
      expect(saved.hasNoteEntry('person_cafe_owner', 'knows_villa'), isTrue);
      await tester.closeGame();
    });

    testWidgets('a quick double tap on a figure opens one conversation', (
      tester,
    ) async {
      await pumpAtMarket(tester);

      final figure = find.bySemanticsLabel(pharmacist);
      await tester.tap(figure);
      await tester.tap(figure, warnIfMissed: false);
      await tester.pumpFor();

      expect(find.byType(DialoguePanel), findsOneWidget);
      // Still the first greeting: the second tap did not skip it.
      expect(tester.dialogueSays("We're closed"), findsOneWidget);
      await tester.closeGame();
    });

    for (final (name, goBack)
        in <(String, Future<void> Function(WidgetTester))>[
          ('system back', (tester) => tester.binding.handlePopRoute()),
          ('Esc', (tester) => tester.sendKeyEvent(LogicalKeyboardKey.escape)),
        ]) {
      testWidgets('$name in the middle of an answer closes the panel; the '
          'question stays asked and the scene stays', (tester) async {
        await pumpAtMarket(tester);
        await open(tester, cafeOwner);
        await tester.askDialogue('Ask about Ashgrove Villa');

        await goBack(tester);
        await tester.pumpFor();

        expect(find.byType(DialoguePanel), findsNothing);
        expect(sceneStack(), ['market_square']);
        expect(
          progress().current!.hasAsked('cafe_owner', 'about_villa'),
          isTrue,
        );

        // The conversation opens again in good order.
        await open(tester, cafeOwner);
        expect(tester.dialogueAskedMarks, findsOneWidget);
        expect(tester.dialogueNewTags, findsOneWidget);
        await tester.closeGame();
      });

      testWidgets('$name twice in a row closes the panel and does not leave '
          'the game', (tester) async {
        await pumpAtMarket(tester);
        await open(tester, pharmacist);

        await goBack(tester);
        await goBack(tester);
        await tester.pumpFor();

        expect(find.byType(DialoguePanel), findsNothing);
        expect(find.bySemanticsLabel(pharmacist), findsOneWidget);
        expect(sceneStack(), ['market_square']);
        await tester.pumpFor(const Duration(seconds: 3));
        await tester.closeGame();
      });

      testWidgets('$name in the notebook opened for evidence returns to the '
          'panel and shows nothing', (tester) async {
        await pumpAtMarket(tester);
        await open(tester, cafeOwner);
        await tester.tap(find.text(l10n.dialogueShowEvidence));
        await tester.pumpFor();
        expect(find.byType(NotebookScreen), findsOneWidget);

        await goBack(tester);
        await tester.pumpFor();

        expect(find.byType(NotebookScreen), findsNothing);
        expect(find.byType(DialoguePanel), findsOneWidget);
        expect(tester.dialogueIsChoosing, isTrue);
        expect(progress().current!.askedTopics, isEmpty);
        await tester.closeGame();
      });
    }

    testWidgets('going to the background and back in the middle of a line '
        'keeps the conversation where it was', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);
      await tester.askDialogue('Ask about Ashgrove Villa');
      final before = progress().current;

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
        await tester.pump();
      }
      await tester.pumpFor();

      expect(progress().current, before);
      expect(tester.dialogueSays('Empty? I carried a tray'), findsOneWidget);
      // And it still reacts: on to the second line, then the questions.
      await tester.readDialogue();
      expect(tester.dialogueAskedMarks, findsOneWidget);
      await tester.closeGame();
    });

    testWidgets('a selected item on a figure that does not care: the panel '
        'opens, a shrug, the item stays and is no longer selected', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();
      expect(isSelected(tester, tester.itemSlot('Pill bottle')), isTrue);

      await tester.tapHotspot(cafeOwner);
      expect(tester.dialogueSays("Kitchen's closed"), findsOneWidget);
      await tester.tapDialogue();
      await tester.tapDialogue();
      await tester.pumpFor();

      expect(tester.dialogueSays('Means nothing to me'), findsOneWidget);
      expect(tester.itemSlot('Pill bottle'), findsOneWidget);
      expect(isSelected(tester, tester.itemSlot('Pill bottle')), isFalse);
      expect(progress().current!.askedTopics, isEmpty);
      await tester.closeGame();
    });

    testWidgets('a quick double tap on a figure with an item selected hands '
        'the item over once', (tester) async {
      await pumpAtMarket(tester);
      await tester.tap(tester.itemSlot('Pill bottle'));
      await tester.pumpFor();

      final figure = find.bySemanticsLabel(pharmacist);
      await tester.tap(figure);
      await tester.tap(figure, warnIfMissed: false);
      await tester.pumpFor();
      await tester.readDialogue();

      final saved = progress().current!;
      expect(saved.hasItem('pill_bottle'), isFalse);
      expect(saved.askedTopics, {'pharmacist/give_pills'});
      expect(tester.dialogueAskedMarks, findsOneWidget);
      await tester.closeGame();
    });
  });
}
