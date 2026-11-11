import 'package:detective_dark/app/game_screen.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the title and the placeholder line in their fonts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GameScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('en'));
    final title = tester.widget<Text>(find.text(l10n.appTitle));
    final line = tester.widget<Text>(find.text(l10n.gameScreenPlaceholder));

    expect(title.style?.fontFamily, AppFonts.title);
    expect(line.style?.fontFamily, AppFonts.body);
  });
}
