import 'dart:ui';

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// The rough handling a real player gives the game: the manual checklist
/// of plan step 1.8, as far as a test can press the buttons.
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
}
