import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the dialogue panel the way a player does: taps on what is
/// visible. Shared by the widget tests and the acceptance scenario.
extension DialogueDriver on WidgetTester {
  AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));

  Finder get dialoguePanel => find.byType(DialoguePanel);

  /// The line a character is saying right now, by how it starts.
  Finder dialogueSays(String start) => find.descendant(
    of: dialoguePanel,
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(start)}')),
  );

  /// A question in the list of the panel, by its text.
  Finder dialogueQuestion(String text) =>
      find.descendant(of: dialoguePanel, matching: find.text(text));

  /// The "new" tags in the question list.
  Finder get dialogueNewTags => find.descendant(
    of: dialoguePanel,
    matching: find.text(_l10n.dialogueTopicNew),
  );

  /// The check marks of asked questions.
  Finder get dialogueAskedMarks =>
      find.descendant(of: dialoguePanel, matching: find.byIcon(Icons.check));

  /// Whether the question list is on screen (and not a line).
  bool get dialogueIsChoosing =>
      find
          .descendant(of: dialoguePanel, matching: find.byType(ListView))
          .evaluate()
          .isNotEmpty ||
      find.text(_l10n.dialogueNoTopics).evaluate().isNotEmpty;

  /// A tap on the panel: completes the line or moves on.
  Future<void> tapDialogue({
    PointerDeviceKind pointer = PointerDeviceKind.touch,
  }) async {
    await tapAt(getCenter(dialoguePanel), kind: pointer);
    await pump(const Duration(milliseconds: 60));
  }

  /// Taps through whatever the character is saying until the question list
  /// is back.
  Future<void> readDialogue({
    PointerDeviceKind pointer = PointerDeviceKind.touch,
  }) async {
    for (var taps = 0; taps < 16 && !dialogueIsChoosing; taps++) {
      await tapDialogue(pointer: pointer);
    }
    expect(dialogueIsChoosing, isTrue, reason: 'the question list is back');
  }

  /// Asks the question with this text.
  Future<void> askDialogue(
    String text, {
    PointerDeviceKind pointer = PointerDeviceKind.touch,
  }) async {
    await tap(dialogueQuestion(text), kind: pointer);
    await pump(const Duration(milliseconds: 120));
  }

  /// Closes the panel with its own button.
  Future<void> closeDialogue({
    PointerDeviceKind pointer = PointerDeviceKind.touch,
  }) async {
    await tap(
      find.descendant(
        of: dialoguePanel,
        matching: find.byTooltip(_l10n.closeTooltip),
      ),
      kind: pointer,
    );
    await pump(const Duration(milliseconds: 300));
  }

  /// The slot of an item in the item panel, by the name of the item.
  Finder itemSlot(String name) => find.descendant(
    of: find.byType(ItemSidebar),
    matching: find.bySemanticsLabel(name),
  );
}
