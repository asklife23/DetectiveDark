import 'package:detective_dark/app/game/game_status_views.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  /// Shows the error view for [failure] and returns how often its button
  /// was pressed so far.
  Future<int Function()> pumpError(
    WidgetTester tester,
    Failure? failure,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GameErrorView(failure: failure, onRetry: () => presses++),
        ),
      ),
    );
    return () => presses;
  }

  group('GameErrorView', () {
    testWidgets('a save from a newer build asks the player to update', (
      tester,
    ) async {
      final presses = await pumpError(
        tester,
        const SaveTooNewFailure(savedVersion: 2, supportedVersion: 1),
      );

      expect(find.text(l10n.saveTooNewTitle), findsOneWidget);
      expect(find.text(l10n.saveTooNewBody), findsOneWidget);
      expect(find.text(l10n.newGameButton), findsNothing);

      await tester.tap(find.text(l10n.retryButton));
      expect(presses(), 1);
    });

    testWidgets('a save that cannot be read offers a new game', (tester) async {
      final presses = await pumpError(
        tester,
        const SaveCorruptFailure('broken'),
      );

      expect(find.text(l10n.saveCorruptTitle), findsOneWidget);
      expect(find.text(l10n.saveCorruptBody), findsOneWidget);
      expect(find.text(l10n.retryButton), findsNothing);

      await tester.tap(find.text(l10n.newGameButton));
      expect(presses(), 1);
    });

    for (final (name, failure) in <(String, Failure?)>[
      ('content that cannot be loaded', const ContentFailure('missing')),
      ('texts that cannot be loaded (no failure)', null),
    ]) {
      testWidgets('$name shows the general message with retry', (tester) async {
        final presses = await pumpError(tester, failure);

        expect(find.text(l10n.gameLoadFailed), findsOneWidget);
        expect(find.text(l10n.saveTooNewBody), findsNothing);
        expect(find.text(l10n.saveCorruptBody), findsNothing);

        await tester.tap(find.text(l10n.retryButton));
        expect(presses(), 1);
      });
    }

    testWidgets('the texts fit a landscape phone', (tester) async {
      tester.view
        ..physicalSize = const Size(2400, 1080)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await pumpError(tester, const SaveCorruptFailure('broken'));

      expect(tester.takeException(), isNull);
    });
  });
}
