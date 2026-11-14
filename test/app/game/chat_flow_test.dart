import 'dart:math' as math;

import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/scene_layout.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_bar.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_history_sheet.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/hotspot_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// The inner voice of the detective on the real game screen.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final firstLook = RegExp('^Ashgrove Villa. No lights');
  const locked = 'Locked. Of course it is.';

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  /// Long enough for any message of the slice to be typed, read and gone.
  Future<void> waitUntilBarShrinks(WidgetTester tester) =>
      tester.pumpFor(const Duration(seconds: 8));

  Future<void> openHistory(WidgetTester tester) async {
    await waitUntilBarShrinks(tester);
    await tester.tap(find.byTooltip(l10n.chatTooltip));
    await tester.pumpFor();
  }

  testWidgets('the first scene opens with the first line of the detective', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    expect(find.bySemanticsLabel(firstLook), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('the bar lies on the bottom strip of the scene and covers no '
      'hotspot', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    // The viewport widget includes its dark bars; the scene image is the
    // largest 16:9 box in its middle.
    final area = tester.getRect(find.byType(SceneViewport));
    final viewportHeight = math.min(
      area.height,
      area.width / SceneViewport.aspectRatio,
    );
    final viewportBottom = area.center.dy + viewportHeight / 2;
    final bar = tester.getRect(find.byType(ChatBar));

    expect(bar.bottom, moreOrLessEquals(viewportBottom, epsilon: 0.01));
    expect(
      bar.height,
      moreOrLessEquals(
        viewportHeight * SceneLayout.chatStripHeight,
        epsilon: 0.01,
      ),
    );

    // Every hotspot of every scene of the slice ends above the bar.
    for (final label in ['Front door', 'Garden statue']) {
      await tester.tapHotspot(label);
      final hotspots = find.descendant(
        of: find.byType(HotspotLayer),
        matching: find.byType(GestureDetector),
      );
      for (final element in hotspots.evaluate()) {
        final rect = tester.getRect(find.byWidget(element.widget));
        expect(rect.bottom, lessThanOrEqualTo(bar.top + 0.01), reason: label);
      }
      await tester.tap(find.byTooltip(l10n.backTooltip));
      await tester.pumpFor();
    }

    await tester.closeGame();
  });

  testWidgets('a tap on something says something new', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Front door');

    await tester.tapHotspot('Door lock');

    expect(find.bySemanticsLabel(locked), findsOneWidget);
    expect(find.bySemanticsLabel(firstLook), findsNothing);

    await tester.closeGame();
  });

  testWidgets('the bar shrinks to a button and the scene stays tappable', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();

    await waitUntilBarShrinks(tester);

    expect(find.bySemanticsLabel(firstLook), findsNothing);
    expect(find.byTooltip(l10n.chatTooltip), findsOneWidget);
    await tester.tapHotspot('Front door');
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('the history lists everything said, oldest first', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Front door');
    await tester.tapHotspot('Door lock');

    await openHistory(tester);

    expect(find.byType(ChatHistorySheet), findsOneWidget);
    final first = tester.getTopLeft(find.textContaining(firstLook));
    final second = tester.getTopLeft(find.text(locked));
    expect(first.dy, lessThan(second.dy));

    await tester.closeGame();
  });

  testWidgets('Back and Esc close the history first and leave the scene '
      'alone', (tester) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await tester.tapHotspot('Front door');

    await openHistory(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpFor();
    expect(find.byType(ChatHistorySheet), findsNothing);
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.chatTooltip));
    await tester.pumpFor();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpFor();
    expect(find.byType(ChatHistorySheet), findsNothing);
    expect(find.bySemanticsLabel('Door lock'), findsOneWidget);

    await tester.closeGame();
  });

  testWidgets('the scene cannot be tapped through the open history', (
    tester,
  ) async {
    tester.useLandscapePhone();
    await tester.pumpGame();
    await openHistory(tester);

    await tester.tap(
      find.bySemanticsLabel('Front door'),
      warnIfMissed: false,
    );
    await tester.pumpFor();

    final stack = GetIt.instance<ProgressRepository>().current!.sceneStack;
    expect(stack, ['villa_exterior']);
    await tester.closeGame();
  });
}
