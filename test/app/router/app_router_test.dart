import 'package:detective_dark/app/game/game_screen.dart';
import 'package:detective_dark/app/router/app_router.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

void main() {
  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  testWidgets('starts on the game route and shows the game screen', (
    tester,
  ) async {
    final router = createAppRouter(showDebugTools: true);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpFor();

    expect(router.state.uri.path, AppRoutes.game);
    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.showDebugTools, isTrue);
  });
}
