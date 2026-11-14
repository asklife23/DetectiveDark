// Plays the acceptance scenario of phase 1 in the real app: real engine,
// real window or phone screen, real asset bundle. Not part of `flutter
// test` (it needs a device):
//
//   flutter test integration_test/acceptance_test.dart -d windows
//   flutter test integration_test/acceptance_test.dart -d <phone id> --flavor dev
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/acceptance_scenario.dart';
import '../test/helpers/game_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(GetIt.instance.reset);

  // Touch and mouse must behave the same (CLAUDE.md section 6, "Girdi").
  for (final pointer in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('the vertical slice plays from start to end '
        '(${pointer.name})', (tester) async {
      await setUpGameDependencies(assetBundle: rootBundle);
      await tester.pumpGame();

      await playAcceptanceScenario(tester, pointer: pointer);

      await tester.closeGame();
    });
  }
}
