import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/acceptance_scenario.dart';
import '../../helpers/game_app.dart';

/// The acceptance scenario of phase 1, end to end on the real game screen
/// with the real content. Runs on every push (CI); the same scenario runs
/// on a device from `integration_test/acceptance_test.dart`.
void main() {
  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  for (final pointer in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('the vertical slice plays from start to end '
        '(${pointer.name})', (tester) async {
      tester.useLandscapePhone();
      await tester.pumpGame();

      await playAcceptanceScenario(tester, pointer: pointer);

      await tester.closeGame();
    });
  }

  testWidgets('it also plays in a desktop window (1280×720)', (tester) async {
    tester.view
      ..physicalSize = const Size(1280, 720)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpGame();

    await playAcceptanceScenario(tester, pointer: PointerDeviceKind.mouse);

    await tester.closeGame();
  });

  testWidgets('it also plays on a tablet (4:3)', (tester) async {
    tester.view
      ..physicalSize = const Size(2048, 1536)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpGame();

    await playAcceptanceScenario(tester);

    await tester.closeGame();
  });
}
