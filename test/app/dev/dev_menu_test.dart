import 'dart:io';

import 'package:detective_dark/app/dev/dev_menu.dart';
import 'package:detective_dark/app/dev/dev_preset_source.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/game_app.dart';

/// The developer menu inside the running game, with the real content and
/// the real preset file.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  /// The content plus the preset file, as the dev flavor bundles it.
  FakeAssetBundle devBundle() => FakeAssetBundle({
    ...realContentBundle().files,
    DevPresetSource.path: File(DevPresetSource.path).readAsStringSync(),
  });

  tearDown(GetIt.instance.reset);

  Finder menuButton() => find.byTooltip(l10n.devMenuTooltip);
  Finder chip(String id) => find.widgetWithText(ActionChip, id);

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(menuButton());
    await tester.pumpFor();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpFor();
  }

  Future<void> tapChip(WidgetTester tester, String id) async {
    await tester.tap(chip(id));
    await tester.pumpFor();
  }

  /// Taps a chip that moves the player; the scene starts again.
  Future<void> tapMovingChip(WidgetTester tester, String id) async {
    await tester.tap(chip(id));
    await tester.pumpSceneRestart();
  }

  ProgressRepository progress() => GetIt.instance<ProgressRepository>();

  group('with the menu (dev entry point)', () {
    setUp(() => setUpGameDependencies(assetBundle: devBundle()));

    testWidgets('the button opens the menu, close and Esc close it', (
      tester,
    ) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);
      expect(find.text(l10n.devMenuTitle), findsNothing);

      await openMenu(tester);
      expect(find.text(l10n.devMenuTitle), findsOneWidget);
      // The first tab lists the scenes; the current one cannot be tapped.
      expect(chip('market_square'), findsOneWidget);
      expect(
        tester.widget<ActionChip>(chip('villa_exterior')).onPressed,
        isNull,
      );

      await tester.tap(find.byTooltip(l10n.closeTooltip));
      await tester.pumpFor();
      expect(find.text(l10n.devMenuTitle), findsNothing);

      await openMenu(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpFor();
      expect(find.text(l10n.devMenuTitle), findsNothing);
      expect(find.bySemanticsLabel('Front door'), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('jumping to a scene closes the menu and shows that scene', (
      tester,
    ) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);

      await openMenu(tester);
      await tapMovingChip(tester, 'villa_hall');

      expect(find.text(l10n.devMenuTitle), findsNothing);
      expect(
        find.bySemanticsLabel('Sheet of paper on the desk'),
        findsOneWidget,
      );
      // A close-up: Back leads up the parent chain.
      expect(find.byTooltip(l10n.backTooltip), findsOneWidget);
      expect(progress().current!.sceneStack, [
        'villa_exterior',
        'villa_door_closeup',
        'villa_hall',
      ]);

      await tester.closeGame();
    });

    testWidgets('adding an item, a note and a flag keeps the menu open and '
        'marks them', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);
      await openMenu(tester);

      await openTab(tester, l10n.devMenuTabItems);
      await tapChip(tester, 'pill_bottle');
      expect(tester.widget<ActionChip>(chip('pill_bottle')).onPressed, isNull);

      await openTab(tester, l10n.devMenuTabNotes);
      await tapChip(tester, 'hall_letter');

      await openTab(tester, l10n.devMenuTabFlags);
      await tapChip(tester, 'front_door_open');

      expect(find.text(l10n.devMenuTitle), findsOneWidget);
      final current = progress().current!;
      expect(current.inventory, ['pill_bottle']);
      expect(current.hasNote('hall_letter'), isTrue);
      expect(current.hasFlag('front_door_open'), isTrue);

      // The game behind the menu followed: the letter made the sign appear.
      await tester.tap(find.byTooltip(l10n.closeTooltip));
      await tester.pumpFor();
      expect(find.bySemanticsLabel('Signpost to the market'), findsOneWidget);

      await tester.closeGame();
    });

    testWidgets('the preset opens the market with the bottle and the '
        'letter', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);
      await openMenu(tester);

      await openTab(tester, l10n.devMenuTabPresets);
      await tapMovingChip(tester, 'market_with_pills');

      expect(find.text(l10n.devMenuTitle), findsNothing);
      expect(
        find.bySemanticsLabel('Figure at the pharmacy window'),
        findsOneWidget,
      );
      expect(find.byTooltip(l10n.backTooltip), findsNothing);
      final current = progress().current!;
      expect(current.sceneStack, ['market_square']);
      expect(current.inventory, ['pill_bottle']);
      expect(current.hasNote('hall_letter'), isTrue);
      expect(current.hasFlag('front_door_open'), isTrue);

      await tester.closeGame();
    });

    testWidgets('reset starts the case again', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);
      await openMenu(tester);
      await openTab(tester, l10n.devMenuTabPresets);
      await tapMovingChip(tester, 'market_with_pills');

      await openMenu(tester);
      await tester.tap(find.text(l10n.devMenuReset));
      await tester.pumpSceneRestart();

      expect(find.text(l10n.devMenuTitle), findsNothing);
      expect(find.bySemanticsLabel('Front door'), findsOneWidget);
      final current = progress().current!;
      expect(current.sceneStack, ['villa_exterior']);
      expect(current.inventory, isEmpty);
      expect(current.notes, isEmpty);
      expect(current.flags, isEmpty);

      await tester.closeGame();
    });

    testWidgets('the button does not depend on the debug overlay flag', (
      tester,
    ) async {
      tester.useLandscapePhone();
      await tester.pumpGame(devMenu: buildDevMenu);

      expect(menuButton(), findsOneWidget);
      expect(find.byTooltip(l10n.debugHotspotsTooltip), findsNothing);

      await tester.closeGame();
    });
  });

  testWidgets('a build without the preset file shows an empty preset list '
      '(Windows)', (tester) async {
    await setUpGameDependencies();
    tester.useLandscapePhone();
    await tester.pumpGame(devMenu: buildDevMenu);
    await openMenu(tester);

    await openTab(tester, l10n.devMenuTabPresets);

    expect(find.text(l10n.devMenuNoPresets), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.closeGame();
  });

  testWidgets('a game that was given no menu has no button, even with the '
      'debug overlay on (staging, prod, Steam)', (tester) async {
    await setUpGameDependencies(
      assetBundle: devBundle(),
      config: testConfig(showDebugOverlay: true),
    );
    tester.useLandscapePhone();
    await tester.pumpGame(showDebugTools: true);

    expect(menuButton(), findsNothing);
    expect(find.byTooltip(l10n.debugHotspotsTooltip), findsOneWidget);

    await tester.closeGame();
  });
}
