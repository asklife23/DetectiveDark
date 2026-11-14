import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_visual_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/game_app.dart';

/// Travel without a map (ADR 0017) on the real game screen: the signpost
/// in front of the villa, the market square and the road back (acceptance
/// scenario steps 12, 13 and 20).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  // Semantics finders exist only while a test runs, hence functions.
  Finder sign() => find.bySemanticsLabel('Signpost to the market');
  Finder road() => find.bySemanticsLabel('Road back to the villa');
  final back = find.byTooltip(l10n.backTooltip);

  Finder sprite(String style) => find.byWidgetPredicate(
    (widget) => widget is PlaceholderArt && widget.style == style,
  );

  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  /// Starts in front of the villa; with [hasLetter] the letter from the
  /// hall is already in the notebook.
  Future<void> pumpAtVilla(
    WidgetTester tester, {
    required bool hasLetter,
  }) async {
    await GetIt.instance<ProgressRepository>().save(
      GameProgress(
        caseId: 'case01',
        chapterId: 'ch01',
        sceneStack: const ['villa_exterior'],
        visitedSceneIds: const {'villa_exterior'},
        notes: [
          if (hasLetter)
            const CollectedNote(
              noteId: 'hall_letter',
              addedAtUtcMs: 1,
              isRead: true,
            ),
        ],
      ),
    );
    tester.useLandscapePhone();
    await tester.pumpGame();
  }

  testWidgets('before the letter there is no signpost and no word on it', (
    tester,
  ) async {
    await pumpAtVilla(tester, hasLetter: false);

    expect(sign(), findsNothing);
    expect(sprite(PlaceholderStyles.spriteMarketSign), findsNothing);
    expect(find.text('MARKET'), findsNothing);

    await tester.closeGame();
  });

  testWidgets('with the letter the signpost stands there, with its word', (
    tester,
  ) async {
    await pumpAtVilla(tester, hasLetter: true);

    expect(sign(), findsOneWidget);
    expect(sprite(PlaceholderStyles.spriteMarketSign), findsOneWidget);
    expect(find.text('MARKET'), findsOneWidget);
    // The word sits on the board of the sign.
    final board = tester.getRect(sprite(PlaceholderStyles.spriteMarketSign));
    final word = tester.getRect(find.text('MARKET'));
    expect(board.contains(word.center), isTrue);

    await tester.closeGame();
  });

  testWidgets('the signpost leads to the market square: a main location '
      'without Back', (tester) async {
    await pumpAtVilla(tester, hasLetter: true);

    await tester.tapHotspot('Signpost to the market');

    expect(road(), findsOneWidget);
    expect(back, findsNothing);
    expect(find.text('PHARMACY'), findsOneWidget);
    expect(find.text('CAFÉ'), findsOneWidget);
    expect(find.text('VILLA'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^The market square')), findsOneWidget);
    // The word on the signpost belonged to the villa scene.
    expect(find.text('MARKET'), findsNothing);

    await tester.closeGame();
  });

  testWidgets('the road leads back to the villa', (tester) async {
    await pumpAtVilla(tester, hasLetter: true);
    await tester.tapHotspot('Signpost to the market');

    await tester.tapHotspot('Road back to the villa');

    expect(find.bySemanticsLabel('Front door'), findsOneWidget);
    expect(sign(), findsOneWidget);
    expect(back, findsNothing);

    await tester.closeGame();
  });

  testWidgets('system back in the market asks before leaving the game, like '
      'in any main location', (tester) async {
    await pumpAtVilla(tester, hasLetter: true);
    await tester.tapHotspot('Signpost to the market');

    await tester.binding.handlePopRoute();
    await tester.pumpFor();

    expect(find.text(l10n.exitHint), findsOneWidget);
    expect(road(), findsOneWidget);

    await tester.pumpFor(const Duration(seconds: 3));
    await tester.closeGame();
  });

  testWidgets('the pill bottle in the hall is taken into the item panel', (
    tester,
  ) async {
    await GetIt.instance<ProgressRepository>().save(
      const GameProgress(
        caseId: 'case01',
        chapterId: 'ch01',
        sceneStack: ['villa_exterior', 'villa_door_closeup', 'villa_hall'],
        flags: {'front_door_open'},
        visitedSceneIds: {'villa_exterior', 'villa_door_closeup', 'villa_hall'},
      ),
    );
    tester.useLandscapePhone();
    await tester.pumpGame();
    expect(sprite(PlaceholderStyles.spritePillBottle), findsOneWidget);

    await tester.tapHotspot('Small bottle on the desk');
    await tester.pumpFor(const Duration(seconds: 1));

    expect(find.bySemanticsLabel('Small bottle on the desk'), findsNothing);
    expect(sprite(PlaceholderStyles.spritePillBottle), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ItemSidebar),
        matching: find.bySemanticsLabel('Pill bottle'),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('^A pill bottle')), findsOneWidget);

    await tester.closeGame();
  });

  group('the text of an object', () {
    const signSprite = HotspotSprite(
      rect: NormalizedRect(x: 0.1, y: 0.4, width: 0.1, height: 0.4),
      placeholderStyle: PlaceholderStyles.spriteMarketSign,
      overlays: [
        TextOverlay(
          rect: NormalizedRect(x: 0.11, y: 0.42, width: 0.08, height: 0.06),
          textKey: 'sign',
          style: 'engraved',
        ),
      ],
    );

    Future<void> pumpVisual(
      WidgetTester tester,
      List<HotspotSprite> sprites,
    ) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ContentTextScope(
          texts: const ContentTexts({'sign': 'MARKET', 'number': '17'}),
          child: SizedBox(
            width: 800,
            height: 450,
            child: SceneVisualView(
              visual: const SceneVisual(
                placeholderStyle: PlaceholderStyles.villaExterior,
                overlays: [
                  TextOverlay(
                    rect: NormalizedRect(
                      x: 0.5,
                      y: 0.5,
                      width: 0.1,
                      height: 0.1,
                    ),
                    textKey: 'number',
                    style: 'brass',
                  ),
                ],
              ),
              sprites: sprites,
            ),
          ),
        ),
      ),
    );

    testWidgets('is drawn while the object is in the scene, next to the '
        'text of the scene', (tester) async {
      await pumpVisual(tester, const [signSprite]);

      expect(find.text('MARKET'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
    });

    testWidgets('disappears together with the object', (tester) async {
      await pumpVisual(tester, const [signSprite]);
      await pumpVisual(tester, const []);

      expect(find.text('MARKET'), findsNothing);
      expect(find.text('17'), findsOneWidget);
    });

    testWidgets('lies where the content puts it, relative to the scene '
        'image', (tester) async {
      await pumpVisual(tester, const [signSprite]);

      final scene = tester.getRect(find.byType(SceneVisualView));
      final word = tester.getRect(find.text('MARKET'));
      final box = Rect.fromLTWH(
        scene.left + 0.11 * scene.width,
        scene.top + 0.42 * scene.height,
        0.08 * scene.width,
        0.06 * scene.height,
      );
      expect(box.inflate(0.5).contains(word.center), isTrue);
    });
  });
}
