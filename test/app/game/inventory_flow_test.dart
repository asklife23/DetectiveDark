import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// The item panel together with the scene: pick up, select, use, examine.
/// (Acceptance scenario steps 1–7, on the real game screen.)
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  const keyLabel = "Something behind the statue's ear";

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  // Scoped to the panel: the examine card shows the same name as a title.
  Finder keySlot() => find.descendant(
    of: find.byType(ItemSidebar),
    matching: find.bySemanticsLabel('Brass key'),
  );

  Future<void> takeKey(WidgetTester tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Garden statue');
    await tester.tapHotspot(keyLabel);
    await tester.pumpFor(const Duration(seconds: 1));
  }

  bool keyIsSelected(WidgetTester tester) =>
      tester.getSemantics(keySlot()).flagsCollection.isSelected.toBoolOrNull()!;

  testWidgets('the panel sits right of the scene and starts empty', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    final panel = tester.getRect(find.byType(ItemSidebar));
    final scene = tester.getRect(find.byType(SceneViewport));
    expect(panel.width, AppSizes.sidebarWidth);
    expect(panel.right, 800);
    expect(scene.right, lessThanOrEqualTo(panel.left));
    expect(find.text(l10n.inventoryEmpty), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('a collected item leaves the scene and lands in the panel', (
    tester,
  ) async {
    await takeKey(tester);

    expect(find.bySemanticsLabel(keyLabel), findsNothing);
    expect(keySlot(), findsOneWidget);
    expect(find.text(l10n.inventoryEmpty), findsNothing);

    await tester.closeGame();
  });

  testWidgets('tap selects the item, a second tap puts it back', (
    tester,
  ) async {
    await takeKey(tester);
    expect(keyIsSelected(tester), isFalse);

    await tester.tap(keySlot());
    await tester.pumpFor();
    expect(keyIsSelected(tester), isTrue);

    await tester.tap(keySlot());
    await tester.pumpFor();
    expect(keyIsSelected(tester), isFalse);

    await tester.closeGame();
  });

  testWidgets('a wrong target keeps the item and clears the selection', (
    tester,
  ) async {
    await takeKey(tester);
    await tester.tap(keySlot());
    await tester.pumpFor();

    await tester.tapHotspot('Statue');

    expect(keySlot(), findsOneWidget);
    expect(keyIsSelected(tester), isFalse);
    final progress = GetIt.instance<ProgressRepository>().current!;
    expect(progress.chatLog.last.textKey, 'generic_item_no_effect');

    await tester.closeGame();
  });

  testWidgets('the key opens the door and is used up', (tester) async {
    await takeKey(tester);
    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();
    await tester.tapHotspot('Front door');

    // Without the key selected the lock stays shut.
    await tester.tapHotspot('Door lock');
    expect(find.bySemanticsLabel('Open doorway'), findsNothing);

    await tester.tap(keySlot());
    await tester.pumpFor();
    await tester.tapHotspot('Door lock');

    expect(find.bySemanticsLabel('Open doorway'), findsOneWidget);
    expect(find.bySemanticsLabel('Door lock'), findsNothing);
    expect(keySlot(), findsNothing);
    expect(find.text(l10n.inventoryEmpty), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('a long press opens the examine card of the item', (
    tester,
  ) async {
    await takeKey(tester);

    await tester.longPress(keySlot());
    await tester.pumpFor();

    expect(find.byType(InspectPanel), findsOneWidget);
    expect(find.text('Brass key'), findsOneWidget);
    expect(find.textContaining('hidden on the garden statue'), findsOneWidget);
    // Examining is not selecting.
    expect(keyIsSelected(tester), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpFor();
    expect(find.byType(InspectPanel), findsNothing);

    await tester.closeGame();
  });
}
