import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_asset_bundle.dart';
import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameHarness game;

  setUp(() => game = GameHarness());
  tearDown(() => game.dispose());

  blocTest<SceneBloc, SceneState>(
    'starts in loading and becomes ready in the entry scene',
    build: () => game.createBloc(),
    act: (bloc) => bloc.add(const SceneStarted()),
    expect: () => [
      const SceneState(),
      isA<SceneState>()
          .having((s) => s.status, 'status', SceneStatus.ready)
          .having((s) => s.scene?.id, 'scene', 'villa_exterior'),
    ],
  );

  blocTest<SceneBloc, SceneState>(
    'content that cannot be loaded ends in failed with the failure',
    build: () => GameHarness(
      contentRepository: AssetSceneContentRepository(
        ContentAssetSource(FakeAssetBundle({})),
      ),
    ).createBloc(),
    act: (bloc) => bloc.add(const SceneStarted()),
    skip: 1,
    expect: () => [
      isA<SceneState>()
          .having((s) => s.status, 'status', SceneStatus.failed)
          .having((s) => s.failure, 'failure', isA<ContentFailure>()),
    ],
  );

  test('continues a stored game where it was left', () async {
    final stored = newGame
        .withSceneStack(['villa_exterior', 'statue_closeup'])
        .withVisited('villa_exterior')
        .withVisited('statue_closeup');
    final bloc = GameHarness(
      progressRepository: InMemoryProgressRepository(initial: stored),
    ).createBloc();
    addTearDown(bloc.close);

    await bloc.start();

    expect(bloc.sceneId, 'statue_closeup');
    expect(bloc.state.canGoBack, isTrue);
    expect(bloc.state.progress!.chatLog, isEmpty);
  });

  group('transitions', () {
    test('a fade goes idle → covering → revealing → idle and swaps the scene '
        'only when the screen is black', () async {
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();

      bloc.add(const HotspotTapped('door'));
      await bloc.settle();
      expect(bloc.state.transitionPhase, TransitionPhase.covering);
      expect(bloc.state.pendingSceneId, 'villa_door_closeup');
      expect(bloc.state.pendingTransition, SceneTransition.standard);
      expect(bloc.sceneId, 'villa_exterior');

      bloc.add(const TransitionCovered());
      await bloc.settle();
      expect(bloc.state.transitionPhase, TransitionPhase.revealing);
      expect(bloc.sceneId, 'villa_door_closeup');

      bloc.add(const TransitionFinished());
      await bloc.settle();
      expect(bloc.state.transitionPhase, TransitionPhase.idle);
      expect(bloc.state.pendingTransition, isNull);
      expect(bloc.state.pendingSceneId, isNull);
    });

    test('a second tap during a transition is ignored', () async {
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();

      bloc
        ..add(const HotspotTapped('door'))
        ..add(const HotspotTapped('statue'));
      await bloc.settle();
      expect(bloc.state.pendingSceneId, 'villa_door_closeup');

      await bloc.finishTransition();
      expect(bloc.sceneId, 'villa_door_closeup');
    });

    test('Back during a transition is ignored', () async {
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();
      await bloc.tap('door');

      bloc
        ..add(const HotspotTapped('lock'))
        ..add(const BackPressed())
        ..add(const BackPressed());
      await bloc.settle();
      await bloc.finishTransition();

      expect(bloc.sceneId, 'villa_exterior');
      expect(bloc.state.transitionPhase, TransitionPhase.idle);
    });

    test(
      'stray transition events without a transition change nothing',
      () async {
        final bloc = game.createBloc();
        addTearDown(bloc.close);
        await bloc.start();
        final before = bloc.state;

        bloc
          ..add(const TransitionCovered())
          ..add(const TransitionFinished());
        await bloc.settle();

        expect(bloc.state, before);
      },
    );
  });

  test('two quick taps on a pickup give the item once', () async {
    final bloc = game.createBloc();
    addTearDown(bloc.close);
    await bloc.start();
    await bloc.tap('statue');

    bloc
      ..add(const HotspotTapped('statue_key'))
      ..add(const HotspotTapped('statue_key'));
    await bloc.settle();

    final progress = bloc.state.progress!;
    expect(progress.inventory, ['brass_key']);
    expect(
      progress.chatLog.where((e) => e.textKey == 'say_statue_key_found'),
      hasLength(1),
    );
  });

  test('Back in a main scene does nothing', () async {
    final bloc = game.createBloc();
    addTearDown(bloc.close);
    await bloc.start();
    final before = bloc.state;

    await bloc.back();

    expect(bloc.state, before);
  });

  test('an item the player does not carry cannot be used', () async {
    final bloc = game.createBloc();
    addTearDown(bloc.close);
    await bloc.start();
    await bloc.tap('door');

    await bloc.tap('lock', usingItemId: 'brass_key');

    expect(bloc.state.progress!.hasFlag('front_door_open'), isFalse);
    expect(bloc.state.progress!.chatLog.last.textKey, 'say_door_locked');
  });

  group('inspection', () {
    Future<SceneBloc> atOpenPlaque() async {
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();
      await bloc.tap('statue');
      await bloc.tap('statue_plaque');
      return bloc;
    }

    test('is not written to the progress', () async {
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();
      await bloc.tap('statue');
      final before = bloc.state.progress;

      await bloc.tap('statue_plaque');

      expect(bloc.state.activeInspection, isNotNull);
      expect(bloc.state.progress, before);
    });

    test('hotspot taps are ignored while the panel is open', () async {
      final bloc = await atOpenPlaque();

      await bloc.tap('statue_key');

      expect(bloc.state.progress!.inventory, isEmpty);
      expect(bloc.state.activeInspection, isNotNull);
    });

    test('InspectionClosed closes the panel and keeps the scene', () async {
      final bloc = await atOpenPlaque();

      bloc.add(const InspectionClosed());
      await bloc.settle();

      expect(bloc.state.activeInspection, isNull);
      expect(bloc.sceneId, 'statue_closeup');
    });

    test('InspectionRequested opens a panel from outside the scene', () async {
      const card = InspectionDefinition(
        id: 'item:brass_key',
        textKey: 'item_brass_key_description',
        visual: SceneVisual(placeholderStyle: 'item_brass_key'),
      );
      final bloc = game.createBloc();
      addTearDown(bloc.close);
      await bloc.start();

      bloc.add(const InspectionRequested(card));
      await bloc.settle();
      expect(bloc.state.activeInspection, card);
      expect(bloc.state.acceptsTaps, isFalse);

      await bloc.back();
      expect(bloc.state.activeInspection, isNull);
    });
  });

  test('a change saved by another feature redraws the scene', () async {
    final bloc = game.createBloc();
    addTearDown(bloc.close);
    await bloc.start();
    await bloc.tap('door');
    expect(bloc.hotspotIds, ['lock']);

    await game.progress.save(
      bloc.state.progress!.withFlag('front_door_open'),
    );
    await bloc.settle();

    expect(bloc.hotspotIds, ['doorway']);
    expect(bloc.state.visual!.placeholderStyle, 'villa_door_open');
  });

  test('a failed save keeps the state and reports the error', () async {
    final failing = FailingProgressRepository(
      stored: newGame.withVisited('villa_exterior'),
    );
    final bloc = GameHarness(progressRepository: failing).createBloc();
    addTearDown(bloc.close);
    await bloc.start();
    final before = bloc.state;

    // Navigation needs a save when the new scene is entered.
    await bloc.tap('door');

    expect(failing.saveCalls, 1);
    expect(bloc.sceneId, 'villa_exterior');
    expect(bloc.state.transitionPhase, TransitionPhase.idle);
    expect(bloc.state.progress, before.progress);
  });

  group('travel between places (ADR 0017)', () {
    /// A game that stands in front of the villa with the letter read: the
    /// signpost to the market has appeared.
    Future<SceneBloc> blocWithLetter() async {
      final stored = newGame
          .withVisited('villa_exterior')
          .withNote(
            const CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 1),
          );
      final travelling = GameHarness(
        progressRepository: InMemoryProgressRepository(initial: stored),
      );
      addTearDown(travelling.dispose);
      final bloc = travelling.createBloc();
      addTearDown(bloc.close);
      await bloc.start();
      return bloc;
    }

    test(
      'the signpost appears only once the letter is in the notebook',
      () async {
        final without = game.createBloc();
        addTearDown(without.close);
        await without.start();
        final withLetter = await blocWithLetter();

        expect(without.hotspotIds, isNot(contains('market_sign')));
        expect(withLetter.hotspotIds, contains('market_sign'));
      },
    );

    test('the market is a main location: no Back', () async {
      final bloc = await blocWithLetter();

      await bloc.tap('market_sign');

      expect(bloc.sceneId, 'market_square');
      expect(bloc.state.stack, ['market_square']);
      expect(bloc.state.canGoBack, isFalse);
      expect(
        bloc.state.progress!.chatLog.last.textKey,
        'say_market_first_look',
      );

      // Back does nothing here.
      await bloc.back();
      expect(bloc.sceneId, 'market_square');
    });

    test('the road leads back to the villa, again without Back', () async {
      final bloc = await blocWithLetter();
      await bloc.tap('market_sign');

      await bloc.tap('villa_road');

      expect(bloc.sceneId, 'villa_exterior');
      expect(bloc.state.stack, ['villa_exterior']);
      expect(bloc.state.canGoBack, isFalse);
      expect(bloc.hotspotIds, contains('market_sign'));
    });

    test('the first look at the market is commented once', () async {
      final bloc = await blocWithLetter();
      await bloc.tap('market_sign');
      await bloc.tap('villa_road');
      await bloc.tap('market_sign');

      final lines = [
        for (final entry in bloc.state.progress!.chatLog) entry.textKey,
      ];
      expect(
        lines.where((key) => key == 'say_market_first_look'),
        hasLength(1),
      );
    });
  });
}
