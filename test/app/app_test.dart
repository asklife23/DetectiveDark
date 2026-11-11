import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App opens the game screen on a dark theme', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);

    final context = tester.element(find.byType(GameScreen));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, Colors.black);
  });
}
