import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/app/dev/dev_actions.dart';
import 'package:detective_dark/app/dev/dev_menu_cubit.dart';
import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/app/dev/dev_preset_source.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/features/dialogue/data/repositories/asset_dialogue_catalog_repository.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/data/models/codec_rule_parser.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/game_app.dart';
import '../../helpers/game_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const caseId = ContentPaths.defaultCaseId;
  const presetJson =
      '{"formatVersion": 1, "presets": [{"id": "market", '
      '"scene": "market_square", "items": ["pill_bottle"]}]}';

  late GameHarness game;

  /// A menu cubit on [bundle], wired like `createDevMenuCubit` does.
  DevMenuCubit cubitOn(
    AssetBundle bundle, {
    ProgressRepository? progressRepository,
  }) {
    final source = ContentAssetSource(bundle);
    game = GameHarness(
      contentRepository: AssetSceneContentRepository(source),
      progressRepository: progressRepository,
    );
    return DevMenuCubit(
      caseId: caseId,
      contentRepository: game.content,
      itemCatalog: AssetItemCatalogRepository(source),
      noteCatalog: AssetNoteCatalogRepository(source),
      dialogueCatalog: AssetDialogueCatalogRepository(
        source,
        const CodecRuleParser(),
      ),
      presetSource: DevPresetSource(bundle),
      progressRepository: game.progress,
      saveCodec: const JsonSaveCodec(),
      actions: DevActions(
        pipeline: game.pipeline,
        enterScene: game.enterScene,
        progressRepository: game.progress,
        clock: GameHarness.clock,
      ),
    );
  }

  FakeAssetBundle bundleWithPresets() => FakeAssetBundle({
    ...realContentBundle().files,
    DevPresetSource.path: presetJson,
  });

  /// A cubit with a running game, loaded and ready.
  Future<DevMenuCubit> readyCubit() async {
    final cubit = cubitOn(bundleWithPresets());
    await game.startGame(caseId);
    await cubit.load();
    return cubit;
  }

  tearDown(() => game.dispose());

  blocTest<DevMenuCubit, DevMenuState>(
    'load shows the catalog, the presets and the running game',
    build: () => cubitOn(bundleWithPresets()),
    act: (cubit) async {
      await game.startGame(caseId);
      await cubit.load();
    },
    verify: (cubit) {
      final state = cubit.state;
      expect(state.status, DevMenuStatus.ready);
      expect(state.catalog!.sceneIds, contains('market_square'));
      expect(state.catalog!.flags, contains('front_door_open'));
      expect(state.presets.single.id, 'market');
      expect(state.progress!.currentSceneId, 'villa_exterior');
      expect(state.actionFailed, isFalse);
    },
  );

  blocTest<DevMenuCubit, DevMenuState>(
    'a build without the preset file has an empty preset list',
    build: () => cubitOn(realContentBundle()),
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, DevMenuStatus.ready);
      expect(cubit.state.presets, isEmpty);
    },
  );

  blocTest<DevMenuCubit, DevMenuState>(
    'content that cannot be loaded ends in failed',
    build: () => cubitOn(FakeAssetBundle({})),
    act: (cubit) => cubit.load(),
    expect: () => [const DevMenuState(status: DevMenuStatus.failed)],
  );

  test('an action before loading does nothing', () async {
    final cubit = cubitOn(bundleWithPresets());
    addTearDown(cubit.close);

    expect(await cubit.jumpTo('villa_hall'), isFalse);
    expect(game.progress.current, isNull);
  });

  test('adding an item reports success and the state follows the '
      'progress', () async {
    final cubit = await readyCubit();
    addTearDown(cubit.close);

    expect(await cubit.giveItem('pill_bottle'), isTrue);
    await pumpEventQueue();

    expect(cubit.state.progress!.inventory, ['pill_bottle']);
    expect(cubit.state.actionFailed, isFalse);
  });

  test('note, flag, jump, preset and reset all work on the game', () async {
    final cubit = await readyCubit();
    addTearDown(cubit.close);

    expect(await cubit.addNote('hall_letter'), isTrue);
    expect(await cubit.setFlag('front_door_open'), isTrue);
    expect(await cubit.jumpTo('villa_hall'), isTrue);
    await pumpEventQueue();
    expect(cubit.state.progress!.currentSceneId, 'villa_hall');
    expect(cubit.state.progress!.hasNote('hall_letter'), isTrue);
    expect(cubit.state.progress!.hasFlag('front_door_open'), isTrue);

    expect(await cubit.loadPreset(cubit.state.presets.single), isTrue);
    await pumpEventQueue();
    expect(cubit.state.progress!.currentSceneId, 'market_square');
    expect(cubit.state.progress!.inventory, ['pill_bottle']);
    expect(cubit.state.progress!.hasNote('hall_letter'), isFalse);

    expect(await cubit.reset(), isTrue);
    await pumpEventQueue();
    expect(cubit.state.progress!.currentSceneId, 'villa_exterior');
    expect(cubit.state.progress!.inventory, isEmpty);
  });

  test('a failed action is reported and a later success clears it', () async {
    final cubit = await readyCubit();
    addTearDown(cubit.close);

    expect(await cubit.jumpTo('nowhere'), isFalse);
    expect(cubit.state.actionFailed, isTrue);

    expect(await cubit.jumpTo('villa_hall'), isTrue);
    expect(cubit.state.actionFailed, isFalse);
  });

  group('the save as text', () {
    const codec = JsonSaveCodec();

    test('export hands out the running game in the save format', () async {
      final cubit = await readyCubit();
      addTearDown(cubit.close);
      await cubit.giveItem('pill_bottle');

      final text = cubit.exportSave();

      expect(codec.decode(text!).valueOrNull, game.progress.current);
      expect(cubit.state.saveCopied, isTrue);
      expect(cubit.state.actionFailed, isFalse);
    });

    test('export without a running game gives nothing and is reported', () {
      final cubit = cubitOn(bundleWithPresets());
      addTearDown(cubit.close);

      expect(cubit.exportSave(), isNull);
      expect(cubit.state.saveCopied, isFalse);
      expect(cubit.state.actionFailed, isTrue);
    });

    test('import brings back the exported state', () async {
      final cubit = await readyCubit();
      addTearDown(cubit.close);
      await cubit.jumpTo('villa_hall');
      final text = cubit.exportSave()!;
      final exported = game.progress.current;

      await cubit.reset();
      expect(await cubit.importSave(text), isTrue);
      await pumpEventQueue();

      expect(game.progress.current, exported);
      expect(cubit.state.progress, exported);
      expect(cubit.state.saveCopied, isFalse);
      expect(cubit.state.actionFailed, isFalse);
    });

    test('a text that is not a readable save changes nothing and is '
        'reported', () async {
      final cubit = await readyCubit();
      addTearDown(cubit.close);
      final before = game.progress.current;
      final tooNew = jsonEncode({
        ...jsonDecode(cubit.exportSave()!) as Map<String, dynamic>,
        'schemaVersion': codec.version + 1,
      });

      for (final text in [null, '', 'not a save', tooNew]) {
        expect(await cubit.importSave(text), isFalse);
        expect(cubit.state.actionFailed, isTrue);
        expect(cubit.state.saveCopied, isFalse);
        expect(game.progress.current, before);
      }
    });

    test('a save of another case is refused', () async {
      final cubit = await readyCubit();
      addTearDown(cubit.close);
      final before = game.progress.current;
      final foreign = codec.encode(
        const GameProgress(
          caseId: 'case99',
          chapterId: 'ch01',
          sceneStack: ['villa_exterior'],
        ),
      );

      expect(await cubit.importSave(foreign), isFalse);
      expect(cubit.state.actionFailed, isTrue);
      expect(game.progress.current, before);
    });
  });

  test('a failed save changes nothing and is reported', () async {
    const stored = GameProgress(
      caseId: caseId,
      chapterId: 'ch01',
      sceneStack: ['villa_exterior'],
    );
    final repository = FailingProgressRepository(stored: stored);
    final cubit = cubitOn(bundleWithPresets(), progressRepository: repository);
    addTearDown(cubit.close);
    await cubit.load();

    expect(await cubit.giveItem('pill_bottle'), isFalse);
    expect(
      await cubit.loadPreset(const DevPreset(id: 'x', sceneId: 'villa_hall')),
      isFalse,
    );

    expect(repository.saveCalls, 2);
    expect(cubit.state.actionFailed, isTrue);
    expect(cubit.state.progress, stored);
  });
}
