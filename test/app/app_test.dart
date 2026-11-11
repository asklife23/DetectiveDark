import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/flavor_badge.dart';
import 'package:detective_dark/app/game_screen.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppConfig config({bool showDebugOverlay = false}) => AppConfig(
    flavor: Flavor.dev,
    supabaseUrl: '',
    supabaseAnonKey: '',
    showDebugOverlay: showDebugOverlay,
  );

  testWidgets('App opens the game screen on the noir theme', (tester) async {
    await tester.pumpWidget(App(config: config()));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);

    final theme = Theme.of(tester.element(find.byType(GameScreen)));
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
  });

  testWidgets('supported languages come only from the generated list', (
    tester,
  ) async {
    await tester.pumpWidget(App(config: config()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
  });

  testWidgets('an unsupported device language falls back to English', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(App(config: config()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(GameScreen));
    expect(Localizations.localeOf(context), const Locale('en'));
    final english = lookupAppLocalizations(const Locale('en'));
    expect(find.text(english.gameScreenPlaceholder), findsOneWidget);
  });

  testWidgets('shows the flavor badge when the overlay is on', (tester) async {
    await tester.pumpWidget(App(config: config(showDebugOverlay: true)));
    await tester.pumpAndSettle();

    expect(find.byType(FlavorBadge), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
  });

  testWidgets('hides the flavor badge when the overlay is off', (
    tester,
  ) async {
    await tester.pumpWidget(App(config: config()));
    await tester.pumpAndSettle();

    expect(find.byType(FlavorBadge), findsNothing);
  });
}
