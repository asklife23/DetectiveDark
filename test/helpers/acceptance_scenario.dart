import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'game_app.dart';

/// The acceptance scenario of phase 1 (plan.md), steps 1–11, played on the
/// real game screen exactly as a player would: only taps on what is
/// visible, only checks of what is visible.
///
/// One function, two runners:
/// - `test/app/game/acceptance_scenario_test.dart` plays it in the headless
///   test runner on every push;
/// - `integration_test/acceptance_test.dart` plays it in the real app on a
///   phone or in a Windows window.
///
/// [pointer] is the input device: touch on a phone, mouse on the desktop.
/// The game must behave the same with both.
///
/// The game must already be on screen in its first scene (`pumpGame`).
Future<void> playAcceptanceScenario(
  WidgetTester tester, {
  PointerDeviceKind pointer = PointerDeviceKind.touch,
}) async {
  final l10n = lookupAppLocalizations(const Locale('en'));

  // Hotspots, by their accessibility label.
  final door = find.bySemanticsLabel('Front door');
  final statue = find.bySemanticsLabel('Garden statue');
  final lock = find.bySemanticsLabel('Door lock');
  final doorway = find.bySemanticsLabel('Open doorway');
  final statueBody = find.bySemanticsLabel('Statue');
  final statueKey = find.bySemanticsLabel("Something behind the statue's ear");
  final plaque = find.bySemanticsLabel('Plaque on the pedestal');
  final paper = find.bySemanticsLabel('Sheet of paper on the desk');

  // Interface.
  final back = find.byTooltip(l10n.backTooltip);
  final notebookButton = find.byTooltip(l10n.notebookTooltip);
  final keyInPanel = find.descendant(
    of: find.byType(ItemSidebar),
    matching: find.bySemanticsLabel('Brass key'),
  );
  final notebookBadge = find.descendant(
    of: find.byType(NotebookButton),
    matching: find.text('1'),
  );
  Finder sprite(String style) => find.byWidgetPredicate(
    (widget) => widget is PlaceholderArt && widget.style == style,
  );
  final keyInScene = sprite(PlaceholderStyles.spriteBrassKey);
  final letterInScene = sprite(PlaceholderStyles.spriteLetter);

  /// The line the detective is saying right now (the open message bar).
  Finder says(String start) => find.bySemanticsLabel(RegExp('^$start'));

  Future<void> tap(Finder finder) async {
    await tester.tap(finder, kind: pointer);
    await tester.pumpFor();
  }

  // 1. The villa: the detective comments, door and statue are there, no
  //    Back button in a main scene.
  expect(says('Ashgrove Villa'), findsOneWidget);
  expect(door, findsOneWidget);
  expect(statue, findsOneWidget);
  expect(back, findsNothing);

  // 2. Door → close-up of the door, Back appears.
  await tap(door);
  expect(lock, findsOneWidget);
  expect(back, findsOneWidget);

  // 3. The lock: "Locked."
  await tap(lock);
  expect(says('Locked'), findsOneWidget);
  expect(lock, findsOneWidget);

  // 4. Back → villa → statue close-up: a key hangs behind the ear.
  await tap(back);
  expect(door, findsOneWidget);
  await tap(statue);
  expect(statueKey, findsOneWidget);
  expect(keyInScene, findsOneWidget);

  // 5. Take the key: it leaves the scene and lands in the item panel.
  await tap(statueKey);
  await tester.pumpFor(const Duration(seconds: 1));
  expect(statueKey, findsNothing);
  expect(keyInScene, findsNothing);
  expect(keyInPanel, findsOneWidget);
  expect(says('A brass key'), findsOneWidget);

  // 6. The key on the statue itself: only the generic reaction, the item
  //    stays and the selection is cleared.
  await tap(keyInPanel);
  expect(_isSelected(tester, keyInPanel), isTrue);
  await tap(statueBody);
  expect(says("That won't do anything here"), findsOneWidget);
  expect(keyInPanel, findsOneWidget);
  expect(_isSelected(tester, keyInPanel), isFalse);

  // 7. Back → door close-up → key on the lock: the door stands open, the
  //    key is used up.
  await tap(back);
  await tap(door);
  await tap(keyInPanel);
  await tap(lock);
  await tester.pumpFor();
  expect(doorway, findsOneWidget);
  expect(lock, findsNothing);
  expect(keyInPanel, findsNothing);
  expect(says('The key turns'), findsOneWidget);

  // 8. Through the open door into the hall; take the paper: it leaves the
  //    desk and the notebook gets a badge.
  await tap(doorway);
  expect(paper, findsOneWidget);
  expect(letterInScene, findsOneWidget);
  await tap(paper);
  await tester.pumpFor(const Duration(seconds: 1));
  expect(paper, findsNothing);
  expect(letterInScene, findsNothing);
  expect(notebookBadge, findsOneWidget);

  // 9. Read the paper in the notebook.
  await tap(notebookButton);
  expect(find.byType(NotebookScreen), findsOneWidget);
  await tap(find.text('Unsigned letter'));
  expect(find.textContaining('leave the door on the latch'), findsOneWidget);
  await tap(find.byTooltip(l10n.closeTooltip));
  expect(find.byType(NotebookScreen), findsNothing);
  expect(notebookBadge, findsNothing);

  // 10. Back, Back → villa. The key is gone from the statue for good and
  //     the door has stayed open.
  await tap(back);
  expect(doorway, findsOneWidget);
  await tap(back);
  expect(door, findsOneWidget);
  expect(back, findsNothing);
  await tap(statue);
  expect(statueKey, findsNothing);
  expect(keyInScene, findsNothing);

  // 11. The plaque opens the inspection panel without changing the scene.
  //     Back closes only the panel; Back again returns to the villa.
  await tap(plaque);
  expect(find.byType(InspectPanel), findsOneWidget);
  expect(find.text('FIDES ET SILENTIUM'), findsOneWidget);
  expect(find.textContaining('Faith and silence'), findsOneWidget);
  await tap(back);
  expect(find.byType(InspectPanel), findsNothing);
  expect(plaque, findsOneWidget);
  await tap(back);
  expect(door, findsOneWidget);
  expect(back, findsNothing);

  // And the door is still open.
  await tap(door);
  expect(doorway, findsOneWidget);
}

bool _isSelected(WidgetTester tester, Finder item) =>
    tester.getSemantics(item).flagsCollection.isSelected.toBoolOrNull()!;
