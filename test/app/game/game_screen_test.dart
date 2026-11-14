import 'package:detective_dark/app/game/game_status_views.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/game_app.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  Finder backButton() => find.byTooltip(l10n.backTooltip);

  testWidgets('shows a loading indicator, then the first scene', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    expect(find.byType(GameLoadingView), findsNothing);
    expect(find.byType(SceneView), findsOneWidget);
    expect(find.bySemanticsLabel('Front door'), findsOneWidget);
    expect(find.bySemanticsLabel('Garden statue'), findsOneWidget);
    // Overlay text drawn by the game, not part of the picture.
    expect(find.text('17'), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('Back is hidden in a main scene and returns from a close-up', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    expect(backButton(), findsNothing);

    await tester.tapHotspot('Front door');
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);
    expect(backButton(), findsOneWidget);

    await tester.tap(backButton());
    await tester.pumpFor();
    expect(find.bySemanticsLabel('Front door'), findsOneWidget);
    expect(backButton(), findsNothing);

    await tester.closeGame();
  });

  group('Esc', () {
    Future<void> pressEsc(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpFor();
    }

    testWidgets('returns from a close-up', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();
      await tester.tapHotspot('Front door');
      expect(find.bySemanticsLabel('Door lock'), findsOneWidget);

      await pressEsc(tester);

      expect(find.bySemanticsLabel('Front door'), findsOneWidget);
      await tester.closeGame();
    });

    testWidgets('closes the inspection panel first', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();
      await tester.tapHotspot('Garden statue');
      await tester.tapHotspot('Plaque on the pedestal');
      expect(find.byType(InspectPanel), findsOneWidget);

      await pressEsc(tester);
      expect(find.byType(InspectPanel), findsNothing);
      expect(find.bySemanticsLabel('Plaque on the pedestal'), findsOneWidget);

      await pressEsc(tester);
      expect(find.bySemanticsLabel('Garden statue'), findsOneWidget);
      await tester.closeGame();
    });

    testWidgets('still works after a button took the focus', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();
      await tester.tapHotspot('Front door');
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      expect(find.byType(NotebookScreen), findsOneWidget);

      await pressEsc(tester);
      expect(find.byType(NotebookScreen), findsNothing);
      expect(find.bySemanticsLabel('Door lock'), findsOneWidget);

      await pressEsc(tester);
      expect(find.bySemanticsLabel('Front door'), findsOneWidget);
      await tester.closeGame();
    });

    testWidgets('does nothing in a main scene', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();

      await pressEsc(tester);

      expect(find.bySemanticsLabel('Front door'), findsOneWidget);
      expect(find.text(l10n.exitHint), findsNothing);
      await tester.closeGame();
    });
  });

  testWidgets('the system back button returns from a close-up', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Garden statue');
    expect(find.bySemanticsLabel('Plaque on the pedestal'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpFor();

    expect(find.bySemanticsLabel('Garden statue'), findsOneWidget);
    await tester.closeGame();
  });

  testWidgets('system back in a main scene asks before leaving the game', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    await tester.binding.handlePopRoute();
    await tester.pumpFor();

    expect(find.text(l10n.exitHint), findsOneWidget);
    expect(find.byType(SceneView), findsOneWidget);

    // Let the hint and its timer run out.
    await tester.pumpFor(const Duration(seconds: 3));
    await tester.closeGame();
  });

  group('inspection panel', () {
    Future<void> openPlaque(WidgetTester tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();
      await tester.tapHotspot('Garden statue');
      await tester.tapHotspot('Plaque on the pedestal');
    }

    testWidgets('opens above the scene with picture, overlay and text', (
      tester,
    ) async {
      await openPlaque(tester);

      expect(find.byType(InspectPanel), findsOneWidget);
      expect(find.text('Plaque'), findsOneWidget);
      expect(find.text('FIDES ET SILENTIUM'), findsOneWidget);
      // The scene is still there underneath.
      expect(find.bySemanticsLabel('Statue'), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('the close button closes it', (tester) async {
      await openPlaque(tester);

      await tester.tap(find.byTooltip(l10n.closeTooltip));
      await tester.pumpFor();

      expect(find.byType(InspectPanel), findsNothing);
      await tester.closeGame();
    });

    testWidgets('a tap outside closes it', (tester) async {
      await openPlaque(tester);

      await tester.tapAt(
        tester.getTopLeft(find.byType(InspectPanel)) + const Offset(4, 4),
      );
      await tester.pumpFor();

      expect(find.byType(InspectPanel), findsNothing);
      await tester.closeGame();
    });

    testWidgets('Back closes only the panel, not the scene', (tester) async {
      await openPlaque(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpFor();
      expect(find.byType(InspectPanel), findsNothing);
      expect(find.bySemanticsLabel('Plaque on the pedestal'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpFor();
      expect(find.bySemanticsLabel('Garden statue'), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('the scene cannot be tapped through the panel', (tester) async {
      await openPlaque(tester);

      // The key lies under the scrim.
      await tester.tap(
        find.bySemanticsLabel("Something behind the statue's ear"),
        warnIfMissed: false,
      );
      await tester.pumpFor();

      // The tap only closed the panel; the key is still on the statue.
      expect(
        find.bySemanticsLabel("Something behind the statue's ear"),
        findsOneWidget,
      );
      await tester.closeGame();
    });
  });

  testWidgets('developer tools: the hotspot outlines can be toggled', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame(showDebugTools: true);
    expect(find.text('door'), findsNothing);

    await tester.tap(find.byTooltip(l10n.debugHotspotsTooltip));
    await tester.pumpFor();

    expect(find.text('door'), findsOneWidget);
    expect(find.text('statue'), findsOneWidget);
    await tester.closeGame();
  });

  testWidgets('without debug tools there is no hotspot toggle', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    expect(find.byTooltip(l10n.debugHotspotsTooltip), findsNothing);
    await tester.closeGame();
  });

  testWidgets('content that cannot be loaded shows an error with retry', (
    tester,
  ) async {
    await setUpGameDependencies(assetBundle: FakeAssetBundle({}));
    await tester.pumpGame();

    expect(find.byType(GameErrorView), findsOneWidget);
    expect(find.text(l10n.gameLoadFailed), findsOneWidget);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pumpFor();
    expect(find.byType(GameErrorView), findsOneWidget);
  });
}
