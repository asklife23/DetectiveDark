import 'dart:convert';
import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/dialogue_layout.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_bar.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// The dialogue panel on the real game screen (acceptance scenario steps
/// 14–16 and 19).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  const pharmacist = 'Figure at the pharmacy window';
  const cafeOwner = 'Figure outside the café';

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  ProgressRepository progress() => GetIt.instance<ProgressRepository>();

  /// Starts in the market square with the bottle and the (read) letter.
  Future<void> pumpAtMarket(WidgetTester tester, {Size? window}) async {
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
    if (window == null) {
      tester.useLandscapePhone();
    } else {
      tester.view
        ..physicalSize = window
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpGame();
  }

  /// The line a character is saying right now.
  Finder says(String start) => find.descendant(
    of: find.byType(DialoguePanel),
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(start)}')),
  );

  /// A question in the list, by its text.
  Finder question(String text) => find.descendant(
    of: find.byType(DialoguePanel),
    matching: find.text(text),
  );

  Finder newTags() => find.descendant(
    of: find.byType(DialoguePanel),
    matching: find.text(l10n.dialogueTopicNew),
  );

  Finder askedMarks() => find.descendant(
    of: find.byType(DialoguePanel),
    matching: find.byIcon(Icons.check),
  );

  /// Taps the panel: completes the line or moves on.
  Future<void> tapPanel(WidgetTester tester) async {
    await tester.tapAt(tester.getCenter(find.byType(DialoguePanel)));
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Taps through whatever the character is saying, to the question list.
  Future<void> readOn(WidgetTester tester) async {
    for (var i = 0; i < 12 && newTags().evaluate().isEmpty; i++) {
      if (askedMarks().evaluate().isNotEmpty) break;
      await tapPanel(tester);
    }
  }

  Future<void> open(WidgetTester tester, String figure) async {
    await tester.tapHotspot(figure);
    await readOn(tester);
  }

  Future<void> ask(WidgetTester tester, String text) async {
    await tester.tap(question(text));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('14. a tap on the café owner opens the panel directly: name, '
      'greeting, then two questions, both new', (tester) async {
    await pumpAtMarket(tester);
    expect(find.byType(DialoguePanel), findsNothing);

    await tester.tapHotspot(cafeOwner);

    // No "Talk" step in between: the panel is there and the character
    // speaks.
    expect(find.byType(DialoguePanel), findsOneWidget);
    expect(find.text('The café owner'), findsOneWidget);
    expect(says("Kitchen's closed"), findsOneWidget);
    expect(question('Ask about Ashgrove Villa'), findsNothing);

    await readOn(tester);

    expect(question('Ask about Ashgrove Villa'), findsOneWidget);
    expect(question('Ask about the pharmacist'), findsOneWidget);
    // The letter waits for evidence: it is not a question yet.
    expect(question('Show the unsigned letter'), findsNothing);
    expect(newTags(), findsNWidgets(2));
    expect(askedMarks(), findsNothing);

    await tester.closeGame();
  });

  testWidgets('14. the lines of an answer advance tap by tap; the question '
      'is marked asked afterwards', (tester) async {
    await pumpAtMarket(tester);
    await open(tester, cafeOwner);

    await ask(tester, 'Ask about Ashgrove Villa');
    expect(says('Empty? I carried a tray'), findsOneWidget);
    expect(question('Ask about the pharmacist'), findsNothing);

    // First tap completes the line that is being typed, the second one
    // moves on.
    await tapPanel(tester);
    expect(says('Empty? I carried a tray'), findsOneWidget);
    await tapPanel(tester);
    expect(says('Somebody up there likes the coffee strong'), findsOneWidget);

    await tapPanel(tester);
    await tapPanel(tester);

    expect(question('Ask about Ashgrove Villa'), findsOneWidget);
    expect(newTags(), findsOneWidget);
    expect(askedMarks(), findsOneWidget);
    expect(progress().current!.askedTopics, {'cafe_owner/about_villa'});

    await tester.closeGame();
  });

  testWidgets('a line that was typed to its end needs one tap to move '
      'on', (tester) async {
    await pumpAtMarket(tester);
    await open(tester, cafeOwner);
    await ask(tester, 'Ask about Ashgrove Villa');

    // Let the typewriter finish by itself.
    await tester.pumpFor(const Duration(seconds: 4));
    await tapPanel(tester);

    expect(says('Somebody up there likes the coffee strong'), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('15. the pharmacist offers three questions with the bottle '
      'in hand; asking about the villa adds a line to his file, lights the '
      'notebook badge and fires the trigger once', (tester) async {
    await pumpAtMarket(tester);
    await open(tester, cafeOwner);
    await ask(tester, 'Ask about Ashgrove Villa');
    await readOn(tester);
    await tester.tap(find.byTooltip(l10n.closeTooltip));
    await tester.pumpFor();
    // The café owner's file is new in the notebook.
    final badge = find.descendant(
      of: find.byType(NotebookButton),
      matching: find.text('1'),
    );
    expect(badge, findsOneWidget);

    await open(tester, pharmacist);
    expect(find.text('The pharmacist'), findsOneWidget);
    expect(question('Ask about Ashgrove Villa'), findsOneWidget);
    expect(question('Ask about last night'), findsOneWidget);
    expect(question('Ask about the pills'), findsOneWidget);
    expect(question('Hand over the pill bottle'), findsNothing);
    expect(newTags(), findsNWidgets(3));

    await ask(tester, 'Ask about Ashgrove Villa');
    await tester.pumpFor();

    // The trigger: the detective speaks in the message bar under the
    // panel, and an observation joins the two files.
    expect(
      find.descendant(
        of: find.byType(ChatBar),
        matching: find.bySemanticsLabel(RegExp('^Empty since spring')),
      ),
      findsOneWidget,
    );
    final saved = progress().current!;
    expect(saved.firedTriggers, {'both_asked_about_villa'});
    expect(saved.hasNoteEntry('person_pharmacist', 'knows_villa'), isTrue);
    expect(saved.hasNote('obs_stories_do_not_match'), isTrue);
    expect(
      find.descendant(
        of: find.byType(NotebookButton),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );

    // Asking again only replays the answer.
    await readOn(tester);
    await ask(tester, 'Ask about Ashgrove Villa');
    await readOn(tester);
    expect(progress().current, same(saved));

    await tester.closeGame();
  });

  testWidgets('16. asking about the pills: the answer in the panel, the '
      'thought of the detective in the message bar', (tester) async {
    await pumpAtMarket(tester);
    await open(tester, pharmacist);

    await ask(tester, 'Ask about the pills');
    await tester.pumpFor();

    expect(says('Brown glass, no label'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ChatBar),
        matching: find.bySemanticsLabel(RegExp('^He looked at that bottle')),
      ),
      findsOneWidget,
    );
    // The lines of a character never enter the message history.
    expect(progress().current!.chatLog.map((entry) => entry.textKey), [
      'say_pills_owner_known',
    ]);

    await tester.closeGame();
  });

  testWidgets('19. the second visit is greeted with the other line', (
    tester,
  ) async {
    await pumpAtMarket(tester);
    await tester.tapHotspot(pharmacist);
    expect(says("We're closed"), findsOneWidget);
    await readOn(tester);
    await tester.tap(find.byTooltip(l10n.closeTooltip));
    await tester.pumpFor();
    expect(find.byType(DialoguePanel), findsNothing);

    await tester.tapHotspot(pharmacist);

    expect(says('You again'), findsOneWidget);

    await tester.closeGame();
  });

  group('the panel and the rest of the screen', () {
    testWidgets('it leaves the item panel and the message bar free', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);

      final panel = tester.getRect(find.byType(DialoguePanel));
      final items = tester.getRect(find.byType(ItemSidebar));
      final bar = tester.getRect(find.byType(ChatBar));

      expect(panel.right, lessThanOrEqualTo(items.left));
      expect(panel.bottom, lessThanOrEqualTo(bar.top + 0.01));
      expect(panel.overlaps(items), isFalse);

      await tester.closeGame();
    });

    testWidgets('the scene cannot be tapped while it is open', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);

      await tester.tap(
        find.bySemanticsLabel('Road back to the villa'),
        warnIfMissed: false,
      );
      await tester.tap(find.bySemanticsLabel(cafeOwner), warnIfMissed: false);
      await tester.pumpFor();

      expect(progress().current!.currentSceneId, 'market_square');
      expect(find.text('The pharmacist'), findsOneWidget);
      expect(find.text('The café owner'), findsNothing);

      await tester.closeGame();
    });

    testWidgets('the close button closes it; the scene is back', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);

      await tester.tap(find.byTooltip(l10n.closeTooltip));
      await tester.pumpFor();
      expect(find.byType(DialoguePanel), findsNothing);

      await tester.tapHotspot('Road back to the villa');
      expect(find.bySemanticsLabel('Front door'), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('system back closes the panel and nothing else', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);

      await tester.binding.handlePopRoute();
      await tester.pumpFor();

      expect(find.byType(DialoguePanel), findsNothing);
      expect(find.bySemanticsLabel(pharmacist), findsOneWidget);
      // No "press again to leave" hint: Back had something to close.
      expect(find.text(l10n.exitHint), findsNothing);

      await tester.closeGame();
    });

    testWidgets('Esc closes the panel', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, cafeOwner);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpFor();

      expect(find.byType(DialoguePanel), findsNothing);
      expect(progress().current!.currentSceneId, 'market_square');

      await tester.closeGame();
    });

    testWidgets('Back closes the notebook first, then the panel', (
      tester,
    ) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      expect(find.byType(NotebookScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpFor();
      expect(find.byType(NotebookScreen), findsNothing);
      expect(find.byType(DialoguePanel), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpFor();
      expect(find.byType(DialoguePanel), findsNothing);

      await tester.closeGame();
    });

    testWidgets('panels never stack: a long press on an item opens no '
        'examine card while the panel is open', (tester) async {
      await pumpAtMarket(tester);
      await open(tester, pharmacist);

      await tester.longPress(
        find.descendant(
          of: find.byType(ItemSidebar),
          matching: find.bySemanticsLabel('Pill bottle'),
        ),
      );
      await tester.pumpFor();

      expect(find.byType(InspectPanel), findsNothing);
      expect(find.byType(DialoguePanel), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('a mouse click works like a touch', (tester) async {
      await pumpAtMarket(tester, window: const Size(1280, 720));

      await tester.tap(
        find.bySemanticsLabel(cafeOwner),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpFor();
      expect(says("Kitchen's closed"), findsOneWidget);

      final center = tester.getCenter(find.byType(DialoguePanel));
      await tester.tapAt(center, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(center, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(
        question('Ask about the pharmacist'),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(says('He shuts early these days'), findsOneWidget);

      await tester.closeGame();
    });
  });

  group('four questions without scrolling', () {
    /// The real content, with a pharmacist who has six fixed questions.
    Future<void> setUpSixQuestions() async {
      const path = 'assets/content/cases/case01/chapters/ch01/dialogues.json';
      final bundle = realContentBundle();
      final file = jsonDecode(bundle.files[path]!) as Map<String, dynamic>;
      final dialogues = (file['dialogues'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final pharmacist = dialogues.firstWhere(
        (dialogue) => dialogue['id'] == 'pharmacist',
      );
      final first = (pharmacist['topics'] as List<dynamic>).first;
      pharmacist['topics'] = [
        first,
        for (var i = 2; i <= 6; i++)
          {
            'id': 'extra_$i',
            'promptKey': 'dlg_pharmacist_q_night',
            'answer': ['dlg_pharmacist_night_1'],
          },
      ];
      bundle.files[path] = jsonEncode(file);
      await setUpGameDependencies(assetBundle: bundle);
    }

    testWidgets('on the smallest supported phone (640×360) the fourth '
        'question is fully visible and can be tapped; more scroll', (
      tester,
    ) async {
      await setUpSixQuestions();
      await pumpAtMarket(tester, window: const Size(640, 360));
      await open(tester, pharmacist);

      final panel = tester.getRect(find.byType(DialoguePanel));
      expect(panel.height, greaterThanOrEqualTo(DialogueLayout.minPanelHeight));

      // The rows of the question list (the close button is an InkWell
      // too, hence "inside the list").
      final rows = find.descendant(
        of: find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
        matching: find.byType(InkWell),
      );
      final list = tester.getRect(
        find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
      );
      // The first four rows lie completely inside the list area.
      for (var i = 0; i < DialogueLayout.topicsWithoutScrolling; i++) {
        final row = tester.getRect(rows.at(i));
        expect(row.top, greaterThanOrEqualTo(list.top - 0.01), reason: '$i');
        expect(row.bottom, lessThanOrEqualTo(list.bottom + 0.01), reason: '$i');
        expect(row.height, DialogueLayout.topicRowHeight, reason: '$i');
      }

      // The fourth one answers a tap.
      await tester.tap(rows.at(3));
      await tester.pump(const Duration(milliseconds: 100));
      expect(says('I closed at six'), findsOneWidget);
      expect(progress().current!.askedTopics, {'pharmacist/extra_4'});

      // The sixth one is reached by scrolling.
      await readOn(tester);
      await tester.drag(
        find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
        const Offset(0, -200),
      );
      await tester.pump();
      await tester.tap(rows.last);
      await tester.pump(const Duration(milliseconds: 100));
      expect(progress().current!.askedTopics, contains('pharmacist/extra_6'));

      await tester.closeGame();
    });

    testWidgets('the same holds on an 800×360 phone', (tester) async {
      await setUpSixQuestions();
      await pumpAtMarket(tester, window: const Size(800, 360));
      await open(tester, pharmacist);

      // The rows of the question list (the close button is an InkWell
      // too, hence "inside the list").
      final rows = find.descendant(
        of: find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
        matching: find.byType(InkWell),
      );
      final list = tester.getRect(
        find.descendant(
          of: find.byType(DialoguePanel),
          matching: find.byType(ListView),
        ),
      );
      expect(
        tester.getRect(rows.at(3)).bottom,
        lessThanOrEqualTo(list.bottom + 0.01),
      );

      await tester.closeGame();
    });
  });
}
