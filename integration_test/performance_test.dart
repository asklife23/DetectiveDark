// Measures frame times while the acceptance scenario plays. Run it in
// PROFILE mode on a real device; debug numbers mean nothing:
//
//   flutter drive --profile -d windows \
//     --driver=test_driver/performance_driver.dart \
//     --target=integration_test/performance_test.dart \
//     --dart-define-from-file=env/dev.json
//
// (On a phone add `--flavor dev -d <phone id>`.) The summary is written to
// `build/performance/acceptance_scenario.json`. The target is 60 fps: a
// frame budget of 16.6 ms for build + raster.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/acceptance_scenario.dart';
import '../test/helpers/game_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(GetIt.instance.reset);

  testWidgets('frame times of the acceptance scenario', (tester) async {
    await setUpGameDependencies(assetBundle: rootBundle);
    await tester.pumpGame();

    await binding.watchPerformance(
      () => playAcceptanceScenario(tester),
      reportKey: 'acceptance_scenario',
    );

    await tester.closeGame();
  });
}
