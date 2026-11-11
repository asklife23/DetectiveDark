import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/flavor_badge.dart';
import 'package:detective_dark/app/game_screen.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AppConfig config({required bool showDebugOverlay}) => AppConfig(
    flavor: Flavor.dev,
    supabaseUrl: '',
    supabaseAnonKey: '',
    showDebugOverlay: showDebugOverlay,
  );

  testWidgets('App opens the game screen on a dark theme', (tester) async {
    await tester.pumpWidget(App(config: config(showDebugOverlay: false)));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);

    final context = tester.element(find.byType(GameScreen));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.black);
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
    await tester.pumpWidget(App(config: config(showDebugOverlay: false)));
    await tester.pumpAndSettle();

    expect(find.byType(FlavorBadge), findsNothing);
  });
}
