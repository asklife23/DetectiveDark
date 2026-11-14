import 'package:detective_dark/app/game/game_texts_cubit.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/start_game.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/tap_hotspot.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:get_it/get_it.dart';

/// Scenes: content, the use cases that change the game and the scene bloc.
///
/// Blocs and cubits are factories: every screen that asks gets a fresh one
/// and closes it when the screen goes away.
void registerSceneEngine(GetIt getIt) {
  getIt
    ..registerLazySingleton<SceneContentRepository>(
      () => AssetSceneContentRepository(getIt<ContentAssetSource>()),
    )
    // The single path on which progress changes (ADR 0014): one instance,
    // shared by every use case that writes.
    ..registerLazySingleton<EffectPipeline>(
      () => EffectPipeline(
        progressRepository: getIt<ProgressRepository>(),
        eventBus: getIt<GameEventBus>(),
      ),
    )
    ..registerLazySingleton<EnterScene>(
      () => EnterScene(
        pipeline: getIt<EffectPipeline>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton<StartGame>(
      () => StartGame(
        contentRepository: getIt<SceneContentRepository>(),
        progressRepository: getIt<ProgressRepository>(),
        enterScene: getIt<EnterScene>(),
      ),
    )
    ..registerLazySingleton<TapHotspot>(
      () => TapHotspot(
        pipeline: getIt<EffectPipeline>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerFactory<SceneBloc>(
      () => SceneBloc(
        caseId: ContentPaths.defaultCaseId,
        startGame: getIt<StartGame>(),
        enterScene: getIt<EnterScene>(),
        tapHotspot: getIt<TapHotspot>(),
        progressRepository: getIt<ProgressRepository>(),
      ),
    )
    ..registerFactory<GameTextsCubit>(
      () => GameTextsCubit(
        loader: getIt<ContentTextLoader>(),
        caseId: ContentPaths.defaultCaseId,
      ),
    );
}
