import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameHarness game;
  late CaseContent content;

  setUp(() async {
    game = GameHarness();
    content = (await game.content.loadCase('case01')).valueOrNull!;
  });
  tearDown(() => game.dispose());

  GameProgress at(List<String> stack) => newGame.withSceneStack(stack);

  group('StartGame', () {
    test('a new game enters the entry scene and saves once', () async {
      final started = (await game.startGame('case01')).valueOrNull!;
      await pumpEventQueue();

      expect(started.progress.sceneStack, ['villa_exterior']);
      expect(started.progress.chapterId, 'ch01');
      expect(started.progress.hasVisited('villa_exterior'), isTrue);
      expect(game.progress.current, started.progress);
      expect(game.events, const [
        SceneEntered('villa_exterior', isFirstVisit: true),
        DetectiveSaid('say_villa_first_look'),
      ]);
    });

    test('a stored game is continued without events', () async {
      final stored = at([
        'villa_exterior',
        'statue_closeup',
      ]).withVisited('statue_closeup');
      final continued = GameHarness(
        progressRepository: InMemoryProgressRepository(initial: stored),
      );

      final started = (await continued.startGame('case01')).valueOrNull!;
      await pumpEventQueue();

      expect(started.progress, stored);
      expect(continued.events, isEmpty);
    });

    test('a save that points at a removed scene starts over', () async {
      final broken = GameHarness(
        progressRepository: InMemoryProgressRepository(
          initial: at(['demolished_wing']),
        ),
      );

      final started = (await broken.startGame('case01')).valueOrNull!;

      expect(started.progress.sceneStack, ['villa_exterior']);
    });

    test('an unknown case is a content failure', () async {
      final result = await game.startGame('case99');

      expect(result.failureOrNull, isA<ContentFailure>());
    });
  });

  group('EnterScene', () {
    test(
      'sets the stack to the chain of parents and marks the visit',
      () async {
        final result = await game.enterScene(
          content: content,
          progress: at(['villa_exterior']),
          sceneId: 'villa_hall',
        );
        await pumpEventQueue();

        final progress = result.valueOrNull!;
        expect(progress.sceneStack, [
          'villa_exterior',
          'villa_door_closeup',
          'villa_hall',
        ]);
        expect(progress.hasVisited('villa_hall'), isTrue);
        expect(game.events, const [
          SceneEntered('villa_hall', isFirstVisit: true),
        ]);
      },
    );

    test('first-enter effects run only on the first visit', () async {
      final first = await game.enterScene(
        content: content,
        progress: at(const []),
        sceneId: 'villa_exterior',
      );
      final second = await game.enterScene(
        content: content,
        progress: first.valueOrNull!,
        sceneId: 'villa_exterior',
      );
      await pumpEventQueue();

      expect(second.valueOrNull!.chatLog, hasLength(1));
      expect(
        game.events.last,
        const SceneEntered(
          'villa_exterior',
          isFirstVisit: false,
        ),
      );
    });

    test('an unknown scene fails and saves nothing', () async {
      final result = await game.enterScene(
        content: content,
        progress: at(['villa_exterior']),
        sceneId: 'cellar',
      );

      expect(result.failureOrNull, isA<ContentFailure>());
      expect(game.progress.current, isNull);
    });

    test('when the save fails no event is published', () async {
      final failing = GameHarness(
        progressRepository: FailingProgressRepository(),
      );

      final result = await failing.enterScene(
        content: content,
        progress: at(const []),
        sceneId: 'villa_exterior',
      );
      await pumpEventQueue();

      expect(result.failureOrNull, isA<StorageFailure>());
      expect(failing.events, isEmpty);
    });
  });

  group('TapHotspot', () {
    final statue = at(['villa_exterior', 'statue_closeup']);

    test('applies all effects of the rule in one save', () async {
      var saves = 0;
      game.progress.watch().listen((_) => saves++);

      final outcome = (await game.tapHotspot(
        scene: content.scenes['statue_closeup']!,
        progress: statue,
        hotspotId: 'statue_key',
      )).valueOrNull!;
      await pumpEventQueue();

      expect(saves, 1);
      expect(outcome.progress.hasItem('brass_key'), isTrue);
      expect(
        outcome.progress.isHotspotHidden('statue_closeup', 'statue_key'),
        isTrue,
      );
      expect(game.progress.current, outcome.progress);
    });

    test('returns navigation without changing the stack itself', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['villa_exterior']!,
        progress: at(['villa_exterior']),
        hotspotId: 'door',
      )).valueOrNull!;

      expect(outcome.navigation, const GoToScene('villa_door_closeup'));
      expect(outcome.progress.sceneStack, ['villa_exterior']);
      // Nothing changed, so nothing was saved.
      expect(game.progress.current, isNull);
    });

    test('a hidden hotspot cannot be tapped', () async {
      final taken = statue.withHiddenHotspot('statue_closeup', 'statue_key');

      final outcome = (await game.tapHotspot(
        scene: content.scenes['statue_closeup']!,
        progress: taken,
        hotspotId: 'statue_key',
      )).valueOrNull!;

      expect(outcome.progress, same(taken));
    });

    test('a hotspot whose visibleWhen is false cannot be tapped', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['villa_door_closeup']!,
        progress: at(['villa_exterior', 'villa_door_closeup']),
        hotspotId: 'doorway',
      )).valueOrNull!;

      expect(outcome.navigation, isNull);
    });

    test('an unknown hotspot does nothing', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['statue_closeup']!,
        progress: statue,
        hotspotId: 'bird',
      )).valueOrNull!;

      expect(outcome.progress, same(statue));
    });

    test('when the save fails no event is published', () async {
      final failing = GameHarness(
        progressRepository: FailingProgressRepository(),
      );

      final result = await failing.tapHotspot(
        scene: content.scenes['statue_closeup']!,
        progress: statue,
        hotspotId: 'statue_key',
      );
      await pumpEventQueue();

      expect(result.failureOrNull, isA<StorageFailure>());
      expect(failing.events, isEmpty);
    });
  });

  group('talk (ADR 0016)', () {
    test('a tap on a character asks for the conversation and saves '
        'nothing', () async {
      final inMarket = at(['market_square']);

      final outcome = (await game.tapHotspot(
        scene: content.scenes['market_square']!,
        progress: inMarket,
        hotspotId: 'pharmacist',
      )).valueOrNull!;
      await pumpEventQueue();

      expect(outcome.dialogueId, 'pharmacist');
      expect(outcome.progress, same(inMarket));
      expect(outcome.navigation, isNull);
      expect(game.progress.current, isNull);
      expect(game.events, isEmpty);
    });

    test('the two characters open their own conversations', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['market_square']!,
        progress: at(['market_square']),
        hotspotId: 'cafe_owner',
      )).valueOrNull!;

      expect(outcome.dialogueId, 'cafe_owner');
    });
  });

  group('showing an item to a character (ADR 0016)', () {
    test('a tap with an item selected opens the conversation with the '
        'item to show; nothing is said, used or saved', () async {
      final inMarket = at(['market_square']).withItem('pill_bottle');

      final outcome = (await game.tapHotspot(
        scene: content.scenes['market_square']!,
        progress: inMarket,
        hotspotId: 'pharmacist',
        usingItemId: 'pill_bottle',
      )).valueOrNull!;
      await pumpEventQueue();

      expect(outcome.dialogueId, 'pharmacist');
      expect(outcome.shownItemId, 'pill_bottle');
      expect(outcome.progress, same(inMarket));
      expect(game.events, isEmpty);
    });

    test('an item the player does not carry is not shown', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['market_square']!,
        progress: at(['market_square']),
        hotspotId: 'pharmacist',
        usingItemId: 'pill_bottle',
      )).valueOrNull!;

      expect(outcome.dialogueId, 'pharmacist');
      expect(outcome.shownItemId, isNull);
    });

    test('an item on something that is not a character still gets the '
        'generic reaction', () async {
      final outcome = (await game.tapHotspot(
        scene: content.scenes['market_square']!,
        progress: at(['market_square']).withItem('pill_bottle'),
        hotspotId: 'villa_road',
        usingItemId: 'pill_bottle',
      )).valueOrNull!;

      expect(outcome.dialogueId, isNull);
      expect(outcome.shownItemId, isNull);
      expect(outcome.navigation, isNull);
      expect(outcome.progress.chatLog.last.textKey, 'generic_item_no_effect');
    });
  });
}
