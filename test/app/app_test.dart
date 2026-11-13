import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/flavor_badge.dart';
import 'package:detective_dark/app/game/game_screen.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../helpers/game_app.dart';

void main() {
  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  testWidgets('App opens the game screen on the noir theme', (tester) async {
    await tester.pumpWidget(App(config: testConfig()));
    await tester.pumpFor();

    expect(find.byType(GameScreen), findsOneWidget);

    final theme = Theme.of(tester.element(find.byType(GameScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
  });

  testWidgets('supported languages come only from the generated list', (
    tester,
  ) async {
    await tester.pumpWidget(App(config: testConfig()));
    await tester.pumpFor();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
  });

  testWidgets('an unsupported device language falls back to English', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(App(config: testConfig()));
    await tester.pumpFor();

    final context = tester.element(find.byType(GameScreen));
    expect(Localizations.localeOf(context), const Locale('en'));
    // The story texts follow the same language: the English content loads.
    expect(find.bySemanticsLabel('Front door'), findsOneWidget);
  });

  testWidgets('shows the flavor badge when the overlay is on', (tester) async {
    await tester.pumpWidget(App(config: testConfig(showDebugOverlay: true)));
    await tester.pumpFor();

    expect(find.byType(FlavorBadge), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
  });

  testWidgets('hides the flavor badge when the overlay is off', (
    tester,
  ) async {
    await tester.pumpWidget(App(config: testConfig()));
    await tester.pumpFor();

    expect(find.byType(FlavorBadge), findsNothing);
  });
}
