import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English is supported', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });

  testWidgets('context.l10n returns the active localizations', (tester) async {
    late AppLocalizations l10n;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(l10n.localeName, 'en');
  });
}
