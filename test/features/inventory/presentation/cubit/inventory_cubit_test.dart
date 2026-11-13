import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_asset_bundle.dart';
import '../../../../helpers/game_app.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  late InMemoryProgressRepository progress;

  InventoryCubit build({ContentAssetSource? source}) => InventoryCubit(
    catalogRepository: AssetItemCatalogRepository(
      source ?? ContentAssetSource(realContentBundle()),
    ),
    progressRepository: progress,
    caseId: 'case01',
  );

  List<String> ids(InventoryState state) => [
    for (final item in state.items) item.id,
  ];

  setUp(() => progress = InMemoryProgressRepository());
  tearDown(() => progress.dispose());

  blocTest<InventoryCubit, InventoryState>(
    'starts empty',
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(cubit.state, const InventoryState()),
  );

  blocTest<InventoryCubit, InventoryState>(
    'shows a collected item with its catalog data',
    build: build,
    act: (cubit) async {
      await cubit.load();
      await progress.save(newGame.withItem(brassKey));
    },
    verify: (cubit) {
      expect(ids(cubit.state), [brassKey]);
      expect(cubit.state.items.single.nameKey, 'item_brass_key_name');
      expect(cubit.state.selectedItemId, isNull);
    },
  );

  blocTest<InventoryCubit, InventoryState>(
    'shows the items of a game that is already running',
    setUp: () => progress.save(newGame.withItem(brassKey)),
    build: build,
    act: (cubit) => cubit.load(),
    verify: (cubit) => expect(ids(cubit.state), [brassKey]),
  );

  group('selection', () {
    Future<InventoryCubit> withKey() async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();
      await progress.save(newGame.withItem(brassKey));
      await pumpEventQueue();
      return cubit;
    }

    test('a tap selects, a second tap puts the item back', () async {
      final cubit = await withKey();

      cubit.toggle(brassKey);
      expect(cubit.state.selectedItemId, brassKey);

      cubit.toggle(brassKey);
      expect(cubit.state.selectedItemId, isNull);
    });

    test('an item the player does not carry cannot be selected', () async {
      final cubit = await withKey();

      cubit.toggle(crowbar);

      expect(cubit.state.selectedItemId, isNull);
    });

    test('clearSelection drops the selection and keeps the items', () async {
      final cubit = await withKey()
        ..toggle(brassKey)
        ..clearSelection();

      expect(cubit.state.selectedItemId, isNull);
      expect(ids(cubit.state), [brassKey]);
    });

    test('the selection survives unrelated progress changes', () async {
      final cubit = await withKey()
        ..toggle(brassKey);

      await progress.save(newGame.withItem(brassKey).withFlag('seen'));
      await pumpEventQueue();

      expect(cubit.state.selectedItemId, brassKey);
    });

    test('a used-up item leaves the panel and loses the selection', () async {
      final cubit = await withKey()
        ..toggle(brassKey);

      await progress.save(newGame.withFlag(doorOpenFlag));
      await pumpEventQueue();

      expect(cubit.state.items, isEmpty);
      expect(cubit.state.selectedItemId, isNull);
    });
  });

  test('an item missing from the catalog is skipped, not a crash', () async {
    final cubit = build(source: ContentAssetSource(minimalCaseBundle()));
    addTearDown(cubit.close);
    await cubit.load();

    await progress.save(newGame.withItem(brassKey));
    await pumpEventQueue();

    expect(cubit.state.items, isEmpty);
  });
}
