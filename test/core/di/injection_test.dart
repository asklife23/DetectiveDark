import 'package:detective_dark/app/game/game_texts_cubit.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/di/injection.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  late GetIt getIt;
  final config = AppConfig.fromEnvironment(Flavor.dev);

  setUp(() async {
    getIt = GetIt.asNewInstance();
    await configureDependencies(
      getIt,
      config,
      assetBundle: minimalCaseBundle(),
    );
  });
  tearDown(() => getIt.reset());

  test('registers the AppConfig', () {
    expect(getIt<AppConfig>(), same(config));
  });

  test('shared services are singletons', () {
    expect(getIt<GameEventBus>(), same(getIt<GameEventBus>()));
    expect(getIt<ProgressRepository>(), same(getIt<ProgressRepository>()));
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
