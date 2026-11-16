import 'package:detective_dark/app/game/game_texts_cubit.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/device/device_id_provider.dart';
import 'package:detective_dark/core/di/injection.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/repositories/drift_progress_repository.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/progress/domain/services/progress_autosave.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/in_memory_key_value_store.dart';

void main() {
  late GetIt getIt;
  final config = AppConfig.fromEnvironment(Flavor.dev);
  late InMemoryKeyValueStore keyValueStore;

  setUp(() async {
    getIt = GetIt.asNewInstance();
    keyValueStore = InMemoryKeyValueStore();
    await configureDependencies(
      getIt,
      config,
      assetBundle: minimalCaseBundle(),
      keyValueStore: keyValueStore,
      progressRepository: InMemoryProgressRepository(),
    );
  });
  tearDown(() => getIt.reset());

  test('registers the AppConfig', () {
    expect(getIt<AppConfig>(), same(config));
  });

  test('the device ID is created during start-up', () async {
    final stored = keyValueStore.values[DeviceIdProvider.storageKey];

    expect(stored, isNotEmpty);
    expect((await getIt<DeviceIdProvider>().get()).valueOrNull, stored);
  });

  test('shared services are singletons', () {
    expect(getIt<GameEventBus>(), same(getIt<GameEventBus>()));
    expect(getIt<ProgressRepository>(), same(getIt<ProgressRepository>()));
  });

  test('a progress given from outside has no autosave', () {
    expect(getIt<ProgressRepository>(), isA<InMemoryProgressRepository>());
    expect(getIt<ProgressAutosave>(), isA<NoAutosave>());
  });

  test('without one, the progress is kept in the save database', () async {
    final app = GetIt.asNewInstance();
    addTearDown(app.reset);
    await configureDependencies(
      app,
      config,
      assetBundle: minimalCaseBundle(),
      keyValueStore: keyValueStore,
    );

    // Only asked, not created: creating it would open the database file
    // of the device, which a unit test must not touch.
    expect(app.isRegistered<DriftProgressRepository>(), isTrue);
    expect(app.isRegistered<AppDatabase>(), isTrue);
    expect(app.isRegistered<ProgressRepository>(), isTrue);
    expect(app.isRegistered<ProgressAutosave>(), isTrue);
  });

  test('blocs and cubits are created fresh for every screen', () async {
    final first = getIt<SceneBloc>();
    final second = getIt<SceneBloc>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(first, isNot(same(second)));
    expect(getIt<GameTextsCubit>(), isNot(same(getIt<GameTextsCubit>())));
  });

  test('the registered scene bloc starts a game from the content', () async {
    final bloc = getIt<SceneBloc>()..add(const SceneStarted());
    addTearDown(bloc.close);
    await pumpEventQueue();

    expect(bloc.state.status, SceneStatus.ready);
    expect(bloc.state.scene?.id, 'yard');
  });
}
