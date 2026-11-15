import 'package:detective_dark/app/dev/dev_actions.dart';
import 'package:detective_dark/app/dev/dev_catalog.dart';
import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/content_validation.dart';
import '../../helpers/game_harness.dart';

/// The developer menu actions on the real content, without any UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const caseId = ContentPaths.defaultCaseId;

  late GameHarness game;
  late CaseContent content;
  late DevActions actions;

  /// Counts the saves: every action must be exactly one.
  late List<GameProgress> saves;

  setUp(() async {
    game = GameHarness();
    actions = DevActions(
      pipeline: game.pipeline,
      enterScene: game.enterScene,
      progressRepository: game.progress,
      clock: GameHarness.clock,
    );
    final started = await game.startGame(caseId);
    content = started.valueOrNull!.content;
    await pumpEventQueue();
    game.events.clear();
    saves = [];
    game.progress.watch().skip(1).listen(saves.add);
  });

  tearDown(() => game.dispose());

  GameProgress progress() => game.progress.current!;

  group('jumpTo', () {
    test('moves into a close-up with its whole parent chain', () async {
      final result = await actions.jumpTo(content, 'villa_hall');
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      expect(progress().sceneStack, [
        'villa_exterior',
        'villa_door_closeup',
        'villa_hall',
      ]);
      expect(progress().hasVisited('villa_hall'), isTrue);
      expect(saves, hasLength(1));
    });

    test('runs through the pipeline: the scene is announced and its first '
        'line is said', () async {
      await actions.jumpTo(content, 'market_square');
      await pumpEventQueue();

      expect(
        game.events.first,
        const SceneEntered('market_square', isFirstVisit: true),
      );
      expect(game.events.whereType<DetectiveSaid>(), isNotEmpty);
    });

    test('keeps what the player has', () async {
      await actions.giveItem(content, 'pill_bottle');
      await actions.jumpTo(content, 'market_square');

      expect(progress().inventory, ['pill_bottle']);
    });

    test('an unknown scene fails and changes nothing', () async {
      final before = progress();

      final result = await actions.jumpTo(content, 'nowhere');
      await pumpEventQueue();

      expect(result, isA<Failed<void>>());
      expect(progress(), before);
      expect(saves, isEmpty);
    });
  });

  group('adding', () {
    test('an item arrives through the giveItem effect', () async {
      final result = await actions.giveItem(content, 'brass_key');
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      expect(progress().inventory, ['brass_key']);
      expect(game.events.whereType<ItemObtained>().single.itemId, 'brass_key');
      expect(saves, hasLength(1));
    });

    test('a note arrives unread', () async {
      await actions.addNote(content, 'hall_letter');
      await pumpEventQueue();

      expect(progress().hasNote('hall_letter'), isTrue);
      expect(progress().unreadNoteCount, 1);
      expect(game.events.whereType<NoteAdded>().single.noteId, 'hall_letter');
    });

    test('a flag is set', () async {
      await actions.setFlag(content, 'front_door_open');

      expect(progress().hasFlag('front_door_open'), isTrue);
    });

    test('adding what is already there saves nothing', () async {
      await actions.setFlag(content, 'front_door_open');
      await pumpEventQueue();
      saves.clear();

      await actions.setFlag(content, 'front_door_open');
      await pumpEventQueue();

      expect(saves, isEmpty);
    });
  });

  test('reset starts the case again in the entry scene', () async {
    await actions.giveItem(content, 'brass_key');
    await actions.setFlag(content, 'front_door_open');
    await actions.jumpTo(content, 'villa_hall');
    await pumpEventQueue();
    saves.clear();

    final result = await actions.reset(content);
    await pumpEventQueue();

    expect(result.isSuccess, isTrue);
    expect(progress().sceneStack, ['villa_exterior']);
    expect(progress().inventory, isEmpty);
    expect(progress().flags, isEmpty);
    expect(progress().visitedSceneIds, {'villa_exterior'});
    expect(saves, hasLength(1));
  });

  group('loadPreset', () {
    const preset = DevPreset(
      id: 'market_with_pills',
      sceneId: 'market_square',
      itemIds: ['pill_bottle'],
      noteIds: ['hall_letter'],
      flags: ['front_door_open'],
    );

    test('replaces the progress with the preset, in one save', () async {
      await actions.giveItem(content, 'brass_key');
      await pumpEventQueue();
      saves.clear();

      final result = await actions.loadPreset(content, preset);
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      expect(progress().sceneStack, ['market_square']);
      expect(progress().inventory, ['pill_bottle']);
      expect(progress().hasNote('hall_letter'), isTrue);
      expect(progress().flags, {'front_door_open'});
      expect(progress().chapterId, 'ch01');
      expect(saves, hasLength(1));
    });

    test('announces the arrival but no pickups (nothing flies)', () async {
      await actions.loadPreset(content, preset);
      await pumpEventQueue();

      expect(
        game.events.whereType<SceneEntered>().single.sceneId,
        'market_square',
      );
      expect(game.events.whereType<ItemObtained>(), isEmpty);
      expect(game.events.whereType<NoteAdded>(), isEmpty);
    });
  });

  test('without a running game nothing happens', () async {
    final empty = GameHarness();
    addTearDown(empty.dispose);
    final idle = DevActions(
      pipeline: empty.pipeline,
      enterScene: empty.enterScene,
      progressRepository: empty.progress,
      clock: GameHarness.clock,
    );

    expect(await idle.jumpTo(content, 'villa_hall'), isA<Failed<void>>());
    expect(await idle.giveItem(content, 'brass_key'), isA<Failed<void>>());
    expect(empty.progress.current, isNull);
  });

  group('DevCatalog', () {
    late DevCatalog catalog;

    setUp(() async {
      final loaded = await loadCaseForValidation(
        ContentAssetSource(rootBundle),
        caseId,
      );
      catalog = DevCatalog.fromContent(
        content: loaded.content,
        itemIds: loaded.items.keys,
        noteIds: loaded.notes.keys,
        dialogues: loaded.dialogues.values,
      );
    });

    test('lists what the content has, sorted', () {
      expect(catalog.sceneIds, contains('market_square'));
      expect(catalog.sceneIds, orderedEquals([...catalog.sceneIds]..sort()));
      expect(catalog.itemIds, containsAll(['brass_key', 'pill_bottle']));
      expect(catalog.noteIds, contains('hall_letter'));
      expect(catalog.flags, contains('front_door_open'));
    });

    test('accepts a preset that names only existing things', () {
      expect(
        catalog.problemsOf(
          const DevPreset(
            id: 'ok',
            sceneId: 'market_square',
            itemIds: ['pill_bottle'],
            noteIds: ['hall_letter'],
            flags: ['front_door_open'],
          ),
        ),
        isEmpty,
      );
    });

    test('names every unknown scene, item, note and flag', () {
      final problems = catalog.problemsOf(
        const DevPreset(
          id: 'broken',
          sceneId: 'moon',
          itemIds: ['pill_bottle', 'laser'],
          noteIds: ['diary'],
          flags: ['front_door_opne'],
        ),
      );

      expect(problems, [
        'preset "broken": unknown scene "moon"',
        'preset "broken": unknown item "laser"',
        'preset "broken": unknown note "diary"',
        'preset "broken": unknown flag "front_door_opne"',
      ]);
    });
  });
}
