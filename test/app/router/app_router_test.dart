import 'package:detective_dark/app/game_screen.dart';
import 'package:detective_dark/app/router/app_router.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on the game route and shows the game screen', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.game);
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
